Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0CA368E0001
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 21:37:01 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id j8so15246248plb.1
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 18:37:01 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-eopbgr150052.outbound.protection.outlook.com. [40.107.15.52])
        by mx.google.com with ESMTPS id q9si32579407pgh.92.2018.12.26.18.36.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 26 Dec 2018 18:36:59 -0800 (PST)
From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [rpmsg PATCH v2 1/1] rpmsg: virtio_rpmsg_bus: fix unexpected huge
 vmap mappings
Date: Thu, 27 Dec 2018 02:36:53 +0000
Message-ID: 
 <VI1PR0402MB3600AC833D6F29ECC34C8D4CFFB60@VI1PR0402MB3600.eurprd04.prod.outlook.com>
References: <1545812449-32455-1-git-send-email-fugang.duan@nxp.com>
 <CAKv+Gu-zfTZAZfiQt1iUn9otqeDkJP-y-siuBUrWUR-Kq=BsVQ@mail.gmail.com>
 <20181226145048.GA24307@infradead.org>
In-Reply-To: <20181226145048.GA24307@infradead.org>
Content-Language: en-US
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Robin Murphy <robin.murphy@arm.com>, "bjorn.andersson@linaro.org" <bjorn.andersson@linaro.org>, "ohad@wizery.com" <ohad@wizery.com>, "linux-remoteproc@vger.kernel.org" <linux-remoteproc@vger.kernel.org>, "anup@brainfault.org" <anup@brainfault.org>, "loic.pallardy@st.com" <loic.pallardy@st.com>, dl-linux-imx <linux-imx@nxp.com>, Richard Zhu <hongxing.zhu@nxp.com>, Jason Liu <jason.hui.liu@nxp.com>, Peng Fan <peng.fan@nxp.com>

