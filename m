Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 56AD56B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 10:59:02 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j64so6799366pfj.6
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 07:59:02 -0700 (PDT)
Received: from relmlie1.idc.renesas.com (relmlor2.renesas.com. [210.160.252.172])
        by mx.google.com with ESMTP id u186si1548670pgc.823.2017.10.03.07.59.00
        for <linux-mm@kvack.org>;
        Tue, 03 Oct 2017 07:59:01 -0700 (PDT)
From: Chris Brandt <Chris.Brandt@renesas.com>
Subject: RE: [PATCH v4 1/5] cramfs: direct memory access support
Date: Tue, 3 Oct 2017 14:58:57 +0000
Message-ID: <SG2PR06MB1165AEAAF88684C9CDBB37738A720@SG2PR06MB1165.apcprd06.prod.outlook.com>
References: <20170927233224.31676-1-nicolas.pitre@linaro.org>
 <20170927233224.31676-2-nicolas.pitre@linaro.org>
 <20171001082955.GA17116@infradead.org>
 <CAL_JsqK1FhN7f55ZDinX+PKaO_e7m7bxCgBeHg=hzCRn+TSwSA@mail.gmail.com>
In-Reply-To: <CAL_JsqK1FhN7f55ZDinX+PKaO_e7m7bxCgBeHg=hzCRn+TSwSA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Herring <robh@kernel.org>, Christoph Hellwig <hch@infradead.org>
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-embedded@vger.kernel.org" <linux-embedded@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>

