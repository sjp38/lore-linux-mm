Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9AED76B0038
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 12:47:51 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id 73so218385215otj.1
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 09:47:51 -0800 (PST)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0138.outbound.protection.outlook.com. [104.47.42.138])
        by mx.google.com with ESMTPS id w83si2292638oib.247.2017.01.27.09.47.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 Jan 2017 09:47:50 -0800 (PST)
From: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Subject: Re: [PATCH 2/2] base/memory, hotplug: fix a kernel oops in
 show_valid_zones()
Date: Fri, 27 Jan 2017 17:47:49 +0000
Message-ID: <1485542594.2029.30.camel@hpe.com>
References: <20170126214415.4509-1-toshi.kani@hpe.com>
	 <20170126214415.4509-3-toshi.kani@hpe.com>
	 <20170126135254.cbd0bdbe3cdc5910c288ad32@linux-foundation.org>
	 <1485472910.2029.28.camel@hpe.com> <20170127074854.GA31443@kroah.com>
In-Reply-To: <20170127074854.GA31443@kroah.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <DBE5EA41D7C82D40A76C78625515EEE3@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Cc: "zhenzhang.zhang@huawei.com" <zhenzhang.zhang@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "arbab@linux.vnet.ibm.com" <arbab@linux.vnet.ibm.com>, "abanman@sgi.com" <abanman@sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rientjes@google.com" <rientjes@google.com>

