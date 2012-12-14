Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id B0AFD6B002B
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 15:17:35 -0500 (EST)
From: Satoru Moriya <satoru.moriya@hds.com>
Subject: RE: [patch 2/8] mm: vmscan: disregard swappiness shortly before
 going OOM
Date: Fri, 14 Dec 2012 20:17:27 +0000
Message-ID: <8631DC5930FA9E468F04F3FD3A5D007214AD7388@USINDEM103.corp.hds.com>
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org>
 <1355348620-9382-3-git-send-email-hannes@cmpxchg.org>
 <20121213103420.GW1009@suse.de> <20121213152959.GE21644@dhcp22.suse.cz>
 <20121213160521.GG21644@dhcp22.suse.cz>
 <8631DC5930FA9E468F04F3FD3A5D007214AD2FA2@USINDEM103.corp.hds.com>
 <20121214045030.GE6317@cmpxchg.org> <20121214083738.GA6898@dhcp22.suse.cz>
 <50CB493B.8000900@redhat.com>
In-Reply-To: <50CB493B.8000900@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

T24gMTIvMTQvMjAxMiAxMDo0MyBBTSwgUmlrIHZhbiBSaWVsIHdyb3RlOg0KPiBPbiAxMi8xNC8y
MDEyIDAzOjM3IEFNLCBNaWNoYWwgSG9ja28gd3JvdGU6DQo+IA0KPj4gSSBjYW4gYW5zd2VyIHRo
ZSBsYXRlci4gQmVjYXVzZSBtZW1zdyBjb21lcyB3aXRoIGl0cyBwcmljZSBhbmQgDQo+PiBzd2Fw
cGluZXNzIGlzIG11Y2ggY2hlYXBlci4gT24gdGhlIG90aGVyIGhhbmQgaXQgbWFrZXMgc2Vuc2Ug
dGhhdA0KPj4gc3dhcHBpbmVzcz09MCBkb2Vzbid0IHN3YXAgYXQgYWxsLiBPciBkbyB5b3UgdGhp
bmsgd2Ugc2hvdWxkIGdldCBiYWNrIA0KPj4gdG8gX2FsbW9zdF8gZG9lc24ndCBzd2FwIGF0IGFs
bD8NCj4gDQo+IHN3YXBwaW5lc3M9PTAgd2lsbCBzd2FwIGluIGVtZXJnZW5jaWVzLCBzcGVjaWZp
Y2FsbHkgd2hlbiB3ZSBoYXZlIA0KPiBhbG1vc3Qgbm8gcGFnZSBjYWNoZSBsZWZ0LCB3ZSB3aWxs
IHN0aWxsIHN3YXAgdGhpbmdzIG91dDoNCj4gDQo+ICAgICAgICAgaWYgKGdsb2JhbF9yZWNsYWlt
KHNjKSkgew0KPiAgICAgICAgICAgICAgICAgZnJlZSAgPSB6b25lX3BhZ2Vfc3RhdGUoem9uZSwg
TlJfRlJFRV9QQUdFUyk7DQo+ICAgICAgICAgICAgICAgICBpZiAodW5saWtlbHkoZmlsZSArIGZy
ZWUgPD0gaGlnaF93bWFya19wYWdlcyh6b25lKSkpIHsNCj4gICAgICAgICAgICAgICAgICAgICAg
ICAgLyoNCj4gICAgICAgICAgICAgICAgICAgICAgICAgICogSWYgd2UgaGF2ZSB2ZXJ5IGZldyBw
YWdlIGNhY2hlIHBhZ2VzLCBmb3JjZS1zY2FuDQo+ICAgICAgICAgICAgICAgICAgICAgICAgICAq
IGFub24gcGFnZXMuDQo+ICAgICAgICAgICAgICAgICAgICAgICAgICAqLw0KPiAgICAgICAgICAg
ICAgICAgICAgICAgICBmcmFjdGlvblswXSA9IDE7DQo+ICAgICAgICAgICAgICAgICAgICAgICAg
IGZyYWN0aW9uWzFdID0gMDsNCj4gICAgICAgICAgICAgICAgICAgICAgICAgZGVub21pbmF0b3Ig
PSAxOw0KPiAgICAgICAgICAgICAgICAgICAgICAgICBnb3RvIG91dDsNCj4gDQo+IFRoaXMgbWFr
ZXMgc2Vuc2UsIGJlY2F1c2UgcGVvcGxlIHdobyBzZXQgc3dhcHBpbmVzcz09MCBidXQgZG8gaGF2
ZSANCj4gc3dhcCBzcGFjZSBhdmFpbGFibGUgd291bGQgcHJvYmFibHkgcHJlZmVyIHNvbWUgZW1l
cmdlbmN5IHN3YXBwaW5nIA0KPiBvdmVyIGFuIE9PTSBraWxsLg0KDQpUaGlzIGJlaGF2aW9yIGlz
IHJlYXNvbmFibGUgZm9yIGdsb2JhbCByZWNsYWltIHRvIG1lLiBCdXQgd2hlbg0Kd2UgaGl0IHRo
aXMgY29uZGl0aW9uLCBpdCBtYXkgYmUgYmV0dGVyIHRvIHByaW50IHNvbWUgbWVzc2FnZXMNCnRv
IG5vdGlmeSB0aGUgdXNlciB3aG8gc2V0IHN3YXBwaW5lc3M9PTAgb2YgYW5vbiBwYWdlIHNjYW4u
DQoNClJlZ2FyZHMsDQpTYXRvcnUNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
