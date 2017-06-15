window.JSON || (window.JSON = {
    parse: function(sJSON) {
      return eval("(" + sJSON + ")")
    }
  }), ! function(e, t, s) {
    "undefined" != typeof module && module.exports ? module.exports = s() : "function" == typeof define && define.amd ? define(s) : t[e] = s()
  }("reqwest", this, function() {
    function succeed(e) {
      var t = protocolRe.exec(e.url);
      return t = t && t[1] || window.location.protocol, httpsRe.test(t) ? twoHundo.test(e.request.status) : !!e.request.response
    }

    function handleReadyState(e, t, s) {
      return function() {
        return e._aborted ? s(e.request) : e._timedOut ? s(e.request, "Request is aborted: timeout") : void(e.request && 4 == e.request[readyState] && (e.request.onreadystatechange = noop, succeed(e) ? t(e.request) : s(e.request)))
      }
    }

    function setHeaders(e, t) {
      var s, r = t.headers || {};
      r.Accept = r.Accept || defaultHeaders.accept[t.type] || defaultHeaders.accept["*"];
      var n = "function" == typeof FormData && t.data instanceof FormData;
      t.crossOrigin || r[requestedWith] || (r[requestedWith] = defaultHeaders.requestedWith), r[contentType] || n || (r[contentType] = t.contentType || defaultHeaders.contentType);
      for (s in r) r.hasOwnProperty(s) && "setRequestHeader" in e && e.setRequestHeader(s, r[s])
    }

    function setCredentials(e, t) {
      "undefined" != typeof t.withCredentials && "undefined" != typeof e.withCredentials && (e.withCredentials = !!t.withCredentials)
    }

    function generalCallback(e) {
      lastValue = e
    }

    function urlappend(e, t) {
      return e + (/\?/.test(e) ? "&" : "?") + t
    }

    function handleJsonp(e, t, s, r) {
      var n = uniqid++,
        i = e.jsonpCallback || "callback",
        o = e.jsonpCallbackName || reqwest.getcallbackPrefix(n),
        a = new RegExp("((^|\\?|&)" + i + ")=([^&]+)"),
        l = r.match(a),
        u = doc.createElement("script"),
        c = 0,
        h = navigator.userAgent.indexOf("MSIE 10.0") !== -1;
      return l ? "?" === l[3] ? r = r.replace(a, "$1=" + o) : o = l[3] : r = urlappend(r, i + "=" + o), win[o] = generalCallback, u.type = "text/javascript", u.src = r, u.async = !0, "undefined" == typeof u.onreadystatechange || h || (u.htmlFor = u.id = "_reqwest_" + n), u.onload = u.onreadystatechange = function() {
        return !(u[readyState] && "complete" !== u[readyState] && "loaded" !== u[readyState] || c) && (u.onload = u.onreadystatechange = null, u.onclick && u.onclick(), t(lastValue), lastValue = void 0, head.removeChild(u), void(c = 1))
      }, head.appendChild(u), {
        abort: function() {
          u.onload = u.onreadystatechange = null, s({}, "Request is aborted: timeout", {}), lastValue = void 0, head.removeChild(u), c = 1
        }
      }
    }

    function getRequest(e, t) {
      var s, r = this.o,
        n = (r.method || "GET").toUpperCase(),
        i = "string" == typeof r ? r : r.url,
        o = r.processData !== !1 && r.data && "string" != typeof r.data ? reqwest.toQueryString(r.data) : r.data || null,
        a = !1;
      return "jsonp" != r.type && "GET" != n || !o || (i = urlappend(i, o), o = null), "jsonp" == r.type ? handleJsonp(r, e, t, i) : (s = r.xhr && r.xhr(r) || xhr(r), s.open(n, i, r.async !== !1), setHeaders(s, r), setCredentials(s, r), win[xDomainRequest] && s instanceof win[xDomainRequest] ? (s.onload = e, s.onerror = t, s.onprogress = function() {}, a = !0) : s.onreadystatechange = handleReadyState(this, e, t), r.before && r.before(s), a ? setTimeout(function() {
        s.send(o)
      }, 200) : s.send(o), s)
    }

    function Reqwest(e, t) {
      this.o = e, this.fn = t, init.apply(this, arguments)
    }

    function setType(e) {
      return e.match("json") ? "json" : e.match("javascript") ? "js" : e.match("text") ? "html" : e.match("xml") ? "xml" : void 0
    }

    function init(o, fn) {
      function complete(e) {
        for (o.timeout && clearTimeout(self.timeout), self.timeout = null; self._completeHandlers.length > 0;) self._completeHandlers.shift()(e)
      }

      function success(resp) {
        var type = o.type || resp && setType(resp.getResponseHeader("Content-Type"));
        resp = "jsonp" !== type ? self.request : resp;
        var filteredResponse = globalSetupOptions.dataFilter(resp.responseText, type),
          r = filteredResponse;
        try {
          resp.responseText = r
        } catch (e) {}
        if (r) switch (type) {
          case "json":
            try {
              resp = win.JSON ? win.JSON.parse(r) : eval("(" + r + ")")
            } catch (e) {
              return error(resp, "Could not parse JSON in response", e)
            }
            break;
          case "js":
            resp = eval(r);
            break;
          case "html":
            resp = r;
            break;
          case "xml":
            resp = resp.responseXML && resp.responseXML.parseError && resp.responseXML.parseError.errorCode && resp.responseXML.parseError.reason ? null : resp.responseXML
        }
        for (self._responseArgs.resp = resp, self._fulfilled = !0, fn(resp), self._successHandler(resp); self._fulfillmentHandlers.length > 0;) resp = self._fulfillmentHandlers.shift()(resp);
        complete(resp)
      }

      function timedOut() {
        self._timedOut = !0, self.request.abort()
      }

      function error(e, t, s) {
        for (e = self.request, self._responseArgs.resp = e, self._responseArgs.msg = t, self._responseArgs.t = s, self._erred = !0; self._errorHandlers.length > 0;) self._errorHandlers.shift()(e, t, s);
        complete(e)
      }
      this.url = "string" == typeof o ? o : o.url, this.timeout = null, this._fulfilled = !1, this._successHandler = function() {}, this._fulfillmentHandlers = [], this._errorHandlers = [], this._completeHandlers = [], this._erred = !1, this._responseArgs = {};
      var self = this;
      fn = fn || function() {}, o.timeout && (this.timeout = setTimeout(function() {
        timedOut()
      }, o.timeout)), o.success && (this._successHandler = function() {
        o.success.apply(o, arguments)
      }), o.error && this._errorHandlers.push(function() {
        o.error.apply(o, arguments)
      }), o.complete && this._completeHandlers.push(function() {
        o.complete.apply(o, arguments)
      }), this.request = getRequest.call(this, success, error)
    }

    function reqwest(e, t) {
      return new Reqwest(e, t)
    }

    function normalize(e) {
      return e ? e.replace(/\r?\n/g, "\r\n") : ""
    }

    function serial(e, t) {
      var s, r, n, i, o = e.name,
        a = e.tagName.toLowerCase(),
        l = function(e) {
          e && !e.disabled && t(o, normalize(e.attributes.value && e.attributes.value.specified ? e.value : e.text))
        };
      if (!e.disabled && o) switch (a) {
        case "input":
          /reset|button|image|file/i.test(e.type) || (s = /checkbox/i.test(e.type), r = /radio/i.test(e.type), n = e.value, (!(s || r) || e.checked) && t(o, normalize(s && "" === n ? "on" : n)));
          break;
        case "textarea":
          t(o, normalize(e.value));
          break;
        case "select":
          if ("select-one" === e.type.toLowerCase()) l(e.selectedIndex >= 0 ? e.options[e.selectedIndex] : null);
          else
            for (i = 0; e.length && i < e.length; i++) e.options[i].selected && l(e.options[i])
      }
    }

    function eachFormElement() {
      var e, t, s = this,
        r = function(e, t) {
          var r, n, i;
          for (r = 0; r < t.length; r++)
            for (i = e[byTag](t[r]), n = 0; n < i.length; n++) serial(i[n], s)
        };
      for (t = 0; t < arguments.length; t++) e = arguments[t], /input|select|textarea/i.test(e.tagName) && serial(e, s), r(e, ["input", "select", "textarea"])
    }

    function serializeQueryString() {
      return reqwest.toQueryString(reqwest.serializeArray.apply(null, arguments))
    }

    function serializeHash() {
      var e = {};
      return eachFormElement.apply(function(t, s) {
        t in e ? (e[t] && !isArray(e[t]) && (e[t] = [e[t]]), e[t].push(s)) : e[t] = s
      }, arguments), e
    }

    function buildParams(e, t, s, r) {
      var n, i, o, a = /\[\]$/;
      if (isArray(t))
        for (i = 0; t && i < t.length; i++) o = t[i], s || a.test(e) ? r(e, o) : buildParams(e + "[" + ("object" == typeof o ? i : "") + "]", o, s, r);
      else if (t && "[object Object]" === t.toString())
        for (n in t) buildParams(e + "[" + n + "]", t[n], s, r);
      else r(e, t)
    }
    var win = window,
      doc = document,
      httpsRe = /^http/,
      protocolRe = /(^\w+):\/\//,
      twoHundo = /^(20\d|1223)$/,
      byTag = "getElementsByTagName",
      readyState = "readyState",
      contentType = "Content-Type",
      requestedWith = "X-Requested-With",
      head = doc[byTag]("head")[0],
      uniqid = 0,
      callbackPrefix = "reqwest_" + +new Date,
      lastValue, xmlHttpRequest = "XMLHttpRequest",
      xDomainRequest = "XDomainRequest",
      noop = function() {},
      isArray = "function" == typeof Array.isArray ? Array.isArray : function(e) {
        return e instanceof Array
      },
      defaultHeaders = {
        contentType: "application/x-www-form-urlencoded",
        requestedWith: xmlHttpRequest,
        accept: {
          "*": "text/javascript, text/html, application/xml, text/xml, */*",
          xml: "application/xml, text/xml",
          html: "text/html",
          text: "text/plain",
          json: "application/json, text/javascript",
          js: "application/javascript, text/javascript"
        }
      },
      xhr = function(e) {
        if (e.crossOrigin === !0) {
          var t = win[xmlHttpRequest] ? new XMLHttpRequest : null;
          if (t && "withCredentials" in t) return t;
          if (win[xDomainRequest]) return new XDomainRequest;
          throw new Error("Browser does not support cross-origin requests")
        }
        return win[xmlHttpRequest] ? new XMLHttpRequest : new ActiveXObject("Microsoft.XMLHTTP")
      },
      globalSetupOptions = {
        dataFilter: function(e) {
          return e
        }
      };
    return Reqwest.prototype = {
      abort: function() {
        this._aborted = !0, this.request.abort()
      },
      retry: function() {
        init.call(this, this.o, this.fn)
      },
      then: function(e, t) {
        return e = e || function() {}, t = t || function() {}, this._fulfilled ? this._responseArgs.resp = e(this._responseArgs.resp) : this._erred ? t(this._responseArgs.resp, this._responseArgs.msg, this._responseArgs.t) : (this._fulfillmentHandlers.push(e), this._errorHandlers.push(t)), this
      },
      always: function(e) {
        return this._fulfilled || this._erred ? e(this._responseArgs.resp) : this._completeHandlers.push(e), this
      },
      fail: function(e) {
        return this._erred ? e(this._responseArgs.resp, this._responseArgs.msg, this._responseArgs.t) : this._errorHandlers.push(e), this
      },
      "catch": function(e) {
        return this.fail(e)
      }
    }, reqwest.serializeArray = function() {
      var e = [];
      return eachFormElement.apply(function(t, s) {
        e.push({
          name: t,
          value: s
        })
      }, arguments), e
    }, reqwest.serialize = function() {
      if (0 === arguments.length) return "";
      var e, t, s = Array.prototype.slice.call(arguments, 0);
      return e = s.pop(), e && e.nodeType && s.push(e) && (e = null), e && (e = e.type), t = "map" == e ? serializeHash : "array" == e ? reqwest.serializeArray : serializeQueryString, t.apply(null, s)
    }, reqwest.toQueryString = function(e, t) {
      var s, r, n = t || !1,
        i = [],
        o = encodeURIComponent,
        a = function(e, t) {
          t = "function" == typeof t ? t() : null == t ? "" : t, i[i.length] = o(e) + "=" + o(t)
        };
      if (isArray(e))
        for (r = 0; e && r < e.length; r++) a(e[r].name, e[r].value);
      else
        for (s in e) e.hasOwnProperty(s) && buildParams(s, e[s], n, a);
      return i.join("&").replace(/%20/g, "+")
    }, reqwest.getcallbackPrefix = function() {
      return callbackPrefix
    }, reqwest.compat = function(e, t) {
      return e && (e.type && (e.method = e.type) && delete e.type, e.dataType && (e.type = e.dataType), e.jsonpCallback && (e.jsonpCallbackName = e.jsonpCallback) && delete e.jsonpCallback, e.jsonp && (e.jsonpCallback = e.jsonp)), new Reqwest(e, t)
    }, reqwest.ajaxSetup = function(e) {
      e = e || {};
      for (var t in e) globalSetupOptions[t] = e[t]
    }, reqwest
  }),
  function() {
    var e = [].slice,
      t = function(e, t) {
        return function() {
          return e.apply(t, arguments)
        }
      },
      s = function(e, t) {
        function s() {
          this.constructor = e
        }
        for (var n in t) r.call(t, n) && (e[n] = t[n]);
        return s.prototype = t.prototype, e.prototype = new s, e.__super__ = t.prototype, e
      },
      r = {}.hasOwnProperty;
    ! function(e, t) {
      return "function" == typeof define && define.amd ? define(function() {
        return t(e)
      }) : e.NeatComplete = t(e)
    }(this, function() {
      var r;
      return r = {}, r.addDomEvent = function(e, t, s) {
        var r;
        return e.addEventListener ? e.addEventListener(t, s, !1) : (r = function() {
          return s.apply(e, arguments)
        }, e.attachEvent("on" + t, r))
      }, r.removeDomEvent = function(e, t, s) {
        e.removeEventListener ? e.removeEventListener(t, s, !1) : e.detachEvent && e.detachEvent("on" + t, null)
      }, Array.prototype.indexOf || (Array.prototype.indexOf = function(e) {
        var t, s, r, n;
        if (null == this) throw new TypeError;
        if (n = Object(this), s = n.length >>> 0, 0 === s) return -1;
        if (r = 0, arguments.length > 0 && (r = Number(arguments[1]), r !== r ? r = 0 : 0 !== r && Infinity !== r && -Infinity !== r && (r = (r > 0 || -1) * Math.floor(Math.abs(r)))), r >= s) return -1;
        for (t = r >= 0 ? r : Math.max(s - Math.abs(r), 0); t < s;) {
          if (t in n && n[t] === e) return t;
          t++
        }
        return -1
      }), r.Dispatch = function() {
        function t() {}
        return t.prototype.setOption = function(e, t) {
          return this.options[e] = t, this
        }, t.prototype.getOption = function(e) {
          return this.options[e]
        }, t.prototype.on = function(e, t) {
          var s;
          return null == this.subs && (this.subs = {}), null == (s = this.subs)[e] && (s[e] = []), this.subs[e].push(t), this
        }, t.prototype.trigger = function() {
          var t, s, r, n, i, o, a;
          if (r = arguments[0], t = 2 <= arguments.length ? e.call(arguments, 1) : [], null != (null != (o = this.subs) ? o[r] : void 0))
            for (a = this.subs[r], n = 0, i = a.length; n < i; n++) s = a[n], s.apply(this, t);
          return this
        }, t
      }(), r.Widget = function(e) {
        function n(e, s) {
          this.element = e, this.options = null != s ? s : {}, this._onBlur = t(this._onBlur, this), this._onKeyDown = t(this._onKeyDown, this), this._onKeyPress = t(this._onKeyPress, this), this._onFocus = t(this._onFocus, this), this.enabled = !0, this.searchQueued = !1, this.element.setAttribute("autocomplete", "off"), this.services = [], this._applyDefaults(), null == this.getOption("container") && this.setOption("container", window.document.body), this._addListeners(), this.output = document.createElement("ul"), this.output.className = this.options.list_class, this._applyStyle("display", "none"), this._applyStyle("position", this.options.position), this.options.container.appendChild(this.output)
        }
        return s(n, e), n.prototype.defaults = {
          max_results: 10,
          list_class: "nc_list",
          item_class: "nc_item",
          hover_class: "nc_hover",
          footer_class: "nc_footer",
          empty_class: "nc_empty",
          error_class: "nc_error",
          position: "absolute",
          timeout: 400,
          ignore_returns: !0
        }, n.prototype.addService = function(e, t, s) {
          var n;
          return null == s && (s = {}), this.services.push(n = new r.Service(this, e, t, s)), n
        }, n.prototype.disable = function() {
          return this.enabled = !1, this
        }, n.prototype.enable = function() {
          return this.enabled = !0, this
        }, n.prototype.destroy = function() {
          document.body.removeChild(this.output), this.element.removeAttribute("autocomplete")
        }, n.prototype._applyDefaults = function() {
          var e, t, s, r;
          t = this.defaults, s = [];
          for (e in t) r = t[e], null == this.getOption(e) ? s.push(this.setOption(e, r)) : s.push(void 0);
          return s
        }, n.prototype._addListeners = function() {
          return r.addDomEvent(this.element, "focus", this._onFocus), r.addDomEvent(this.element, "keypress", this._onKeyPress), r.addDomEvent(this.element, "keydown", this._onKeyDown), r.addDomEvent(this.element, "blur", this._onBlur)
        }, n.prototype._removeListeners = function() {
          return r.removeDomEvent(this.element, "focus", this._onFocus), r.removeDomEvent(this.element, "keypress", this._onKeyPress), r.removeDomEvent(this.element, "keydown", this._onKeyDown), r.removeDomEvent(this.element, "blur", this._onBlur)
        }, n.prototype._onFocus = function() {
          return this.focused = !0
        }, n.prototype._onKeyPress = function(e) {
          var t, s, r;
          if (s = e.which || e.keyCode, this.visible && 13 === s) return null != (r = this.highlighted) && r.selectItem(), t = this.getOption("ignore_returns"), t && e.preventDefault ? e.preventDefault() : t && (e.returnValue = !1), this.highlighted = null
        }, n.prototype._onKeyDown = function(e) {
          var t, s;
          switch (t = e.which || e.keyCode) {
            case 38:
              return this.visible && this._moveHighlight(-1), !1;
            case 40:
              return this.visible && this._moveHighlight(1), !1;
            case 9:
              if (this.visible) return null != (s = this.highlighted) ? s.selectItem() : void 0;
              break;
            case 27:
              return this._hideResults();
            case 37:
            case 39:
            case 13:
              break;
            default:
              return this._getSuggestionsWithTimeout()
          }
        }, n.prototype._onBlur = function() {
          if (!this.mouseDownOnSelect) return this.focused = !1, this._hideResults()
        }, n.prototype._moveHighlight = function(e) {
          var t, s, r;
          return t = null != this.highlighted ? this.results.indexOf(this.highlighted) : -1, null != (s = this.highlighted) && s.unhighlight(), t += e, t < -1 ? t = this.results.length - 1 : t >= this.results.length && (t = -1), null != (r = this.results[t]) && r.highlight(), this.element.value = null != this.highlighted ? this.highlighted.value : this._val
        }, n.prototype._getSuggestionsWithTimeout = function() {
          return null != this._timeout && clearTimeout(this._timeout), this._timeout = setTimeout(function(e) {
            return function() {
              return e._getSuggestions()
            }
          }(this), this.options.timeout)
        }, n.prototype._getSuggestions = function() {
          var e, t, s, r, n;
          if (this.enabled) {
            if (!this._servicesReady()) return void(this.searchQueued = !0);
            if (this._val = this.element.value, this.error_content = null, "" !== this._val) {
              for (s = this.services, r = [], e = 0, t = s.length; e < t; e++) n = s[e], r.push(n.search(this._val));
              return r
            }
            return this._hideResults()
          }
        }, n.prototype._applyStyle = function(e, t) {
          return this.output.style[e] = t
        }, n.prototype._getPosition = function() {
          var e, t;
          for (t = this.element, e = {
              top: t.offsetTop + t.offsetHeight,
              left: t.offsetLeft
            }; t = t.offsetParent;) e.top += t.offsetTop, e.left += t.offsetLeft;
          return e
        }, n.prototype._hideResults = function() {
          var e, t, s, r, n;
          for (this.visible = !1, this._applyStyle("display", "none"), this.results = [], s = this.services, r = [], e = 0, t = s.length; e < t; e++) n = s[e], r.push(n.results = []);
          return r
        }, n.prototype._displayResults = function() {
          var e;
          return this.visible = !0, e = this._getPosition(), this.options.container === document.body && (this._applyStyle("left", e.left + "px"), this._applyStyle("top", e.top + "px")), this._applyStyle("display", "block")
        }, n.prototype._renderItem = function(e, t) {
          var s;
          return s = document.createElement("li"), s.innerHTML = e, null != t && (s.className = t), r.addDomEvent(s, "mousedown", function(e) {
            return function() {
              return e.mouseDownOnSelect = !0
            }
          }(this)), r.addDomEvent(s, "mouseup", function(e) {
            return function() {
              return e.mouseDownOnSelect = !1
            }
          }(this)), s
        }, n.prototype._renderFooter = function() {
          return this._renderItem(this.options.footer_content, this.options.footer_class)
        }, n.prototype._renderEmpty = function() {
          return this._renderItem(this.options.empty_content, this.options.empty_class)
        }, n.prototype._servicesReady = function() {
          var e, t, s, r, n;
          for (n = [], s = this.services, e = 0, t = s.length; e < t; e++) r = s[e], n.push(r.ready());
          return n.indexOf(!1) < 0
        }, n.prototype.showResults = function() {
          var e, t, s, r, n, i, o, a, l;
          if (this._servicesReady()) {
            for (this.searchQueued && (this._getSuggestions(), this.searchQueued = !1), this.results = [], this.output.innerHTML = "", i = this.services, t = 0, r = i.length; t < r; t++) l = i[t], this.results = this.results.concat(l.results);
            if (this.results.length) {
              for (this.results = this.results.sort(function(e, t) {
                  return t.score - e.score
                }), this.results = this.results.slice(0, +(this.getOption("max_results") - 1) + 1 || 9e9), o = this.results, s = 0, n = o.length; s < n; s++) a = o[s], this.output.appendChild(a.render());
              null != this.options.footer_content && "" !== (e = this._renderFooter()) && this.output.appendChild(e), this._displayResults()
            } else this.error_content ? (this.output.appendChild(this._renderItem(this.error_content, this.options.error_class)), this._displayResults()) : (null != this.options.empty_content ? (this.output.appendChild(this._renderEmpty()), this._displayResults()) : this._hideResults(), this.trigger("results:empty"));
            this.trigger("results:update")
          }
        }, n.prototype.selectHighlighted = function() {
          this.element.value = this.highlighted.value, this._hideResults(), this.trigger("result:select", this.highlighted.value, this.highlighted.data)
        }, n
      }(r.Dispatch), r.Service = function(e) {
        function n(e, s, r, n) {
          this.widget = e, this.name = s, this.search_fn = r, this.options = null != n ? n : {}, this._response = t(this._response, this), this.ready = t(this.ready, this), this.results = [], this._ready = !0, this.response = function(e) {
            return function() {
              return e._response.apply(e, arguments)
            }
          }(this)
        }
        return s(n, e), n.prototype.ready = function() {
          return this._ready
        }, n.prototype.search = function(e) {
          return this.last_query = e, this._ready = !1, this.search_fn(e, this.response)
        }, n.prototype._response = function(e, t) {
          var s, n, i;
          if (this.results = [], this.last_query === e) {
            for (this.results = [], n = 0, i = t.length; n < i; n++) s = t[n], this.results.push(new r._Result(this, s));
            return this._ready = !0, this.widget.showResults()
          }
        }, n
      }(r.Dispatch), r._Result = function() {
        function e(e, t) {
          var s, r, n, i;
          this.service = e, this.options = t, this.widget = this.service.widget, this.renderer = this.service.options.renderer || this.widget.options.renderer, this.value = null != (s = this.options) ? s.value : void 0, this.score = (null != (r = this.options) ? r.score : void 0) || 0, this.identifier = null != (n = this.options) ? n.identifier : void 0, this.data = (null != (i = this.options) ? i.data : void 0) || {}
        }
        return e.prototype.render = function() {
          return this.li = document.createElement("li"), this.li.innerHTML = null != this.renderer ? this.renderer(this.value, this.data) : this.value, this.li.className = this.widget.options.item_class, this.addEvents(), this.li
        }, e.prototype.addEvents = function() {
          return r.addDomEvent(this.li, "click", function(e) {
            return function(t) {
              return e.selectItem(), t.preventDefault ? t.preventDefault() : t.returnValue = !1
            }
          }(this)), r.addDomEvent(this.li, "mouseover", function(e) {
            return function() {
              return e.highlight()
            }
          }(this)), r.addDomEvent(this.li, "mouseout", function(e) {
            return function() {
              return e.unhighlight()
            }
          }(this)), r.addDomEvent(this.li, "mousedown", function(e) {
            return function() {
              return e.widget.mouseDownOnSelect = !0
            }
          }(this)), r.addDomEvent(this.li, "mouseup", function(e) {
            return function() {
              return e.widget.mouseDownOnSelect = !1
            }
          }(this))
        }, e.prototype.selectItem = function() {
          return this.service.trigger("result:select", this.value, this.data), this.widget.highlighted = this, this.widget.selectHighlighted()
        }, e.prototype.highlight = function() {
          var e;
          return null != (e = this.widget.highlighted) && e.unhighlight(), this.li.className = this.li.className + " " + this.widget.options.hover_class, this.widget.highlighted = this
        }, e.prototype.unhighlight = function() {
          return this.widget.highlighted = null, this.li.className = this.li.className.replace(new RegExp(this.widget.options.hover_class, "gi"), "")
        }, e
      }(), r
    })
  }.call(this),
  function() {
    var e = function(e, t) {
        return function() {
          return e.apply(t, arguments)
        }
      },
      t = function(e, t) {
        function r() {
          this.constructor = e
        }
        for (var n in t) s.call(t, n) && (e[n] = t[n]);
        return r.prototype = t.prototype, e.prototype = new r, e.__super__ = t.prototype, e
      },
      s = {}.hasOwnProperty;
    ! function(e, t) {
      return "function" == typeof define && define.amd ? define(["reqwest", "neat_complete"], function(s, r) {
        return t(e, s, r)
      }) : e.AddressFinder = t(e, window.reqwest, window.NeatComplete)
    }(this, function(s, r, n) {
      var i;
      return i = {}, i.TOKEN = "aaddcfa38b26e65330108190dd642a79f2ce04b738a68077dd28f15eb81d9f237ccbdea9b982a9d1ef09ecbb7eb5d67b463a96a36390aaf9325db2d93cf52a0z", i.SERVER = "https://api.addressfinder.io", i.AU_BROCHURE = "https://addressfinder.com.au", i.NZ_BROCHURE = "https://addressfinder.nz", i.CSS = "/assets/v3.css", i.VERSION = "10.4.0", i.WIDGET_VERSION = "3.7.0", i.KEYPRESS_INTERVAL = 400, i.MIN_SEARCH_CHARS = 3, i.MAX_QUERY_TIME = 3e3, i.objParams = function(e) {
        var t, s, r;
        return s = function() {
          var s;
          s = [];
          for (t in e) r = e[t], s.push(t + "=" + r);
          return s
        }(), s.join("&")
      }, i.Widget = function(s) {
        function n(t, s, o, a) {
          var l;
          this.element = t, this.api_key = s, this.country_code = o, this.options = null != a ? a : {}, this.addServices = e(this.addServices, this), this.checkSuppliedParameters = e(this.checkSuppliedParameters, this), this.setOption = e(this.setOption, this), this.checkSuppliedParameters() && (n.__super__.constructor.call(this, this.element, this.options), this.paid = !0, this.reqwest = r, this.options.manual_style || this._addCSS(), this._applyStyle("position", this.options.position), this.country = new i.Country(this.country_code), (l = this.options).empty_content || (l.empty_content = "No addresses were found. This could be a new address, or you may need to check the spelling. <a target='_blank' alt='Missing Addresses Documentation' href=" + this.country.brochureUrl() + "/docs/missing_addresses>Learn more</a>"), null == this.options.address_params.highlight && (this.options.address_params.highlight = 1), null == this.options.location_params.highlight && (this.options.location_params.highlight = 1), null == this.options.points_of_interest_params.highlight && (this.options.points_of_interest_params.highlight = 1), this.country.is_nz && null == this.options.address_params.strict && (this.options.address_params.strict = 2), this.sessionID = this.generateSessionID(), this.addServices())
        }
        return t(n, s), n.prototype.defaults = {
          max_results: 10,
          list_class: "af_list",
          item_class: "af_item",
          hover_class: "af_hover",
          footer_class: "af_footer",
          empty_class: "af_empty",
          error_class: "af_error",
          manual_style: !1,
          show_addresses: !0,
          show_locations: !1,
          position: "absolute",
          ignore_returns: !0,
          byline: !0,
          canonical: !0,
          timeout: i.KEYPRESS_INTERVAL,
          address_params: {},
          location_params: {},
          points_of_interest_params: {},
          allow_null_suburb: !0,
          demo: !1
        }, n.prototype.setOption = function(e, t) {
          return "address_params" === e || "location_params" === e ? this.options[e] = this._extend(this.getOption(e), t) : n.__super__.setOption.apply(this, arguments)
        }, n.prototype.generateSessionID = function() {
          var e, t, s, r, n, i;
          for (i = [], n = 0; n < 256;) i[n] = (n < 16 ? "0" : "") + n.toString(16), n++;
          return e = 4294967295 * Math.random() | 0, t = 4294967295 * Math.random() | 0, s = 4294967295 * Math.random() | 0, r = 4294967295 * Math.random() | 0, i[255 & e] + i[e >> 8 & 255] + i[e >> 16 & 255] + i[e >> 24 & 255] + "-" + i[255 & t] + i[t >> 8 & 255] + "-" + i[t >> 16 & 15 | 64] + i[t >> 24 & 255] + "-" + i[63 & s | 128] + i[s >> 8 & 255] + "-" + i[s >> 16 & 255] + i[s >> 24 & 255] + i[255 & r] + i[r >> 8 & 255] + i[r >> 16 & 255] + i[r >> 24 & 255]
        }, n.prototype.checkSuppliedParameters = function() {
          var e;
          return this.element ? this.api_key ? this.country_code ? "AU" !== (e = this.country_code) && "au" !== e && "NZ" !== e && "nz" !== e ? (this.logError("Parameter country_code contains an invalid value. Check your call to the AddressFinder.Widget constructor."), !1) : !("container" in this.options && !this.options.container) || (this.logError("Option 'container' was supplied, but the value is null. Check your call to the AddressFinder.Widget constructor."), !1) : (this.logError("Parameter country_code was null. Check your call to the AddressFinder.Widget constructor."), !1) : (this.logError("Parameter api_key was null. Check your call to the AddressFinder.Widget constructor."), !1) : (this.logError("Input element was null. Check your call to the AddressFinder.Widget constructor."), !1)
        }, n.prototype.addServices = function() {
          if (this.options.show_addresses && this.services.push(this.country.createAddressService(this, {})), this.options.show_locations && this.services.push(this.country.createLocationService(this, {})), this.options.show_points_of_interest) return this.services.push(this.country.createPointsOfInterestService(this, {}))
        }, n.prototype.logError = function(e) {
          return "undefined" != typeof console && null !== console ? console.error(e) : void 0
        }, n.prototype.addService = function(e, t, s) {
          var r;
          return null == s && (s = {}), this.services.push(r = new i.Service(this, e, t, s)), r
        }, n.prototype.showResults = function() {
          var e;
          return (e = this.options).footer_content || (e.footer_content = ""), n.__super__.showResults.apply(this, arguments)
        }, n.prototype._extend = function(e, t) {
          var s;
          for (s in e) t.hasOwnProperty(s) || (t[s] = e[s]);
          return t
        }, n.prototype._addCSS = function() {
          var e;
          return e = document.createElement("link"), e.type = "text/css", e.rel = "stylesheet", e.href = i.SERVER + i.CSS, e.media = "screen", null != document.createStyleSheet ? document.createStyleSheet(i.SERVER + i.CSS) : document.getElementsByTagName("head")[0].appendChild(e)
        }, n.prototype._renderFooter = function() {
          var e;
          return this.demo ? (e = this._renderItem("You are using the <strong style='display:block'> <a href='" + this.country.brochureUrl() + "' target='_blank' style='color:rgb(40,108,141) !important;text-decoration:none !important'>AddressFinder</a> demo key </strong> <a href='" + this.country.signupUrl() + "' target='_blank' style='display:block;margin:10px auto 0;background-color:#cf6d66;color:#fff !important;text-transform:uppercase;text-decoration:none !important;padding:15px 8px;max-width:200px;-webkit-border-radius:5px;border-radius:5px'> Get a free license key </a>"), e.style.cssText = "background-color: #F0F0F0; padding: 15px; text-align: center;font-family:sans-serif;line-height:1.4;min-width:250px;display:block !important;visibility: visible !important; opacity: 1 !important; height: auto !important;", e) : this.paid && this.options.footer_content ? this._renderItem(this.options.footer_content, this.options.footer_class) : !this.paid || this.options.byline ? (e = this._renderItem("powered by <a href='" + this.country.brochureUrl() + "?utm_source=widget&utm_medium=widget&utm_campaign=widget' target='_blank' >AddressFinder</a>", this.options.footer_class), e.style.cssText = "display: block !important; visibility: visible !important; opacity: 1 !important; height: auto !important;", e) : ""
        }, n
      }(n.Widget), i.Service = function(e) {
        function s() {
          return s.__super__.constructor.apply(this, arguments)
        }
        return t(s, e), s
      }(n.Service), i.Country = function() {
        function t(t) {
          this.createPointsOfInterestService = e(this.createPointsOfInterestService, this), this.createLocationService = e(this.createLocationService, this), this.createAddressService = e(this.createAddressService, this), this.id_attribute = e(this.id_attribute, this), this.namespace = e(this.namespace, this), this.is_nz = e(this.is_nz, this), this.is_valid = e(this.is_valid, this), this.country_code = t.toLowerCase()
        }
        return t.prototype.is_valid = function() {
          var e;
          return "au" === (e = this.country_code) || "nz" === e
        }, t.prototype.is_nz = function() {
          return "nz" === this.country_code
        }, t.prototype.namespace = function() {
          switch (this.country_code) {
            case "au":
              return "api/au";
            case "nz":
              return "api/nz"
          }
        }, t.prototype.id_attribute = function() {
          switch (this.country_code) {
            case "au":
              return "id";
            case "nz":
              return "pxid"
          }
        }, t.prototype.createAddressService = function(e, t) {
          switch (this.country_code) {
            case "au":
              return new i._AUAddressService(e, t);
            case "nz":
              return new i._NZAddressService(e, t)
          }
        }, t.prototype.createLocationService = function(e, t) {
          switch (this.country_code) {
            case "nz":
              return new i._NZLocationService(e, t);
            case "au":
              return new i._AULocationService(e, t)
          }
        }, t.prototype.createPointsOfInterestService = function(e, t) {
          switch (this.country_code) {
            case "nz":
              return new i._NZPointsOfInterestService(e, t)
          }
        }, t.prototype.brochureUrl = function() {
          switch (this.country_code) {
            case "au":
              return i.AU_BROCHURE;
            case "nz":
              return i.NZ_BROCHURE
          }
        }, t.prototype.signupUrl = function() {
          return "https://portal.addressfinder.io/signup/" + this.country_code + "/free1"
        }, t
      }(), i._AFService = function(s) {
        function r(t, s) {
          this.widget = t, this.options = null != s ? s : {}, this.searchSuccess = e(this.searchSuccess, this), this._unlockSearchRequests = e(this._unlockSearchRequests, this), this._lockSearchRequests = e(this._lockSearchRequests, this), this.ready = e(this.ready, this), this.results = [], this._ready = !0, this._resume_requests_timer = null
        }
        return t(r, s), r.prototype.ready = function() {
          return this._ready
        }, r.prototype._lockSearchRequests = function() {
          return this._ready = !1, this._resume_requests_timer = setTimeout(function(e) {
            return function() {
              return e._ready = !0
            }
          }(this), i.MAX_QUERY_TIME)
        }, r.prototype._unlockSearchRequests = function() {
          return null != this._resume_requests_timer && clearTimeout(this._resume_requests_timer), this._ready = !0
        }, r.prototype.search = function(e) {
          var t;
          if (e.length >= i.MIN_SEARCH_CHARS) return this.widget.error = null, this.last_query = e, this._lockSearchRequests(), t = i.objParams({
            q: encodeURIComponent(e),
            key: this.widget.api_key,
            widget_token: i.TOKEN,
            format: "json",
            max: this.widget.options.max_results,
            wv: i.WIDGET_VERSION,
            session: this.widget.sessionID
          }), this.extraParams() && (t += "&" + this.extraParams()), this.widget.reqwest({
            url: this.baseURL + "?" + t,
            type: "jsonp",
            jsonpCallback: "callback",
            success: this.searchSuccess
          })
        }, r.prototype.searchSuccess = function(e) {
          var t, s, r, n, i, o;
          for (this.results = [], n = e.completions.slice(0, +this.widget.options.max_results + 1 || 9e9), t = s = 0, r = n.length; s < r; t = ++s) i = n[t], o = this.widget.options.max_results - t + this.sort_value, this.results.push(this.createResult(this, {
            value: i[this.fullAddressAttribute],
            score: o,
            data: i
          }));
          return this.widget.paid = e.paid, this.widget.demo = e.demo, null != e.error_code && (this.widget.error_content = "Error: <a href='" + this.widget.country.brochureUrl() + "/docs/api_errors#error_" + e.error_code + "' target='_blank'>" + e.message + "</a>"), this._unlockSearchRequests(), this.widget.showResults()
        }, r
      }(n.Dispatch), i._Result = function(s) {
        function r() {
          return this.selectItemSuccess = e(this.selectItemSuccess, this), this.selectItem = e(this.selectItem, this), this.record_id = e(this.record_id, this), r.__super__.constructor.apply(this, arguments)
        }
        return t(r, s), r.prototype.record_id = function() {
          return this.data[this.service.identifierAttribute]
        }, r.prototype.selectItem = function() {
          var e;
          if (null != this.data && null != this.data[this.service.identifierAttribute] && !this.widget.info_loading) return this.widget.info_loading = !0, this.populateValue(), this.service.trigger("result:select:pre", this.value, this.data), e = {
            widget_token: i.TOKEN,
            format: "json",
            key: this.widget.api_key,
            wv: i.WIDGET_VERSION,
            session: this.widget.sessionID
          }, e[this.service.identifierAttribute] = this.record_id(), this.widget.reqwest({
            url: this.service.baseURL + "/info",
            data: e,
            type: "jsonp",
            jsonpCallback: "callback",
            success: this.selectItemSuccess
          })
        }, r.prototype.selectItemSuccess = function(e) {
          return this.data = e, this.service.trigger("result:select", this.value, this.data), this.widget.highlighted = this, this.widget.selectHighlighted(), this.widget.info_loading = !1, this.widget.highlighted = null
        }, r
      }(n._Result), i.HighlightSearchTerms = function() {
        function t(t, s) {
          this.fullAddress = t, this.queryString = s, this.format = e(this.format, this), this.applyMask = e(this.applyMask, this), this.populateMask = e(this.populateMask, this), this.queryElements = e(this.queryElements, this)
        }
        return t.prototype.queryElements = function() {
          return this.queryString.match(/[a-z0-9]+/gi)
        }, t.prototype.populateMask = function() {
          var e, t, s, r, n, i, o, a, l, u;
          for (this.highlightMask = Array(this.fullAddress.length), o = this.queryElements(), s = 0, n = o.length; s < n; s++)
            for (e = o[s], u = new RegExp(e, "ig"); null !== (i = u.exec(this.fullAddress));)
              for (t = r = a = i.index, l = i.index + e.length; a <= l ? r < l : r > l; t = a <= l ? ++r : --r) this.highlightMask[t] = !0;
          return this.highlightMask
        }, t.prototype.applyMask = function() {
          var e, t, s, r, n;
          for (this.highlightedAddress = "", t = !1, s = r = 0, n = this.fullAddress.length; 0 <= n ? r < n : r > n; s = 0 <= n ? ++r : --r) e = this.fullAddress.charAt(s), this.highlightMask[s] ? t ? this.highlightedAddress += e : (t = !0, this.highlightedAddress += '<span class="af_hl">' + e) : t ? (t = !1, this.highlightedAddress += "</span>" + e) : this.highlightedAddress += e;
          if (t) return this.highlightedAddress += "</span>"
        }, t.prototype.format = function() {
          return this.populateMask(), this.applyMask(), this.highlightedAddress
        }, t
      }(), i._NZAddressService = function(s) {
        function r(t, s) {
          null == s && (s = {}), this.createResult = e(this.createResult, this), this.highlightRenderer = e(this.highlightRenderer, this), r.__super__.constructor.call(this, t, s), this.on("result:select:pre", function(e) {
            return function(t, s) {
              return e.widget.trigger("address:select:pre", t, s)
            }
          }(this)), this.on("result:select", function(e) {
            return function(t, s) {
              return e.widget.trigger("address:select", t, s)
            }
          }(this)), "1" !== this.widget.getOption("address_params").highlight && 1 !== this.widget.getOption("address_params").highlight || (this.options.renderer = this.highlightRenderer)
        }
        return t(r, s), r.prototype.search_type = "address", r.prototype.sort_value = -1e3, r.prototype.baseURL = i.SERVER + "/api/nz/address",
          r.prototype.identifierAttribute = "pxid", r.prototype.fullAddressAttribute = "a", r.prototype.highlightRenderer = function(e, t) {
            return t.highlighted_a
          }, r.prototype.extraParams = function() {
            if (null != this.widget.getOption("address_params")) return i.objParams(this.widget.getOption("address_params"))
          }, r.prototype.createResult = function(e, t) {
            return new i._NZAddressResult(e, t)
          }, r
      }(i._AFService), i._NZAddressResult = function(s) {
        function r() {
          return this.selectItemSuccess = e(this.selectItemSuccess, this), this.populateValue = e(this.populateValue, this), r.__super__.constructor.apply(this, arguments)
        }
        return t(r, s), r.prototype.populateValue = function() {
          return this.value = this.data.a
        }, r.prototype.selectItemSuccess = function(e) {
          return this.widget.getOption("allow_null_suburb") && e.city === e.suburb && (e.suburb = null), r.__super__.selectItemSuccess.apply(this, arguments)
        }, r
      }(i._Result), i._NZLocationService = function(s) {
        function r(t, s) {
          null == s && (s = {}), this.createResult = e(this.createResult, this), this.highlightRenderer = e(this.highlightRenderer, this), r.__super__.constructor.call(this, t, s), this.on("result:select:pre", function(e) {
            return function(t, s) {
              return e.widget.trigger("location:select:pre", t, s)
            }
          }(this)), this.on("result:select", function(e) {
            return function(t, s) {
              return e.widget.trigger("location:select", t, s)
            }
          }(this)), "1" !== this.widget.getOption("location_params").highlight && 1 !== this.widget.getOption("location_params").highlight || (this.options.renderer = this.highlightRenderer)
        }
        return t(r, s), r.prototype.search_type = "location", r.prototype.sort_value = -100, r.prototype.baseURL = i.SERVER + "/api/nz/location", r.prototype.identifierAttribute = "pxid", r.prototype.fullAddressAttribute = "a", r.prototype.highlightRenderer = function(e, t) {
          return void 0 === t.highlighted_a ? new i.HighlightSearchTerms(e, this.last_query).format() : t.highlighted_a
        }, r.prototype.extraParams = function() {
          if (null != this.widget.getOption("location_params")) return i.objParams(this.widget.getOption("location_params"))
        }, r.prototype.createResult = function(e, t) {
          return new i._NZLocationResult(e, t)
        }, r
      }(i._AFService), i._NZLocationResult = function(s) {
        function r() {
          return this.populateValue = e(this.populateValue, this), r.__super__.constructor.apply(this, arguments)
        }
        return t(r, s), r.prototype.populateValue = function() {
          return this.value = this.data.a
        }, r
      }(i._Result), i._NZPointsOfInterestService = function(s) {
        function r(t, s) {
          null == s && (s = {}), this.createResult = e(this.createResult, this), this.highlightRenderer = e(this.highlightRenderer, this), r.__super__.constructor.call(this, t, s), this.on("result:select:pre", function(e) {
            return function(t, s) {
              return e.widget.trigger("points_of_interest:select:pre", t, s)
            }
          }(this)), this.on("result:select", function(e) {
            return function(t, s) {
              return e.widget.trigger("points_of_interest:select", t, s)
            }
          }(this)), "1" !== this.widget.getOption("points_of_interest_params").highlight && 1 !== this.widget.getOption("points_of_interest_params").highlight || (this.options.renderer = this.highlightRenderer)
        }
        return t(r, s), r.prototype.search_type = "points_of_interest", r.prototype.sort_value = -10, r.prototype.baseURL = i.SERVER + "/api/nz/points_of_interest", r.prototype.identifierAttribute = "id", r.prototype.fullAddressAttribute = "name_and_address", r.prototype.highlightRenderer = function(e, t) {
          return t.highlighted_name_and_address
        }, r.prototype.extraParams = function() {
          if (null != this.widget.getOption("points_of_interest_params")) return i.objParams(this.widget.getOption("points_of_interest_params"))
        }, r.prototype.createResult = function(e, t) {
          return new i._NZPointsOfInterestResult(e, t)
        }, r
      }(i._AFService), i._NZPointsOfInterestResult = function(s) {
        function r() {
          return this.populateValue = e(this.populateValue, this), r.__super__.constructor.apply(this, arguments)
        }
        return t(r, s), r.prototype.populateValue = function() {
          return this.value = this.data.name_and_address
        }, r
      }(i._Result), i._AUAddressService = function(s) {
        function r(t, s) {
          null == s && (s = {}), this.createResult = e(this.createResult, this), this.highlightRenderer = e(this.highlightRenderer, this), r.__super__.constructor.call(this, t, s), "1" !== this.widget.getOption("address_params").highlight && 1 !== this.widget.getOption("address_params").highlight || (this.options.renderer = this.highlightRenderer), this.on("result:select:pre", function(e) {
            return function(t, s) {
              return e.widget.trigger("address:select:pre", t, s)
            }
          }(this)), this.on("result:select", function(e) {
            return function(t, s) {
              return e.widget.trigger("address:select", t, s)
            }
          }(this))
        }
        return t(r, s), r.prototype.search_type = "address", r.prototype.sort_value = -1e3, r.prototype.baseURL = i.SERVER + "/api/au/address", r.prototype.identifierAttribute = "id", r.prototype.fullAddressAttribute = "full_address", r.prototype.highlightRenderer = function(e, t) {
          return t.highlighted_full_address
        }, r.prototype.extraParams = function() {
          if (null != this.widget.getOption("address_params")) return i.objParams(this.widget.getOption("address_params"))
        }, r.prototype.createResult = function(e, t) {
          return new i._AUAddressResult(e, t)
        }, r
      }(i._AFService), i._AULocationService = function(s) {
        function r(t, s) {
          null == s && (s = {}), this.createResult = e(this.createResult, this), this.highlightRenderer = e(this.highlightRenderer, this), r.__super__.constructor.call(this, t, s), "1" !== this.widget.getOption("location_params").highlight && 1 !== this.widget.getOption("location_params").highlight || (this.options.renderer = this.highlightRenderer), this.on("result:select:pre", function(e) {
            return function(t, s) {
              return e.widget.trigger("location:select:pre", t, s)
            }
          }(this)), this.on("result:select", function(e) {
            return function(t, s) {
              return e.widget.trigger("location:select", t, s)
            }
          }(this))
        }
        return t(r, s), r.prototype.search_type = "location", r.prototype.sort_value = -100, r.prototype.baseURL = i.SERVER + "/api/au/location", r.prototype.identifierAttribute = "id", r.prototype.fullAddressAttribute = "full_location", r.prototype.highlightRenderer = function(e, t) {
          return t.highlighted_full_location
        }, r.prototype.extraParams = function() {
          if (null != this.widget.getOption("location_params")) return i.objParams(this.widget.getOption("location_params"))
        }, r.prototype.createResult = function(e, t) {
          return new i._AULocationResult(e, t)
        }, r
      }(i._AFService), i._AULocationResult = function(s) {
        function r() {
          return this.selectItemSuccess = e(this.selectItemSuccess, this), this.populateValue = e(this.populateValue, this), this.record_id = e(this.record_id, this), r.__super__.constructor.apply(this, arguments)
        }
        return t(r, s), r.prototype.record_id = function() {
          return this.widget.getOption("canonical") ? this.data.canonical_location_id : this.data.id
        }, r.prototype.populateValue = function() {
          return this.value = this.data.full_location
        }, r.prototype.selectItemSuccess = function(e) {
          return this.value = e.full_location, r.__super__.selectItemSuccess.apply(this, arguments)
        }, r
      }(i._Result), i._AUAddressResult = function(s) {
        function r() {
          return this.selectItemSuccess = e(this.selectItemSuccess, this), this.populateValue = e(this.populateValue, this), this.record_id = e(this.record_id, this), r.__super__.constructor.apply(this, arguments)
        }
        return t(r, s), r.prototype.record_id = function() {
          return this.widget.getOption("canonical") ? this.data.canonical_address_id : this.data.id
        }, r.prototype.populateValue = function() {
          return this.value = this.data.full_address
        }, r.prototype.selectItemSuccess = function(e) {
          return this.value = e.full_address, r.__super__.selectItemSuccess.apply(this, arguments)
        }, r
      }(i._Result), i.NZSelectedAddress = function() {
        function t(t, s) {
          this.fullAddress = t, this.metaData = s, this._is_postal_address = e(this._is_postal_address, this), this._removeCitySuburbAddressLines = e(this._removeCitySuburbAddressLines, this), this._splitAddress = e(this._splitAddress, this), this.address_line_1_and_2 = e(this.address_line_1_and_2, this), this.address_line_1 = e(this.address_line_1, this), this.address_line_2 = e(this.address_line_2, this), this.suburb = e(this.suburb, this), this.postcode = e(this.postcode, this), this.city = e(this.city, this), this.selectedAddress = this.fullAddress, this.originalAddressLines = this._splitAddress(), this.address_lines = this.originalAddressLines.slice(), this._removeCitySuburbAddressLines()
        }
        return t.prototype.city = function() {
          return this._is_postal_address() ? this.metaData.mailtown || this.metaData.city : this.metaData.city
        }, t.prototype.postcode = function() {
          return this.metaData.postcode
        }, t.prototype.suburb = function() {
          var e;
          return e = this.metaData.post_suburb || this.metaData.suburb, this.originalAddressLines[this.originalAddressLines.length - 2] === e ? this.metaData.post_suburb || this.metaData.suburb : ""
        }, t.prototype.address_line_2 = function() {
          return this.address_lines.length > 1 ? this.address_lines[this.address_lines.length - 1] : ""
        }, t.prototype.address_line_1 = function() {
          var e;
          return e = this.address_lines.length > 1 ? this.address_lines.slice(0, this.address_lines.length - 1) : this.address_lines.slice(0, this.address_lines.length), e.join(", ")
        }, t.prototype.address_line_1_and_2 = function() {
          return "" === this.address_line_2() ? this.address_line_1() : [this.address_line_1(), this.address_line_2()].join(", ")
        }, t.prototype._splitAddress = function() {
          var e, t, s, r, n, i;
          for (i = this.selectedAddress.split(","), n = [], e = s = 0, r = i.length; s < r; e = ++s) t = i[e], n.push(i[e] = i[e].replace(/^\s+|\s+$/g, ""));
          return n
        }, t.prototype._removeCitySuburbAddressLines = function() {
          if (this.address_lines[this.address_lines.length - 1] === this.city() + " " + this.postcode() && this.address_lines.pop(), this.address_lines[this.address_lines.length - 1] === this.metaData.suburb) return this.address_lines.pop()
        }, t.prototype._is_postal_address = function() {
          return this.fullAddress === this.metaData.postal
        }, t
      }(), i
    })
  }.call(this),
  function() {}.call(this);