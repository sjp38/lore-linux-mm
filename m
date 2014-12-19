Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4FEF96B0038
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 01:55:27 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so621582pab.4
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 22:55:26 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id r11si13030454pdl.210.2014.12.18.22.55.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Dec 2014 22:55:25 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 19 Dec 2014 14:54:48 +0800
Subject: RE: [RFC] MADV_FREE doesn't work when doesn't have swap partition
Message-ID: <35FD53F367049845BC99AC72306C23D103EDAF89E152@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net>
 <CALYGNiOuBKz8shHSrFCp0BT5AV6XkNOCHj+LJedQQ-2YdZtM7w@mail.gmail.com>
 <35FD53F367049845BC99AC72306C23D103E688B313F2@CNBJMBX05.corpusers.net>
 <20141205143134.37139da2208c654a0d3cd942@linux-foundation.org>
 <35FD53F367049845BC99AC72306C23D103E688B313F4@CNBJMBX05.corpusers.net>
 <20141208114601.GA28846@node.dhcp.inet.fi>
 <35FD53F367049845BC99AC72306C23D103E688B313FB@CNBJMBX05.corpusers.net>
 <CALYGNiMEytHuND37f+hNdMKqCPzN0k_uha6CaeL_fyzrj-obNQ@mail.gmail.com>
 <35FD53F367049845BC99AC72306C23D103E688B31408@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103EDAF89E14C@CNBJMBX05.corpusers.net>
 <20141219010452.GC1538@bbox>
In-Reply-To: <20141219010452.GC1538@bbox>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>
Cc: 'Konstantin Khlebnikov' <koct9i@gmail.com>, "'Kirill A. Shutemov'" <kirill@shutemov.name>, 'Andrew Morton' <akpm@linux-foundation.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'n-horiguchi@ah.jp.nec.com'" <n-horiguchi@ah.jp.nec.com>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBNaW5jaGFuIEtpbSBbbWFpbHRv
Om1pbmNoYW5Aa2VybmVsLm9yZ10NCj4gU2VudDogRnJpZGF5LCBEZWNlbWJlciAxOSwgMjAxNCA5
OjA1IEFNDQo+IFRvOiBXYW5nLCBZYWxpbg0KPiBDYzogJ0tvbnN0YW50aW4gS2hsZWJuaWtvdic7
ICdLaXJpbGwgQS4gU2h1dGVtb3YnOyAnQW5kcmV3IE1vcnRvbic7ICdsaW51eC0NCj4ga2VybmVs
QHZnZXIua2VybmVsLm9yZyc7ICdsaW51eC1tbUBrdmFjay5vcmcnOyAnbGludXgtYXJtLQ0KPiBr
ZXJuZWxAbGlzdHMuaW5mcmFkZWFkLm9yZyc7ICduLWhvcmlndWNoaUBhaC5qcC5uZWMuY29tJw0K
PiBTdWJqZWN0OiBSZTogW1JGQ10gTUFEVl9GUkVFIGRvZXNuJ3Qgd29yayB3aGVuIGRvZXNuJ3Qg
aGF2ZSBzd2FwIHBhcnRpdGlvbg0KPiANCj4gT24gVGh1LCBEZWMgMTgsIDIwMTQgYXQgMTE6NTA6
MDFBTSArMDgwMCwgV2FuZywgWWFsaW4gd3JvdGU6DQo+ID4gSSBub3RpY2UgdGhpcyBjb21taXQ6
DQo+ID4gbW06IHN1cHBvcnQgbWFkdmlzZShNQURWX0ZSRUUpLA0KPiA+DQo+ID4gaXQgY2FuIGZy
ZWUgY2xlYW4gYW5vbnltb3VzIHBhZ2VzIGRpcmVjdGx5LCBkb2Vzbid0IG5lZWQgcGFnZW91dCB0
bw0KPiA+IHN3YXAgcGFydGl0aW9uLA0KPiA+DQo+ID4gYnV0IEkgZm91bmQgaXQgZG9lc24ndCB3
b3JrIG9uIG15IHBsYXRmb3JtLCB3aGljaCBkb24ndCBlbmFibGUgYW55DQo+ID4gc3dhcCBwYXJ0
aXRpb25zLg0KPiANCj4gQ3VycmVudCBpbXBsZW1lbnRhdGlvbiwgaWYgdGhlcmUgaXMgbm8gZW1w
dHkgc2xvdCBpbiBzd2FwLCBpdCBkb2VzIGluc3RhbnQNCj4gZnJlZSBpbnN0ZWFkIG9mIGRlbGF5
ZWQgZnJlZS4gTG9vayBhdCBtYWR2aXNlX3ZtYS4NCj4gDQo+ID4NCj4gPiBJIG1ha2UgYSBjaGFu
Z2UgZm9yIHRoaXMuDQo+ID4gSnVzdCB0byBleHBsYWluIG15IGlzc3VlIGNsZWFybHksDQo+ID4g
RG8gd2UgbmVlZCBzb21lIG90aGVyIGNoZWNrcyB0byBzdGlsbCBzY2FuIGFub255bW91cyBwYWdl
cyBldmVuIERvbid0DQo+ID4gaGF2ZSBzd2FwIHBhcnRpdGlvbiBidXQgaGF2ZSBjbGVhbiBhbm9u
eW1vdXMgcGFnZXM/DQo+IA0KPiBUaGVyZSBpcyBhIGZldyBwbGFjZXMgd2Ugc2hvdWxkIGNvbnNp
ZGVyIGlmIHlvdSB3YW50IHRvIHNjYW4gYW5vbnltb3VzIHBhZ2UNCj4gd2l0aG90dSBzd2FwLiBS
ZWZlciA2OWM4NTQ4MTc1NjYgYW5kIDc0ZTNmM2MzMzkxZC4NCj4gDQo+IEhvd2V2ZXIsIGl0J3Mg
bm90IHNpbXBsZSBhdCB0aGUgbW9tZW50LiBJZiB3ZSByZWVuYWJsZSBhbm9ueW1vdXMgc2Nhbg0K
PiB3aXRob3V0IHN3YXAsIGl0IHdvdWxkIG1ha2UgbXVjaCByZWdyZXNzIG9mIHJlY2xhaW0uIFNv
IG15IGRpcmVjdGlvbiBpcw0KPiBtb3ZlIG5vcm1hbCBhbm9ueW1vcyBwYWdlcyBpbnRvIHVuZXZp
Y3RhYmxlIExSVSBsaXN0IGJlY2F1c2UgdGhleSdyZSByZWFsDQo+IHVuZXZpY3RhYmxlIHdpdGhv
dXQgc3dhcCBhbmQgcHV0IGRlbGF5ZWQgZnJlZWluZyBwYWdlcyBpbnRvIGFub24gTFJVIGxpc3QN
Cj4gYW5kIGFnZSB0aGVtLg0KPiANCkkgdW5kZXJzdGFuZCB5b3VyIHNvbHV0aW9uLCBzb3VuZHMg
YSBncmVhdCBpZGVhIQ0KV2hlbiB0aGlzIGRlc2lnbiB3aWxsIGJlIG1lcmdlZCBpbnRvIG1haW4g
c3RyZWFtPw0KDQpUaGFua3MuDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