T24gRnJpLCAyMDE3LTAxLTI3IGF0IDA4OjQ4ICswMTAwLCBncmVna2hAbGludXhmb3VuZGF0aW9u
Lm9yZyB3cm90ZToNCj4gT24gVGh1LCBKYW4gMjYsIDIwMTcgYXQgMTA6MjY6MjNQTSArMDAwMCwg
S2FuaSwgVG9zaGltaXRzdSB3cm90ZToNCj4gPiBPbiBUaHUsIDIwMTctMDEtMjYgYXQgMTM6NTIg
LTA4MDAsIEFuZHJldyBNb3J0b24gd3JvdGU6DQo+ID4gPiBPbiBUaHUsIDI2IEphbiAyMDE3IDE0
OjQ0OjE1IC0wNzAwIFRvc2hpIEthbmkgPHRvc2hpLmthbmlAaHBlLmNvbQ0KPiA+ID4gPg0KPiA+
ID4gd3JvdGU6DQo+ID4gPiANCj4gPiA+ID4gUmVhZGluZyBhIHN5c2ZzIG1lbW9yeU4vdmFsaWRf
em9uZXMgZmlsZSBsZWFkcyB0byB0aGUgZm9sbG93aW5nDQo+ID4gPiA+IG9vcHMgd2hlbiB0aGUg
Zmlyc3QgcGFnZSBvZiBhIHJhbmdlIGlzIG5vdCBiYWNrZWQgYnkgc3RydWN0DQo+ID4gPiA+IHBh
Z2UuIHNob3dfdmFsaWRfem9uZXMoKSBhc3N1bWVzIHRoYXQgJ3N0YXJ0X3BmbicgaXMgYWx3YXlz
DQo+ID4gPiA+IHZhbGlkIGZvciBwYWdlX3pvbmUoKS4NCj4gPiA+ID4gDQo+ID4gPiA+IMKgQlVH
OiB1bmFibGUgdG8gaGFuZGxlIGtlcm5lbCBwYWdpbmcgcmVxdWVzdCBhdA0KPiA+ID4gPiBmZmZm
ZWEwMTdhMDAwMDAwDQo+ID4gPiA+IMKgSVA6IHNob3dfdmFsaWRfem9uZXMrMHg2Zi8weDE2MA0K
PiA+ID4gPiANCj4gPiA+ID4gU2luY2UgdGVzdF9wYWdlc19pbl9hX3pvbmUoKSBhbHJlYWR5IGNo
ZWNrcyBob2xlcywgZXh0ZW5kIHRoaXMNCj4gPiA+ID4gZnVuY3Rpb24gdG8gcmV0dXJuICd2YWxp
ZF9zdGFydCcgYW5kICd2YWxpZF9lbmQnIGZvciBhIGdpdmVuDQo+ID4gPiA+IHJhbmdlLiBzaG93
X3ZhbGlkX3pvbmVzKCkgdGhlbiBwcm9jZWVkcyB3aXRoIHRoZSB2YWxpZCByYW5nZS4NCj4gPiA+
IA0KPiA+ID4gVGhpcyBkb2Vzbid0IGFwcGx5IHRvIGN1cnJlbnQgbWFpbmxpbmUgZHVlIHRvIGNo
YW5nZXMgaW4NCj4gPiA+IHpvbmVfY2FuX3NoaWZ0KCkuwqDCoFBsZWFzZSByZWRvIGFuZCByZXNl
bmQuDQo+ID4gDQo+ID4gU29ycnksIEkgd2lsbCByZWJhc2UgdG8gdGhlIC1tbSB0cmVlIGFuZCBy
ZXNlbmQgdGhlIHBhdGNoZXMuDQo+ID4gDQo+ID4gPiBQbGVhc2UgYWxzbyB1cGRhdGUgdGhlIGNo
YW5nZWxvZyB0byBwcm92aWRlIHN1ZmZpY2llbnQNCj4gPiA+IGluZm9ybWF0aW9uIGZvciBvdGhl
cnMgdG8gZGVjaWRlIHdoaWNoIGtlcm5lbChzKSBuZWVkIHRoZQ0KPiA+ID4gZml4LsKgwqBJbiBw
YXJ0aWN1bGFyOiB1bmRlciB3aGF0IGNpcmN1bXN0YW5jZXMgd2lsbCBpdCBvY2N1cj/CoMKgT24N
Cj4gPiA+IHJlYWwgbWFjaGluZXMgd2hpY2ggcmVhbCBwZW9wbGUgb3duPw0KPiA+IA0KPiA+IFll
cywgdGhpcyBpc3N1ZSBoYXBwZW5zIG9uIHJlYWwgeDg2IG1hY2hpbmVzIHdpdGggNjRHaUIgb3Ig
bW9yZQ0KPiA+IG1lbW9yeS4gwqBPbiBzdWNoIHN5c3RlbXMsIHRoZSBtZW1vcnkgYmxvY2sgc2l6
ZSBpcyBidW1wZWQgdXAgdG8NCj4gPiAyR2lCLiBbMV0NCj4gPiANCj4gPiBIZXJlIGlzIGFuIGV4
YW1wbGUgc3lzdGVtLsKgwqAweDMyNDAwMDAwMDAgaXMgb25seSBhbGlnbmVkIGJ5IDFHaUINCj4g
PiBhbmQgaXRzIG1lbW9yeSBibG9jayBzdGFydHMgZnJvbSAweDMyMDAwMDAwMDAsIHdoaWNoIGlz
IG5vdCBiYWNrZWQNCj4gPiBieSBzdHJ1Y3QgcGFnZS4NCj4gPiANCj4gPiDCoEJJT1MtZTgyMDog
W21lbcKgMHgwMDAwMDAzMjQwMDAwMDAwLTB4MDAwMDAwNjAzZmZmZmZmZl0gdXNhYmxlDQo+ID4g
DQo+ID4gSSB3aWxsIGFkZCB0aGUgZGVzY3JpcHRpb25zIHRvIHRoZSBwYXRjaC4NCj4gDQo+IFNo
b3VsZCBpdCBhbHNvIGJlIGJhY2twb3J0ZWQgdG8gdGhlIHN0YWJsZSBrZXJuZWxzIHRvIHJlc29s
dmUgdGhlDQo+IGlzc3VlIHRoZXJlPw0KDQpZZXMsIGl0IHNob3VsZCBiZSBiYWNrcG9ydGVkIHRv
IHRoZSBzdGFibGUga2VybmVscy4gIFRoZSBtZW1vcnkgYmxvY2sNCnNpemUgY2hhbmdlIHdhcyBt
YWRlIGJ5IGNvbW1pdCBiZGVlMjM3YzAzNCwgd2hpY2ggd2FzIGFjY2VwdGVkIHRvIDMuOS4gDQpI
b3dldmVyLCB0aGlzIHBhdGNoLXNldCBkZXBlbmRzIG9uIChhbmQgZml4ZXMpIHRoZSBjaGFuZ2Ug
dG8NCnRlc3RfcGFnZXNfaW5fYV96b25lKCkgbWFkZSBieSBjb21taXQgNWYwZjI4ODdmNCwgd2hp
Y2ggd2FzIGFjY2VwdGVkIHRvDQo0LjQuICBTbywgaW4gdGhlIGN1cnJlbnQgZm9ybSwgSSdkIHJl
Y29tbWVuZCB3ZSBiYWNrcG9ydCBpdCB1cCB0byA0LjQuDQoNClRoYW5rcywNCi1Ub3NoaQ==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
