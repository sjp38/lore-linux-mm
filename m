Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 535886B0685
	for <linux-mm@kvack.org>; Fri, 18 May 2018 15:58:00 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id a5-v6so5628712plp.8
        for <linux-mm@kvack.org>; Fri, 18 May 2018 12:58:00 -0700 (PDT)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id i14-v6si6441888pgv.424.2018.05.18.12.57.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 12:57:59 -0700 (PDT)
From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: dma_sync_*_for_cpu and direction=TO_DEVICE (was Re: [PATCH
 02/20] dma-mapping: provide a generic dma-noncoherent implementation)
Date: Fri, 18 May 2018 19:57:34 +0000
Message-ID: <182840dedb4890a88c672b1c5d556920bf89a8fb.camel@synopsys.com>
References: <20180511075945.16548-1-hch@lst.de>
	 <20180511075945.16548-3-hch@lst.de>
	 <bad125dff49f6e49c895e818c9d1abb346a46e8e.camel@synopsys.com>
	 <5ac5b1e3-9b96-9c7c-4dfe-f65be45ec179@synopsys.com>
	 <20180518175004.GF17671@n2100.armlinux.org.uk>
In-Reply-To: <20180518175004.GF17671@n2100.armlinux.org.uk>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <FBDD463EE3FC3543A056335FD62CF42C@internal.synopsys.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux@armlinux.org.uk" <linux@armlinux.org.uk>
Cc: "deanbo422@gmail.com" <deanbo422@gmail.com>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nios2-dev@lists.rocketboards.org" <nios2-dev@lists.rocketboards.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "hch@lst.de" <hch@lst.de>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "green.hu@gmail.com" <green.hu@gmail.com>, "Vineet.Gupta1@synopsys.com" <Vineet.Gupta1@synopsys.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "monstr@monstr.eu" <monstr@monstr.eu>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, "linux-c6x-dev@linux-c6x.org" <linux-c6x-dev@linux-c6x.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>