T24gVHVlc2RheSwgT2N0b2JlciAwMywgMjAxNyAxLCBSb2IgSGVycmluZyB3cm90ZToNCj4gT24g
U3VuLCBPY3QgMSwgMjAxNyBhdCAzOjI5IEFNLCBDaHJpc3RvcGggSGVsbHdpZyA8aGNoQGluZnJh
ZGVhZC5vcmc+DQo+IHdyb3RlOg0KPiA+IE9uIFdlZCwgU2VwIDI3LCAyMDE3IGF0IDA3OjMyOjIw
UE0gLTA0MDAsIE5pY29sYXMgUGl0cmUgd3JvdGU6DQo+ID4+IFRvIGRpc3Rpbmd1aXNoIGJldHdl
ZW4gYm90aCBhY2Nlc3MgdHlwZXMsIHRoZSBjcmFtZnNfcGh5c21lbSBmaWxlc3lzdGVtDQo+ID4+
IHR5cGUgbXVzdCBiZSBzcGVjaWZpZWQgd2hlbiB1c2luZyBhIG1lbW9yeSBhY2Nlc3NpYmxlIGNy
YW1mcyBpbWFnZSwgYW5kDQo+ID4+IHRoZSBwaHlzYWRkciBhcmd1bWVudCBtdXN0IHByb3ZpZGUg
dGhlIGFjdHVhbCBmaWxlc3lzdGVtIGltYWdlJ3MNCj4gcGh5c2ljYWwNCj4gPj4gbWVtb3J5IGxv
Y2F0aW9uLg0KPiA+DQo+ID4gU29ycnksIGJ1dCB0aGlzIHN0aWxsIGlzIGEgY29tcGxldGUgbm8t
Z28uICBBIHBoeXNpY2FsIGFkZHJlc3MgaXMgbm90IGENCj4gPiBwcm9wZXIgaW50ZXJmYWNlLiAg
WW91IHN0aWxsIG5lZWQgdG8gaGF2ZSBzb21lIGludGVyZmFjZSBmb3IgeW91ciBOT1INCj4gbmFu
ZA0KPiA+IG9yIERSQU0uICAtIHVzdWFsbHkgdGhhdCB3b3VsZCBiZSBhIG10ZCBkcml2ZXIsIGJ1
dCBpZiB5b3UgaGF2ZSBhIGdvb2QNCj4gPiByZWFzb24gd2h5IHRoYXQncyBub3Qgc3VpdGFibGUg
Zm9yIHlvdSAoYW5kIHBsZWFzZSBleHBsYWluIGl0IHdlbGwpDQo+ID4gd2UnbGwgbmVlZCBhIGxp
dHRsZSBPRiBvciBzaW1pbGFyIGxheWVyIHRvIGJpbmQgYSB0aGluIGRyaXZlci4NCj4gDQo+IEkg
ZG9uJ3QgZGlzYWdyZWUgdGhhdCB3ZSBtYXkgbmVlZCBEVCBiaW5kaW5nIGhlcmUsIGJ1dCBEVCBi
aW5kaW5ncyBhcmUNCj4gaC93IGRlc2NyaXB0aW9uIGFuZCBub3QgYSBtZWNoYW5pc20gYmluZCBM
aW51eCBrZXJuZWwgZHJpdmVycy4gSXQgY2FuDQo+IGJlIGEgc3VidGxlIGRpc3RpbmN0aW9uLCBi
dXQgaXQgaXMgYW4gaW1wb3J0YW50IG9uZS4NCj4gDQo+IEkgY2FuIHNlZSB0aGUgY2FzZSB3aGVy
ZSB3ZSBoYXZlIG5vIGRyaXZlci4gRm9yIFJBTSB3ZSBkb24ndCBoYXZlIGENCj4gZHJpdmVyLCB5
ZXQgcHJldHR5IG11Y2ggYWxsIGhhcmR3YXJlIGhhcyBhIERSQU0gY29udHJvbGxlciB3aGljaCB3
ZQ0KPiBqdXN0IHJlbHkgb24gdGhlIGZpcm13YXJlIHRvIHNldHVwLiBJIGNvdWxkIGFsc28gZW52
aXNpb24gdGhhdCB3ZSBoYXZlDQo+IGhhcmR3YXJlIHdlIGRvIG5lZWQgdG8gY29uZmlndXJlIGlu
IHRoZSBrZXJuZWwuIFBlcmhhcHMgdGhlIGJvb3QNCj4gc2V0dGluZ3MgYXJlIG5vdCBvcHRpbWFs
IG9yIHdlIHdhbnQvbmVlZCB0byBtYW5hZ2UgdGhlIGNsb2Nrcy4gVGhhdA0KPiBzZWVtcyBzb21l
d2hhdCB1bmxpa2VseSBpZiB0aGUga2VybmVsIGlzIGFsc28gWElQIGZyb20gdGhlIHNhbWUgZmxh
c2gNCj4gYXMgaXQgaXMgaW4gTmljbydzIGNhc2UuDQo+IA0KPiBXZSBkbyBvZnRlbiBkZXNjcmli
ZSB0aGUgZmxhc2ggbGF5b3V0IGluIERUIHdoZW4gcGFydGl0aW9ucyBhcmUgbm90DQo+IGRpc2Nv
dmVyYWJsZS4gSSBkb24ndCBrbm93IGlmIHRoYXQgd291bGQgYmUgbmVlZGVkIGhlcmUuIFdvdWxk
IHRoZSBST00NCj4gaGVyZSBldmVyIGJlIHVwZGF0ZWFibGUgZnJvbSB3aXRoaW4gTGludXg/IElm
IHdlJ3JlIHRhbGtpbmcgYWJvdXQgYQ0KPiBzaW5nbGUgYWRkcmVzcyB0byBwYXNzIHRoZSBrZXJu
ZWwsIERUIHNlZW1zIGxpa2UgYW4gb3ZlcmtpbGwgYW5kDQo+IGtlcm5lbCBjbWRsaW5lIGlzIHBl
cmZlY3RseSB2YWxpZCBJTU8uDQoNCg0KQXMgc29tZW9uZSB0aGF0J3MgYmVlbiB1c2luZyBhbiBY
SVAgRmlsZSBzeXN0ZW0gZm9yIGEgd2hpbGUgbm93IChBWEZTLCANCm9idmlvdXNseSBub3QgeGlw
LWNyYW1mcyksIHRoZXJlIGlzIGEgd2F5IChpbiBteSBzeXN0ZW0gYXQgbGVhc3QpIHRvIA0Kd3Jp
dGUgdG8gdGhlIHNhbWUgRmxhc2ggdGhhdCB0aGUga2VybmVsIGFuZCBmaWxlIHN5c3RlbSBhcmUg
Y3VycmVudGx5IFhJUCANCmV4ZWN1dGluZyAodGhpbmsganVtcGluZyB0byBSQU0sIGRvaW5nIGEg
c21hbGwgZmxhc2ggb3BlcmF0aW9uLCB0aGVuIA0KanVtcGluZyBiYWNrIHRvIEZsYXNoKS4NCg0K
VGhlIHVzZSBjYXNlIGlzIGlmIHlvdSd2ZSBsb2dpY2FsbHkgcGFydGl0aW9uZWQgeW91ciBmbGFz
aCBzdWNoIHRoYXQgeW91DQprZWVwIHlvdXIgYXBwbGljYXRpb24gaW4gYSBzZXBhcmF0ZSBmaWxl
IFhJUCBmaWxlc3lzdGVtIGltYWdlLCB5b3UgDQpyZW1vdGVseSBkb3dubG9hZCBhbiB1cGRhdGVk
IHZlcnNpb24gdG8gc29tZSB1bnVzZWQgcG9ydGlvbiBvZiBGbGFzaCwgdGhlbiANCnNpbXBseSB1
bm1vdW50IHdoYXQgeW91IGhhdmUgYmVlbiB1c2luZyBhbmQgbW91bnQgdGhlIG5ldyBpbWFnZSBz
aW5jZSB5b3UNCmNhbiBwYXNzIGluIHRoZSBwaHlzaWNhbCBhZGRyZXNzIG9mIHdoZXJlIHlvdSB3
cm90ZSB5b3VyIG5ldyBpbWFnZSB0by4NCg0KU28gaW4gdGhhdCBjYXNlLCBJIGd1ZXNzIHlvdSBj
YW4gZG8gc29tZSB0eXBlIG9mIERUIG92ZXJsYXkgb3IgDQpzb21ldGhpbmcsIGJ1dCBhdCB0aGUg
bW9tZW50LCBqdXN0IGhhdmluZyB0aGUgcGh5c2ljYWwgYWRkcmVzcyBhcyBhIHBhcmFtZXRlciBp
biANCm1vdW50IGNvbW1hbmQgbWFrZXMgaXQgcHJldHR5IGRhcm4gZWFzeS4NCg0KQ2hyaXMNCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
