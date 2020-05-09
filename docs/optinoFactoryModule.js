const OptinoFactory = {
  template: `
    <div>
      <b-card header-class="warningheader" header="Incorrect Network Detected" v-if="network != 1337 && network != 3">
        <b-card-text>
          Please switch to the Geth Devnet in MetaMask and refresh this page
        </b-card-text>
      </b-card>
      <b-button v-b-toggle.optinoFactory size="sm" block variant="outline-info">Optino Factory {{ address.substring(0, 6) }}</b-button>
      <b-collapse id="optinoFactory" visible class="mt-2">
        <b-card no-body class="border-0" v-if="network == 1337 || network == 3">
          <b-row>
            <b-col cols="4" class="small">Factory</b-col><b-col class="small truncate" cols="8"><b-link :href="explorer + 'address/' + address + '#code'" class="card-link" target="_blank">{{ address }}</b-link></b-col>
          </b-row>
          <b-row>
            <b-col cols="4" class="small">OptinoToken</b-col><b-col class="small truncate" cols="8"><b-link :href="explorer + 'address/' + optinoTokenTemplate + '#code'" class="card-link" target="_blank">{{ optinoTokenTemplate }}</b-link></b-col>
          </b-row>
          <b-row>
            <b-col cols="4" class="small">Owner</b-col><b-col class="small truncate" cols="8"><b-link :href="explorer + 'address/' + owner" class="card-link" target="_blank">{{ owner }}</b-link></b-col>
          </b-row>
          <b-row v-for="(config, index) in configData" v-bind:key="index">
            <b-col>
              <b-row>
                <b-col colspan="2" class="small truncate">
                  Config {{ config.index }} - <em>{{ config.description }}</em>
                </b-col>
              </b-row>
              <b-row>
                <b-col cols="4" class="small truncate">• key</b-col>
                <b-col class="small truncate">{{ config.configKey }}</b-col>
              </b-row>
              <b-row>
                <b-col cols="4" class="small truncate">• baseToken</b-col>
                <b-col class="small truncate"><b-link :href="explorer + 'address/' + config.baseToken" class="card-link" target="_blank">{{ config.baseToken }}</b-link></b-col>
              </b-row>
              <b-row>
                <b-col cols="4" class="small truncate">• quoteToken</b-col>
                <b-col class="small truncate"><b-link :href="explorer + 'address/' + config.quoteToken" class="card-link" target="_blank">{{ config.quoteToken }}</b-link></b-col>
              </b-row>
              <b-row>
                <b-col cols="4" class="small truncate">• priceFeed</b-col>
                <b-col class="small truncate"><b-link :href="explorer + 'address/' + config.priceFeed" class="card-link" target="_blank">{{ config.priceFeed }}</b-link></b-col>
              </b-row>
              <b-row>
                <b-col cols="4" class="small truncate">• maxTerm</b-col>
                <b-col class="small truncate">{{ config.maxTermString }} ({{ config.maxTerm }}s)</b-col>
              </b-row>
              <b-row>
                <b-col cols="4" class="small truncate">• fee</b-col>
                <b-col class="small truncate">{{ config.fee.shift(-16) }}%</b-col>
              </b-row>
              <b-row>
                <b-col cols="4" class="small truncate">• timestamp</b-col>
                <b-col class="small truncate">{{ new Date(config.timestamp*1000).toLocaleString() }}</b-col>
              </b-row>
            </b-col>
          </b-row>
          <b-row v-for="(series, index) in seriesData" v-bind:key="'a' + index">
            <b-col>
              <b-row>
                <b-col colspan="2" class="small truncate">
                  Series {{ series.index }} - <em>{{ series.description }}</em>
                </b-col>
              </b-row>
              <b-row>
                <b-col cols="4" class="small truncate">• seriesKey</b-col>
                <b-col class="small truncate">{{ series.seriesKey }}</b-col>
              </b-row>
              <b-row>
                <b-col cols="4" class="small truncate">• configKey</b-col>
                <b-col class="small truncate">{{ series.configKey }}</b-col>
              </b-row>
              <!--
              <b-row>
                <b-col cols="4" class="small truncate">• baseToken</b-col>
                <b-col class="small truncate"><b-link :href="explorer + 'address/' + series.baseToken" class="card-link" target="_blank">{{ series.baseToken }}</b-link></b-col>
              </b-row>
              <b-row>
                <b-col cols="4" class="small truncate">• quoteToken</b-col>
                <b-col class="small truncate"><b-link :href="explorer + 'address/' + series.quoteToken" class="card-link" target="_blank">{{ series.quoteToken }}</b-link></b-col>
              </b-row>
              <b-row>
                <b-col cols="4" class="small truncate">• priceFeed</b-col>
                <b-col class="small truncate"><b-link :href="explorer + 'address/' + series.priceFeed" class="card-link" target="_blank">{{ series.priceFeed }}</b-link></b-col>
              </b-row>
              -->
              <b-row>
                <b-col cols="4" class="small truncate">• callPut</b-col>
                <b-col class="small truncate">{{ series.callPut }}</b-col>
              </b-row>
              <b-row>
                <b-col cols="4" class="small truncate">• expiry</b-col>
                <b-col class="small truncate">{{ new Date(series.expiry*1000).toLocaleString() }}</b-col>
              </b-row>
              <b-row>
                <b-col cols="4" class="small truncate">• strike</b-col>
                <b-col class="small truncate">{{ series.strike }}</b-col>
              </b-row>
              <b-row>
                <b-col cols="4" class="small truncate">• timestamp</b-col>
                <b-col class="small truncate">{{ new Date(series.timestamp*1000).toLocaleString() }}</b-col>
              </b-row>
              <b-row>
                <b-col cols="4" class="small truncate">• optinoToken</b-col>
                <b-col class="small truncate"><b-link :href="explorer + 'address/' + series.optinoToken" class="card-link" target="_blank">{{ series.optinoToken }}</b-link></b-col>
              </b-row>
              <b-row>
                <b-col cols="4" class="small truncate">• coverToken</b-col>
                <b-col class="small truncate"><b-link :href="explorer + 'address/' + series.coverToken" class="card-link" target="_blank">{{ series.coverToken }}</b-link></b-col>
              </b-row>
            </b-col>
          </b-row>
        </b-card>
      </b-collapse>
    </div>
  `,
  data: function () {
    return {
      // count: 0,
    }
  },
  computed: {
    network() {
      return store.getters['connection/network'];
    },
    explorer() {
      return store.getters['connection/explorer'];
    },
    address() {
      return store.getters['optinoFactory/address'];
    },
    optinoTokenTemplate() {
      return store.getters['optinoFactory/optinoTokenTemplate'];
    },
    owner() {
      return store.getters['optinoFactory/owner'];
    },
    configData() {
      return store.getters['optinoFactory/configData'];
    },
    seriesData() {
      return store.getters['optinoFactory/seriesData'];
    },
  },
};


