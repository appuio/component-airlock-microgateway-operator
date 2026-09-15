local alertpatching = import 'lib/alert-patching.libsonnet';
local com = import 'lib/commodore.libjsonnet';
local kap = import 'lib/kapitan.libjsonnet';
local prom = import 'lib/prom.libsonnet';
local inv = kap.inventory();
local params = inv.parameters.airlock_microgateway_operator;

local groups = std.filter(
  function(g) std.length(g.rules) > 0,
  std.map(
    function(g)
      alertpatching.filterPatchRules(
        g,
        ignoreNames=com.renderArray(params.alerts.ignoreNames),
        patches=params.alerts.patches,
        preserveRecordingRules=true,
        patchNames=false,
      ),
    [
      {
        name: 'airlock-microgateway-license.rules',
        rules: [
          {
            alert: 'AirlockMicrogatewayLicenseExpiresSoon',
            expr: 'max(microgateway_license_expiry_timestamp_seconds) - time() < 30*24*3600',
            annotations: {
              summary: 'Airlock Microgateway license expires in less than a month',
              description: 'The Airlock Microgateway license expires in {{ $value|humanizeDuration }}. Contact the customer/Ergon to renew the license.',
            },
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'AirlockMicrogatewayLicenseExpiresVerySoon',
            expr: 'max(microgateway_license_expiry_timestamp_seconds) - time() < 10*24*3600',
            annotations: {
              summary: 'Airlock Microgateway license expires in less than 10 days',
              description: 'The Airlock Microgateway license expires in {{ $value|humanizeDuration }}. Contact the customer/Ergon to renew the license.',
            },
            labels: {
              severity: 'critical',
            },
          },
        ],
      },
    ],
  )
);

local operator_rules = prom.PrometheusRule('operator-rules') {
  metadata+: {
    namespace: params.namespace,
  },
  spec: {
    groups: groups,
  },
};

local has_monitoring = std.member(inv.applications, 'prometheus') || std.member(inv.applications, 'openshift4-monitoring');
local has_alerts = std.length(groups) > 0;

{
  [if has_alerts && has_monitoring then 'operator_rules']: operator_rules,
}