SGkgUnVzc2VsLA0KDQpPbiBGcmksIDIwMTgtMDUtMTggYXQgMTg6NTAgKzAxMDAsIFJ1c3NlbGwg
S2luZyAtIEFSTSBMaW51eCB3cm90ZToNCj4gSXQncyBuZWNlc3NhcnkuICBUYWtlIGEgbW9tZW50
IHRvIHRoaW5rIGNhcmVmdWxseSBhYm91dCB0aGlzOg0KPiANCj4gICAgICAgICBkbWFfbWFwX3Np
bmdsZSgsIGRpcikNCj4gDQo+ICAgICAgICAgZG1hX3N5bmNfc2luZ2xlX2Zvcl9jcHUoLCBkaXIp
DQo+IA0KPiAgICAgICAgIGRtYV9zeW5jX3NpbmdsZV9mb3JfZGV2aWNlKCwgZGlyKQ0KPiANCj4g
ICAgICAgICBkbWFfdW5tYXBfc2luZ2xlKCwgZGlyKQ0KPiANCj4gSW4gdGhlIGNhc2Ugb2YgYSBE
TUEtaW5jb2hlcmVudCBhcmNoaXRlY3R1cmUsIHRoZSBvcGVyYXRpb25zIGRvbmUgYXQgZWFjaA0K
PiBzdGFnZSBkZXBlbmQgb24gdGhlIGRpcmVjdGlvbiBhcmd1bWVudDoNCj4gDQo+ICAgICAgICAg
bWFwICAgICAgICAgICAgIGZvcl9jcHUgICAgICAgICBmb3JfZGV2aWNlICAgICAgdW5tYXANCj4g
VE9fREVWICB3cml0ZWJhY2sgICAgICAgbm9uZSAgICAgICAgICAgIHdyaXRlYmFjayAgICAgICBu
b25lDQo+IFRPX0NQVSAgaW52YWxpZGF0ZSAgICAgIGludmFsaWRhdGUqICAgICBpbnZhbGlkYXRl
ICAgICAgaW52YWxpZGF0ZSoNCj4gQklESVIgICB3cml0ZWJhY2sgICAgICAgaW52YWxpZGF0ZSAg
ICAgIHdyaXRlYmFjayAgICAgICBpbnZhbGlkYXRlDQo+IA0KPiAqIC0gb25seSBuZWNlc3Nhcnkg
aWYgdGhlIENQVSBzcGVjdWxhdGl2ZWx5IHByZWZldGNoZXMuDQoNCkkgdGhpbmsgaW52YWxpZGF0
aW9uIG9mIERNQSBidWZmZXIgaXMgcmVxdWlyZWQgb24gZm9yX2NwdShUT19DUFUpIGV2ZW4NCmlm
IENQVSBkb2Vzbid0IHByZWZlcmNoIC0gd2hhdCBpZiB3ZSByZXVzZSB0aGUgc2FtZSBidWZmZXIg
Zm9yIG11bHRpcGxlDQpyZWFkcyBmcm9tIERNQSBkZXZpY2U/DQoNCj4gVGhlIG11bHRpcGxlIGlu
dmFsaWRhdGlvbnMgZm9yIHRoZSBUT19DUFUgY2FzZSBoYW5kbGVzIGRpZmZlcmVudA0KPiBjb25k
aXRpb25zIHRoYXQgY2FuIHJlc3VsdCBpbiBkYXRhIGNvcnJ1cHRpb24sIGFuZCBmb3Igc29tZSBD
UFVzLCBhbGwNCj4gZm91ciBhcmUgbmVjZXNzYXJ5Lg0KDQpJIHdvdWxkIGFncmVlIHRoYXQgbWFw
KCkvdW5tYXAoKSBhIHF1aXRlIGEgc3BlY2lhbCBjYXNlcyBhbmQgc28gZGVwZW5kaW5nDQpvbiBk
aXJlY3Rpb24gd2UgbmVlZCB0byBleGVjdXRlIGluIHRoZW0gZWl0aGVyIGZvcl9jcHUoKSBvciBm
b3JfZGV2aWNlKCkNCmNhbGwtYmFja3MgZGVwZW5kaW5nIG9uIGRpcmVjdGlvbi4NCg0KQXMgZm9y
IGludmFsaWRhdGlvbiBpbiBjYXNlIG9mIGZvcl9kZXZpY2UoVE9fQ1BVKSBJIHN0aWxsIGRvbid0
IHNlZQ0KYSByYXRpb25hbGUgYmVoaW5kIGl0LiBXb3VsZCBiZSBpbnRlcmVzdGluZyB0byBzZWUg
YSByZWFsIGV4YW1wbGUgd2hlcmUNCndlIGJlbmVmaXQgZnJvbSB0aGlzLg0KDQo+IFRoaXMgaXMg
d2hhdCBpcyBpbXBsZW1lbnRlZCBmb3IgMzItYml0IEFSTSwgZGVwZW5kaW5nIG9uIHRoZSBDUFUN
Cj4gY2FwYWJpbGl0aWVzLCBhcyB3ZSBoYXZlIERNQSBpbmNvaGVyZW50IGRldmljZXMgYW5kIHdl
IGhhdmUgQ1BVcyB0aGF0DQo+IHNwZWN1bGF0aXZlbHkgcHJlZmV0Y2ggZGF0YSwgYW5kIHNvIG1h
eSBsb2FkIGRhdGEgaW50byB0aGUgY2FjaGVzIHdoaWxlDQo+IERNQSBpcyBpbiBvcGVyYXRpb24u
DQo+IA0KPiANCj4gVGhpbmdzIGdldCBtb3JlIGludGVyZXN0aW5nIGlmIHRoZSBpbXBsZW1lbnRh
dGlvbiBiZWhpbmQgdGhlIERNQSBBUEkgaGFzDQo+IHRvIGNvcHkgZGF0YSBiZXR3ZWVuIHRoZSBi
dWZmZXIgc3VwcGxpZWQgdG8gdGhlIG1hcHBpbmcgYW5kIHNvbWUgRE1BDQo+IGFjY2Vzc2libGUg
YnVmZmVyOg0KPiANCj4gICAgICAgICBtYXAgICAgICAgICAgICAgZm9yX2NwdSAgICAgICAgIGZv
cl9kZXZpY2UgICAgICB1bm1hcA0KPiBUT19ERVYgIGNvcHkgdG8gZG1hICAgICBub25lICAgICAg
ICAgICAgY29weSB0byBkbWEgICAgIG5vbmUNCj4gVE9fQ1BVICBub25lICAgICAgICAgICAgY29w
eSB0byBjcHUgICAgIG5vbmUgICAgICAgICAgICBjb3B5IHRvIGNwdQ0KPiBCSURJUiAgIGNvcHkg
dG8gZG1hICAgICBjb3B5IHRvIGNwdSAgICAgY29weSB0byBkbWEgICAgIGNvcHkgdG8gY3B1DQo+
IA0KPiBTbywgaW4gYm90aCBjYXNlcywgdGhlIHZhbHVlIG9mIHRoZSBkaXJlY3Rpb24gYXJndW1l
bnQgZGVmaW5lcyB3aGF0IHlvdQ0KPiBuZWVkIHRvIGRvIGluIGVhY2ggY2FsbC4NCg0KSW50ZXJl
c3RpbmcgZW5vdWdoIGluIHlvdXIgc2VvbmQgdGFibGUgKHdoaWNoIGRlc2NyaWJlcyBtb3JlIGNv
bXBsaWNhdGVkDQpjYXNlIGluZGVlZCkgeW91IHNldCAibm9uZSIgZm9yIGZvcl9kZXZpY2UoVE9f
Q1BVKSB3aGljaCBsb29rcyBsb2dpY2FsDQp0byBtZS4NCg0KU28gSU1ITyB0aGF0J3Mgd2hhdCBt
YWtlIHNlbnNlOg0KLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLT44LS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0NCiAgICAgICAgbWFwICAgICAgICAgICAgIGZvcl9jcHUgICAgICAgICBm
b3JfZGV2aWNlICAgICAgdW5tYXANClRPX0RFViAgd3JpdGViYWNrICAgICAgIG5vbmUgICAgICAg
ICAgICB3cml0ZWJhY2sgICAgICAgbm9uZQ0KVE9fQ1BVICBub25lICAgICAgICAgICAgaW52YWxp
ZGF0ZSAgICAgIG5vbmUgICAgICAgICAgICBpbnZhbGlkYXRlKg0KQklESVIgICB3cml0ZWJhY2sg
ICAgICAgaW52YWxpZGF0ZSAgICAgIHdyaXRlYmFjayAgICAgICBpbnZhbGlkYXRlKg0KLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLT44LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCg0K
KiBpcyB0aGUgY2FzZSBmb3IgcHJlZmV0Y2hpbmcgQ1BVLg0KDQotQWxleGV5
