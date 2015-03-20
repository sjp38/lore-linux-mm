Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1FE6D6B006C
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 03:06:48 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so100488018pdb.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 00:06:47 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id rj8si7719379pdb.83.2015.03.20.00.06.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Fri, 20 Mar 2015 00:06:47 -0700 (PDT)
Received: from epcpsbgx3.samsung.com
 (u163.gpu120.samsung.co.kr [203.254.230.163])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0NLI007Q9131VN90@mailout3.samsung.com> for linux-mm@kvack.org;
 Fri, 20 Mar 2015 16:06:37 +0900 (KST)
Date: Fri, 20 Mar 2015 07:06:36 +0000 (GMT)
From: Yinghao Xie <yinghao.xie@samsung.com>
Subject: Re: Re: mm/zsmalloc.c: count in handle's size when calculating
 pages_per_zspage
Reply-to: yinghao.xie@samsung.com
MIME-version: 1.0
Content-transfer-encoding: base64
Content-type: text/plain; charset=utf-8
MIME-version: 1.0
Message-id: <660418108.41771426835194470.JavaMail.weblogic@epmlwas06d>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, "sergey.senozhatsky@gmail.com" <sergey.senozhatsky@gmail.com>

PiBIZWxsbywNCj4gDQo+IHNvcnJ5LCBJJ3ZlIGEgcXVlc3Rpb24uDQo+IA0KPiBPbiAoMDMvMTkv
MTUgMTE6MzkpLCBZaW5naGFvIFhpZSB3cm90ZToNCj4gPiBAQCAtMTQyNiwxMSArMTQzMCw2IEBA
IHVuc2lnbmVkIGxvbmcgenNfbWFsbG9jKHN0cnVjdCB6c19wb29sICpwb29sLA0KPiBzaXplX3Qg
c2l6ZSkNCj4gPiAgCS8qIGV4dHJhIHNwYWNlIGluIGNodW5rIHRvIGtlZXAgdGhlIGhhbmRsZSAq
Lw0KPiA+ICAJc2l6ZSArPSBaU19IQU5ETEVfU0laRTsNCj4gPiAgCWNsYXNzID0gcG9vbC0+c2l6
ZV9jbGFzc1tnZXRfc2l6ZV9jbGFzc19pbmRleChzaXplKV07DQo+ID4gLQkvKiBJbiBodWdlIGNs
YXNzIHNpemUsIHdlIHN0b3JlIHRoZSBoYW5kbGUgaW50byBmaXJzdF9wYWdlLT5wcml2YXRlICov
DQo+ID4gLQlpZiAoY2xhc3MtPmh1Z2UpIHsNCj4gPiAtCQlzaXplIC09IFpTX0hBTkRMRV9TSVpF
Ow0KPiA+IC0JCWNsYXNzID0gcG9vbC0+c2l6ZV9jbGFzc1tnZXRfc2l6ZV9jbGFzc19pbmRleChz
aXplKV07DQo+ID4gLQl9DQo+IA0KPiBpZiBodWdlIGNsYXNzIHVzZXMgcGFnZS0+cHJpdmF0ZSB0
byBzdG9yZSBhIGhhbmRsZSwgc2hvdWxkbid0IHdlIHBhc3MgInNpemUgLT0NCj4gWlNfSEFORExF
X1NJWkUiIHRvIGdldF9zaXplX2NsYXNzX2luZGV4KCkgPw0KPiANCj4gCS1zcw0KPiANCnllcywg
eW91J3JlIHJpZ2h0Lml0J3MgbXkgbWlzdW5kZXJzdGFuZGluZywgdGhhbmtzLg0KDQo+ID4gIAlz
cGluX2xvY2soJmNsYXNzLT5sb2NrKTsNCj4gPiAgCWZpcnN0X3BhZ2UgPSBmaW5kX2dldF96c3Bh
Z2UoY2xhc3MpOyBAQCAtMTg1Niw5ICsxODU1LDcgQEAgc3RydWN0DQo+ID4genNfcG9vbCAqenNf
Y3JlYXRlX3Bvb2woY2hhciAqbmFtZSwgZ2ZwX3QgZmxhZ3MpDQo+ID4gIAkJc3RydWN0IHNpemVf
Y2xhc3MgKmNsYXNzOw0KPiA+DQo+ID4gIAkJc2l6ZSA9IFpTX01JTl9BTExPQ19TSVpFICsgaSAq
IFpTX1NJWkVfQ0xBU1NfREVMVEE7DQo+ID4gLQkJaWYgKHNpemUgPiBaU19NQVhfQUxMT0NfU0la
RSkNCj4gPiAtCQkJc2l6ZSA9IFpTX01BWF9BTExPQ19TSVpFOw0KPiA+IC0JCXBhZ2VzX3Blcl96
c3BhZ2UgPSBnZXRfcGFnZXNfcGVyX3pzcGFnZShzaXplKTsNCj4gPiArCQlwYWdlc19wZXJfenNw
YWdlID0gZ2V0X3BhZ2VzX3Blcl96c3BhZ2Uoc2l6ZSArDQo+IFpTX0hBTkRMRV9TSVpFKTsNCj4g
Pg0KPiA+ICAJCS8qDQo+ID4gIAkJICogc2l6ZV9jbGFzcyBpcyB1c2VkIGZvciBub3JtYWwgenNt
YWxsb2Mgb3BlcmF0aW9uIHN1Y2gNCg0K


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