RnJvbTogQ2hyaXN0b3BoIEhlbGx3aWcgPGhjaEBpbmZyYWRlYWQub3JnPiBTZW50OiAyMDE4xOox
MtTCMjbI1SAyMjo1MQ0KPiBPbiBXZWQsIERlYyAyNiwgMjAxOCBhdCAwMToyNzoyNVBNICswMTAw
LCBBcmQgQmllc2hldXZlbCB3cm90ZToNCj4gPiBJZiB0aGVyZSBhcmUgbGVnYWwgdXNlcyBmb3Ig
dm1hbGxvY190b19wYWdlKCkgZXZlbiBpZiB0aGUgcmVnaW9uIGlzDQo+ID4gbm90IG1hcHBlZCBk
b3duIHRvIHBhZ2VzIFt3aGljaCBhcHBlYXJzIHRvIGJlIHRoZSBjYXNlIGhlcmVdLCBJJ2QNCj4g
PiBwcmVmZXIgdG8gZml4IHZtYWxsb2NfdG9fcGFnZSgpIGluc3RlYWQgb2YgYWRkaW5nIHRoaXMg
aGFjay4gT3INCj4gPiBwZXJoYXBzIHdlIG5lZWQgYSBzZ194eHggaGVscGVyIHRoYXQgdHJhbnNs
YXRlcyBhbnkgdmlydHVhbCBhZGRyZXNzDQo+ID4gKHZtYWxsb2Mgb3Igb3RoZXJ3aXNlKSBpbnRv
IGEgc2NhdHRlcmxpc3QgZW50cnk/DQo+IA0KPiBXaGF0IHJwbXNnIGRvZXMgaXMgY29tcGxldGVs
eSBib2d1cyBhbmQgbmVlZHMgdG8gYmUgZml4ZWQgQVNBUC4gIFRoZQ0KPiB2aXJ0dWFsIGFkZHJl
c3MgcmV0dXJuZWQgZnJvbSBkbWFfYWxsb2NfY29oZXJlbnQgbXVzdCBub3QgYmUgcGFzc2VkIHRv
DQo+IHZpcnRfdG9fcGFnZSBvciB2bWFsbG9jX3RvX3BhZ2UsIGJ1dCBvbmx5IHVzZSBhcyBhIGtl
cm5lbCB2aXJ0dWFsIGFkZHJlc3MuICBJdA0KPiBtaWdodCBub3QgYmUgYmFja2VkIGJ5IHBhZ2Vz
LCBvciBtaWdodCBjcmVhdGUgYWxpYXNlcyB0aGF0IG11c3Qgbm90IGJlIHVzZWQNCj4gd2l0aCBW
SVZUIGNhY2hlcy4NCj4gDQo+IHJwbXNnIG5lZWRzIHRvIGVpdGhlciBzdG9wIHRyeWluZyB0byBl
eHRyYWN0IHBhZ2VzIGZyb20gZG1hX2FsbG9jX2NvaGVyZW50LA0KPiBvciBqdXN0IHJlcGxhY2Ug
aXRzIHVzZSBvZiBkbWFfYWxsb2NfY29oZXJlbnQgd2l0aCB0aGUgbm9ybWFsIHBhZ2UgYWxsb2Nh
dG9yDQo+IGFuZCB0aGUgc3RyZWFtaW5nIERNQSBBUEkuDQoNClJwbXNnIGlzIHVzZWQgdG8gY29t
bXVuaWNhdGUgd2l0aCByZW1vdGUgY3B1IGxpa2UgTTQsIHRoZSBhbGxvY2F0ZWQgbWVtb3J5IGlz
IHNoYXJlZCBieSBMaW51eCBhbmQgTTQgc2lkZS4NCkluIGdlbmVyYWwsIExpbnV4IHNpZGUgcmVz
ZXJ2ZWQgdGhlIHN0YXRpYyBtZW1vcnkgcmVnaW9uIGxpa2UgcGVyLWRldmljZSBETUEgcG9vbCBh
cyBjb2hlcmVudCBtZW1vcnkgZm9yIHRoZSBSUE1TRyByZWNlaXZlL3RyYW5zbWl0IGJ1ZmZlcnMu
DQpGb3IgdGhlIHN0YXRpYyBtZW1vcnkgcmVnaW9uLCBub3JtYWwgcGFnZSBhbGxvY2F0b3IgY2Fu
bm90IG1hdGNoIHRoZSByZXF1aXJlbWVudCB1bmxlc3MgdGhlcmUgaGF2ZSBwcm90b2NvbCB0byB0
ZWxsIE00IHRoZSBkeW5hbWljIFJQTVNHIHJlY2VpdmUvdHJhbnNtaXQgYnVmZmVycy4NCg0KVG8g
c3RvcCB0byBleHRyYWN0IHBhZ2VzIGZyb20gZG1hX2FsbG9jX2NvaGVyZW50LCB0aGUgcnBtc2cg
YnVzIGltcGxlbWVudGF0aW9uIGJhc2Ugb24gdmlydGlvIHRoYXQgYWxyZWFkeSB1c2UgdGhlIHNj
YXR0ZXJsaXN0IG1lY2hhbmlzbSBmb3IgdnJpbmcgbWVtb3J5LiBTbyBmb3IgdmlydGlvIGRyaXZl
ciBsaWtlIFJQTVNHIGJ1cywgd2UgaGF2ZSB0byBleHRyYWN0IHBhZ2VzIGZyb20gZG1hX2FsbG9j
X2NvaGVyZW50Lg0KDQpJIGRvbid0IHRoaW5rIHRoZSBwYXRjaCBpcyBvbmUgaGFjaywgIGFzIHdl
IGFscmVhZHkga25vdyB0aGUgcGh5c2ljYWwgYWRkcmVzcyBmb3IgdGhlIGNvaGVyZW50IG1lbW9y
eSwgIGp1c3Qgd2FudCB0byBnZXQgcGFnZXMsIHRoZSBpbnRlcmZhY2UgInBmbl90b19wYWdlKFBI
WVNfUEZOKHgpKSIgaXMgdmVyeSByZWFzb25hYmxlIHRvIHRoZSByZWxhdGVkIHBhZ2VzLiAgDQoN
CklmIHlvdSBzdGljayB0byB1c2Ugbm9ybWFsIHBhZ2UgYWxsb2NhdG9yIGFuZCBzdHJlYW1pbmcg
RE1BIEFQSSBpbiBSUE1TRywgIHRoZW4gd2UgaGF2ZSB0bzoNCi0gYWRkIG5ldyBxdWlyayBmZWF0
dXJlIGZvciB2aXJ0aW8gbGlrZSB0aGUgc2FtZSBmdW5jdGlvbiBhcyAiVklSVElPX0ZfSU9NTVVf
UExBVEZPUk0iLCByZWdpc3RlciB0aGUgbmV3IGZlYXR1cmUgZm9yIFJQTVNHIHZpcnRvIGRyaXZl
ci4gIFRoZW4gUlBNU0cgdmlydGlvIGJ1cyBkcml2ZXIgb25seSBuZWVkIHRvIGFsbG9jYXRlIHRo
ZSBjb250aW51b3VzIHBhZ2VzLg0KLSB0aGUgc3RhdGljIG1lbW9yeSByZWdpb24gZm9yIE00IGlz
IG5vdCBzdXBwb3J0ZWQuDQoNCkFueSBpZGVhID8NCg0KUmVnYXJkcywNCkFuZHkgRHVhbg0K
