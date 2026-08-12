/**
 * \file Library with public methods provided by component airlock-microgateway-operator.
 */

local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';

local inv = kap.inventory();

local gw =
  if std.member(inv.applications, 'gateway-api') then
    import 'lib/gateway-api.libsonnet'
  else
    error 'Application "gateway-api" is required for the Gateway API helpers provided by lib/airlock-microgateway-operator.libsonnet';

/**
 * The main Airlock Microgateway K8s API group
 */
local airlock_group = 'microgateway.airlock.com';
/**
 * The Airlock Microgateway K8s API group for temporary copies of upstream
 * Gateway AP resources
 */
local xopenshift_group = 'x-openshift.microgateway.airlock.com';

/**
 * Helper function to create Airlock Microgateway GatewayParameters resources
 *
 * \arg name used as `metadata.name`
 * \returns a partial `GatewayParameters` object
 */
local GatewayParameters = function(name='') {
  apiVersion: '%s/v1alpha1' % airlock_group,
  kind: 'GatewayParameters',
  metadata: {
    name: name,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
  },
};

/**
 * Helper function to create Airlock Microgateway SessionHandling resources
 *
 * \arg name used as `metadata.name`
 * \returns a partial `SessionHandling` object
 */
local SessionHandling = function(name='') {
  apiVersion: '%s/v1alpha1' % airlock_group,
  kind: 'SessionHandling',
  metadata: {
    name: name,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
  },
};

/**
 * Helper function to create Airlock Microgateway RedisProvider resources
 *
 * \arg name used as `metadata.name`
 * \returns a partial `RedisProvider` object
 */
local RedisProvider = function(name='') {
  apiVersion: '%s/v1alpha1' % airlock_group,
  kind: 'RedisProvider',
  metadata: {
    name: name,
    annotations: {
      'argocd.argoproj.io/sync-options': 'SkipDryRunOnMissingResource=true',
    },
  },
};

{
  GatewayParameters: GatewayParameters,
  GatewayClass: gw.GatewayClass,
  Gateway: gw.Gateway,
  RedisProvider: RedisProvider,
  SessionHandling: SessionHandling,

  gatewayApiGroup: gw.gatewayApiGroup,
  airlockApiGroup: airlock_group,
  xopenshiftApiGroup: xopenshift_group,
}
