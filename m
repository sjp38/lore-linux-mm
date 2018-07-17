Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 736EA6B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 02:37:26 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z21-v6so18676021plo.13
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 23:37:26 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id y11-v6si187281pll.89.2018.07.16.23.37.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 23:37:25 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v5 08/11] mm, memory_failure: Teach memory_failure()
 about dev_pagemap pages
Date: Tue, 17 Jul 2018 06:36:19 +0000
Message-ID: <20180717063619.GB1346@hori1.linux.bs1.fc.nec.co.jp>
References: <153074042316.27838.17319837331947007626.stgit@dwillia2-desk3.amr.corp.intel.com>
 <153074046610.27838.329669845580014251.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20180713085241.GA26980@hori1.linux.bs1.fc.nec.co.jp>
 <CAPcyv4jpn_NyBWjvj3s67Y8pvPDu0BODtqNJZQL81ryPeewvwA@mail.gmail.com>
In-Reply-To: <CAPcyv4jpn_NyBWjvj3s67Y8pvPDu0BODtqNJZQL81ryPeewvwA@mail.gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-ID: <143C38EA678153419A92FA737435C1AF@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

T24gRnJpLCBKdWwgMTMsIDIwMTggYXQgMDU6Mjg6MDVQTSAtMDcwMCwgRGFuIFdpbGxpYW1zIHdy
b3RlOg0KPiBPbiBGcmksIEp1bCAxMywgMjAxOCBhdCAxOjUyIEFNLCBOYW95YSBIb3JpZ3VjaGkN
Cj4gPG4taG9yaWd1Y2hpQGFoLmpwLm5lYy5jb20+IHdyb3RlOg0KPiA+IE9uIFdlZCwgSnVsIDA0
LCAyMDE4IGF0IDAyOjQxOjA2UE0gLTA3MDAsIERhbiBXaWxsaWFtcyB3cm90ZToNCi4uLg0KPiA+
PiArDQo+ID4+ICsgICAgIC8qDQo+ID4+ICsgICAgICAqIFVzZSB0aGlzIGZsYWcgYXMgYW4gaW5k
aWNhdGlvbiB0aGF0IHRoZSBkYXggcGFnZSBoYXMgYmVlbg0KPiA+PiArICAgICAgKiByZW1hcHBl
ZCBVQyB0byBwcmV2ZW50IHNwZWN1bGF0aXZlIGNvbnN1bXB0aW9uIG9mIHBvaXNvbi4NCj4gPj4g
KyAgICAgICovDQo+ID4+ICsgICAgIFNldFBhZ2VIV1BvaXNvbihwYWdlKTsNCj4gPg0KPiA+IFRo
ZSBudW1iZXIgb2YgaHdwb2lzb24gcGFnZXMgaXMgbWFpbnRhaW5lZCBieSBudW1fcG9pc29uZWRf
cGFnZXMsDQo+ID4gc28geW91IGNhbiBjYWxsIG51bV9wb2lzb25lZF9wYWdlc19pbmMoKT8NCj4g
DQo+IEkgZG9uJ3QgdGhpbmsgd2Ugd2FudCB0aGVzZSBwYWdlcyBhY2NvdW50ZWQgaW4gbnVtX3Bv
aXNvbmVkX3BhZ2VzKCkuDQo+IFdlIGhhdmUgdGhlIGJhZGJsb2NrcyBpbmZyYXN0cnVjdHVyZSBp
biBsaWJudmRpbW0gdG8gdHJhY2sgaG93IG1hbnkNCj4gZXJyb3JzIGFuZCB3aGVyZSB0aGV5IGFy
ZSBsb2NhdGVkLCBhbmQgc2luY2UgdGhleSBjYW4gYmUgcmVwYWlyZWQgdmlhDQo+IGRyaXZlciBh
Y3Rpb25zIEkgdGhpbmsgd2Ugc2hvdWxkIHRyYWNrIHRoZW0gc2VwYXJhdGVseS4NCg0KT0suDQoN
Cj4gPiBSZWxhdGVkIHRvIHRoaXMsIEknbSBpbnRlcmVzdGVkIGluIHdoZXRoZXIvaG93IHVucG9p
c29uX3BhZ2UoKSB3b3Jrcw0KPiA+IG9uIGEgaHdwb2lzb25lZCBkZXZfcGFnZW1hcCBwYWdlLg0K
PiANCj4gdW5wb2lzb25fcGFnZSgpIGlzIG9ubHkgdHJpZ2dlcmVkIHZpYSBmcmVlaW5nIHBhZ2Vz
IHRvIHRoZSBwYWdlDQo+IGFsbG9jYXRvciwgYW5kIHRoYXQgbmV2ZXIgaGFwcGVucyBmb3IgZGV2
X3BhZ2VtYXAgLyBaT05FX0RFVklDRSBwYWdlcy4NCg0Kc29ycnksIG15IGJhZCBjb21tZW50Lg0K
SSBtZWFudCB1bnBvaXNvbl9tZW1vcnkoKSBpbiBtbS9tZW1vcnktZmFpbHVyZS5jLCB3aGljaCBp
cyB0cmlnZ2VyZWQNCnZpYSBkZWJ1Z2ZzOmh3cG9pc29uL3VucG9pc29uLXBmbi4gVGhpcyBpbnRl
cmZhY2UgbG9va3MgbGlrZSBiZWxvdw0KDQogIGludCB1bnBvaXNvbl9tZW1vcnkodW5zaWduZWQg
bG9uZyBwZm4pDQogIHsNCiAgICAgICAgICBzdHJ1Y3QgcGFnZSAqcGFnZTsNCiAgICAgICAgICBz
dHJ1Y3QgcGFnZSAqcDsNCiAgICAgICAgICBpbnQgZnJlZWl0ID0gMDsNCiAgICAgICAgICBzdGF0
aWMgREVGSU5FX1JBVEVMSU1JVF9TVEFURSh1bnBvaXNvbl9ycywgREVGQVVMVF9SQVRFTElNSVRf
SU5URVJWQUwsDQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBERUZB
VUxUX1JBVEVMSU1JVF9CVVJTVCk7DQoNCiAgICAgICAgICBpZiAoIXBmbl92YWxpZChwZm4pKQ0K
ICAgICAgICAgICAgICAgICAgcmV0dXJuIC1FTlhJTzsNCg0KICAgICAgICAgIHAgPSBwZm5fdG9f
cGFnZShwZm4pOw0KICAgICAgICAgIHBhZ2UgPSBjb21wb3VuZF9oZWFkKHApOw0KDQogICAgICAg
ICAgaWYgKCFQYWdlSFdQb2lzb24ocCkpIHsNCiAgICAgICAgICAgICAgICAgIHVucG9pc29uX3By
X2luZm8oIlVucG9pc29uOiBQYWdlIHdhcyBhbHJlYWR5IHVucG9pc29uZWQgJSNseFxuIiwNCiAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgcGZuLCAmdW5wb2lzb25fcnMpOw0KICAg
ICAgICAgICAgICAgICAgcmV0dXJuIDA7DQogICAgICAgICAgfQ0KICAuLi4NCg0Kc28gSSB0aGlu
ayB0aGF0IHdlIGNhbiBhZGQgaXNfem9uZV9kZXZpY2VfcGFnZSgpIGNoZWNrIGF0IHRoZSBiZWdp
bm5pbmcNCm9mIHRoaXMgZnVuY3Rpb24gdG8gY2FsbCBod3BvaXNvbl9jbGVhcigpIGludHJvZHVj
ZWQgaW4gcGF0Y2ggMTMvMTM/DQpPdGhlcndpc2UgbWF5YmUgY29tcG91bmRfaGVhZCgpIHdpbGwg
Y2F1c2Ugc29tZSBjcml0aWNhbCBpc3N1ZSBsaWtlDQpnZW5lcmFsIHByb3RlY3Rpb24gZmF1bHQu
DQoNClRoYW5rcywNCk5hb3lhIEhvcmlndWNoaQ==