const optinoFactoryModule = {
  namespaced: true,
  state: {
    address: OPTINOFACTORYADDRESS,
    optinoTokenTemplate: "",
    owner: "(loading)",
    configData: [],
    seriesData: [],
    tokenData: {}, // { ADDRESS0: { symbol: "ETH", name: "Ether", decimals: "18", balance: "0", totalSupply: null }},
    params: null,
    executing: false,
  },
  getters: {
    address: state => state.address,
    optinoTokenTemplate: state => state.optinoTokenTemplate,
    owner: state => state.owner,
    configData: state => state.configData,
    seriesData: state => state.seriesData,
    tokenData: state => state.tokenData,
    params: state => state.params,
  },
  mutations: {
    updateConfig(state, {index, config}) {
      Vue.set(state.configData, index, config);
      logDebug("optinoFactoryModule", "updateConfig(" + index + ", " + JSON.stringify(config) + ")")
    },
    updateSeries(state, {index, series}) {
      Vue.set(state.seriesData, index, series);
      logDebug("optinoFactoryModule", "updateSeries(" + index + ", " + JSON.stringify(series) + ")")
    },
    updateToken(state, {key, token}) {
      Vue.set(state.tokenData, key, token);
      logDebug("optinoFactoryModule", "updateToken(" + key + ", " + JSON.stringify(token) + ")")
    },
    updateOptinoTokenTemplate(state, optinoTokenTemplate) {
      state.optinoTokenTemplate = optinoTokenTemplate;
      logDebug("optinoFactoryModule", "updateOptinoTokenTemplate('" + optinoTokenTemplate + "')")
    },
    updateOwner(state, owner) {
      state.owner = owner;
      logDebug("optinoFactoryModule", "updateOwner('" + owner + "')")
    },
    updateParams(state, params) {
      state.params = params;
      logDebug("optinoFactoryModule", "updateParams('" + params + "')")
    },
    updateExecuting(state, executing) {
      state.executing = executing;
      logDebug("optinoFactoryModule", "updateExecuting(" + executing + ")")
    },
  },
  actions: {
    // Called by Connection.execWeb3()
    async execWeb3({ state, commit, rootState }, { count, networkChanged, blockChanged, coinbaseChanged }) {
      logDebug("optinoFactoryModule", "execWeb3() start[" + count + ", " + JSON.stringify(rootState.route.params) + ", " + networkChanged + ", " + blockChanged + ", " + coinbaseChanged+ "]");
      if (!state.executing) {
        commit('updateExecuting', true);
        logDebug("optinoFactoryModule", "execWeb3() start[" + count + ", " + JSON.stringify(rootState.route.params) + ", " + networkChanged + ", " + blockChanged + ", " + coinbaseChanged + "]");

        var paramsChanged = false;
        if (state.params != rootState.route.params.param) {
          logDebug("optinoFactoryModule", "execWeb3() params changed from " + state.params + " to " + JSON.stringify(rootState.route.params.param));
          paramsChanged = true;
          commit('updateParams', rootState.route.params.param);
        }

        var contract = web3.eth.contract(OPTINOFACTORYABI).at(state.address);
        if (networkChanged || blockChanged || coinbaseChanged || paramsChanged) {
          var _optinoTokenTemplate = promisify(cb => contract.optinoTokenTemplate(cb));
          var optinoTokenTemplate = await _optinoTokenTemplate;
          if (optinoTokenTemplate !== state.optinoTokenTemplate) {
            commit('updateOptinoTokenTemplate', optinoTokenTemplate);
          }
          var _owner = promisify(cb => contract.owner(cb));
          var owner = await _owner;
          if (owner !== state.owner) {
            commit('updateOwner', owner);
          }
          var _configDataLength = promisify(cb => contract.configDataLength(cb));
          var configDataLength = await _configDataLength;
          logDebug("optinoFactoryModule", "execWeb3() configDataLength: " + configDataLength);
          for (var i = 0; i < configDataLength; i++) {
            var _config = promisify(cb => contract.getConfigByIndex(new BigNumber(i).toString(), cb));
            var config = await _config;
            logDebug("optinoFactoryModule", "execWeb3() config: " + JSON.stringify(config));
            var configKey = config[0];
            var baseToken = config[1];
            var quoteToken = config[2];
            var priceFeed = config[3];
            var decimalsData = config[4];
            var decimals = parseInt(decimalsData / 1000000 % 100);
            var baseDecimals = parseInt(decimalsData / 10000 % 100);
            var quoteDecimals = parseInt(decimalsData / 100 % 100);
            var rateDecimals = parseInt(decimalsData % 100);
            var maxTerm = config[5];
            var fee = config[6];
            var description = config[7];
            var timestamp = config[8];
            var maxTermString = getTermFromSeconds(maxTerm);

            // bytes32 _configKey, address _baseToken, address _quoteToken, address _priceFeed, uint _decimalsData, uint _maxTerm, uint _fee, string memory _description, uint _timestamp

            // TODO: Check timestamp for updated info
            if (i >= state.configData.length) {
              commit('updateConfig', { index: i, config: { index: i, configKey: configKey, baseToken: baseToken, quoteToken: quoteToken, priceFeed: priceFeed, decimals: decimals, baseDecimals: baseDecimals, quoteDecimals: quoteDecimals, rateDecimals: rateDecimals, maxTerm: maxTerm, fee: fee, description: description, timestamp: timestamp, maxTermString: maxTermString } });
            }

            // TODO: Fix updating of token info. Refresh for now
            [baseToken, quoteToken].forEach(async function(t) {
              if (!(t in state.tokenData)) {
                // Commit first so it does not get redone
                commit('updateToken', { key: t, token: { address: t } });
                var _tokenInfo = promisify(cb => contract.getTokenInfo(t, store.getters['connection/coinbase'], OPTINOFACTORYADDRESS, cb));
                var tokenInfo = await _tokenInfo;
                var totalSupply;
                var balance;
                // WORKAROUND - getTokenInfo returns garbled totalSupply (set to 0) and balance (tokenOwner's balance). May be web3.js translation
                if (t == ADDRESS0) {
                  totalSupply = new BigNumber(0);
                  balance = store.getters['connection/balance'];
                } else {
                  totalSupply = new BigNumber(tokenInfo[1]);
                  balance = new BigNumber(tokenInfo[2]);
                }
                commit('updateToken', { key: t, token: { address: t, symbol: tokenInfo[4], name: tokenInfo[5], decimals: tokenInfo[0], totalSupply: totalSupply.toString(), balance: balance.toString(), allowance: tokenInfo[3] } });
              }
            });
          }
          var _seriesDataLength = promisify(cb => contract.seriesDataLength(cb));
          var seriesDataLength = await _seriesDataLength;
          logDebug("optinoFactoryModule", "execWeb3() seriesDataLength: " + seriesDataLength);
          for (var i = 0; i < seriesDataLength; i++) {
            var _series = promisify(cb => contract.getSeriesByIndex(new BigNumber(i).toString(), cb));
            var series = await _series;
            logDebug("optinoFactoryModule", "execWeb3() config: " + JSON.stringify(series));
            var seriesKey = series[0];
            var configKey = series[1];
            var callPut = series[2].toString();
            var expiry = series[3].toString();
            var strike = new BigNumber(series[4]);
            var bound = new BigNumber(series[5]);
            var timestamp = series[6].toString();
            var optinoToken = series[7];
            var coverToken = series[8];
            // TODO: Fix updating of token info. Refresh for now
            [optinoToken, coverToken].forEach(async function(t) {
              if (!(t in state.tokenData)) {
                // Commit first so it does not get redone
                commit('updateToken', { key: t, token: { address: t } });
                var _tokenInfo = promisify(cb => contract.getTokenInfo(t, store.getters['connection/coinbase'], OPTINOFACTORYADDRESS, cb));
                var tokenInfo = await _tokenInfo;
                var totalSupply;
                var balance;
                // WORKAROUND - getTokenInfo returns garbled totalSupply (set to 0) and balance (tokenOwner's balance). May be web3.js translation
                if (t == ADDRESS0) {
                  totalSupply = new BigNumber(0);
                  balance = store.getters['connection/balance'];
                } else {
                  totalSupply = new BigNumber(tokenInfo[1]);
                  balance = new BigNumber(tokenInfo[2]);
                }
                commit('updateToken', { key: t, token: { address: t, symbol: tokenInfo[4], name: tokenInfo[5], decimals: tokenInfo[0], totalSupply: totalSupply.toString(), balance: balance.toString(), allowance: tokenInfo[3] } });
              }
            });
            // TODO: Check timestamp for updated info
            if (i >= state.seriesData.length) {
              commit('updateSeries', { index: i, series: { index: i, seriesKey: seriesKey, configKey: configKey, callPut: callPut, expiry: expiry, strike: strike.shift(-18).toString(), bound: bound.shift(-18).toString(), timestamp: timestamp, optinoToken: optinoToken, coverToken: coverToken } });
            }
          }
        }
        commit('updateExecuting', false);
        logDebug("optinoFactoryModule", "execWeb3() end[" + count + ", " + networkChanged + ", " + blockChanged + ", " + coinbaseChanged + "]");
      } else {
        logDebug("optinoFactoryModule", "execWeb3() already executing[" + count + ", " + networkChanged + ", " + blockChanged + ", " + coinbaseChanged + "]");
      }
    },
  },
};