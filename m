Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id DA2476B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 12:54:52 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id hb4so139314002pac.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:54:52 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id n10si4870016pay.80.2016.04.15.09.54.51
        for <linux-mm@kvack.org>;
        Fri, 15 Apr 2016 09:54:51 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
Date: Fri, 15 Apr 2016 16:54:48 +0000
Message-ID: <1460739288.3012.3.camel@intel.com>
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	 <1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
	 <x49twj26edj.fsf@segfault.boston.devel.redhat.com>
In-Reply-To: <x49twj26edj.fsf@segfault.boston.devel.redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <16063EC031B1C2489B91594D65C22F50@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "jmoyer@redhat.com" <jmoyer@redhat.com>
Cc: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "axboe@fb.com" <axboe@fb.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

T24gRnJpLCAyMDE2LTA0LTE1IGF0IDEyOjExIC0wNDAwLCBKZWZmIE1veWVyIHdyb3RlOg0KPiBW
aXNoYWwgVmVybWEgPHZpc2hhbC5sLnZlcm1hQGludGVsLmNvbT4gd3JpdGVzOg0KPiANCj4gPiAN
Cj4gPiBkYXhfZG9faW8gKGNhbGxlZCBmb3IgcmVhZCgpIG9yIHdyaXRlKCkgZm9yIGEgZGF4IGZp
bGUgc3lzdGVtKSBtYXkNCj4gPiBmYWlsDQo+ID4gaW4gdGhlIHByZXNlbmNlIG9mIGJhZCBibG9j
a3Mgb3IgbWVkaWEgZXJyb3JzLiBTaW5jZSB3ZSBleHBlY3QgdGhhdA0KPiA+IGENCj4gPiB3cml0
ZSBzaG91bGQgY2xlYXIgbWVkaWEgZXJyb3JzIG9uIG52ZGltbXMsIG1ha2UgZGF4X2RvX2lvIGZh
bGwNCj4gPiBiYWNrIHRvDQo+ID4gdGhlIGRpcmVjdF9JTyBwYXRoLCB3aGljaCB3aWxsIHNlbmQg
ZG93biBhIGJpbyB0byB0aGUgZHJpdmVyLCB3aGljaA0KPiA+IGNhbg0KPiA+IHRoZW4gYXR0ZW1w
dCB0byBjbGVhciB0aGUgZXJyb3IuDQo+IFtzbmlwXQ0KPiANCj4gPiANCj4gPiArCWlmIChJU19E
QVgoaW5vZGUpKSB7DQo+ID4gKwkJcmV0ID0gZGF4X2RvX2lvKGlvY2IsIGlub2RlLCBpdGVyLCBv
ZmZzZXQsDQo+ID4gYmxrZGV2X2dldF9ibG9jaywNCj4gPiDCoAkJCQlOVUxMLCBESU9fU0tJUF9E
SU9fQ09VTlQpOw0KPiA+IC0JcmV0dXJuIF9fYmxvY2tkZXZfZGlyZWN0X0lPKGlvY2IsIGlub2Rl
LCBJX0JERVYoaW5vZGUpLA0KPiA+IGl0ZXIsIG9mZnNldCwNCj4gPiArCQlpZiAocmV0ID09IC1F
SU8gJiYgKGlvdl9pdGVyX3J3KGl0ZXIpID09IFdSSVRFKSkNCj4gPiArCQkJcmV0X3NhdmVkID0g
cmV0Ow0KPiA+ICsJCWVsc2UNCj4gPiArCQkJcmV0dXJuIHJldDsNCj4gPiArCX0NCj4gPiArDQo+
ID4gKwlyZXQgPSBfX2Jsb2NrZGV2X2RpcmVjdF9JTyhpb2NiLCBpbm9kZSwgSV9CREVWKGlub2Rl
KSwNCj4gPiBpdGVyLCBvZmZzZXQsDQo+ID4gwqAJCQkJwqDCoMKgwqBibGtkZXZfZ2V0X2Jsb2Nr
LCBOVUxMLCBOVUxMLA0KPiA+IMKgCQkJCcKgwqDCoMKgRElPX1NLSVBfRElPX0NPVU5UKTsNCj4g
PiArCWlmIChyZXQgPCAwICYmIHJldF9zYXZlZCkNCj4gPiArCQlyZXR1cm4gcmV0X3NhdmVkOw0K
PiA+ICsNCj4gSG1tLCBkaWQgeW91IGp1c3QgYnJlYWsgYXN5bmMgRElPP8KgwqBJIHRoaW5rIHlv
dSBkaWQhwqDCoDopDQo+IF9fYmxvY2tkZXZfZGlyZWN0X0lPIGNhbiByZXR1cm4gLUVJT0NCUVVF
VUVELCBhbmQgeW91J3ZlIG5vdyB0dXJuZWQNCj4gdGhhdA0KPiBpbnRvIC1FSU8uwqDCoFJlYWxs
eSwgSSBkb24ndCBzZWUgYSByZWFzb24gdG8gc2F2ZSB0aGF0IGZpcnN0DQo+IC1FSU8uwqDCoFRo
ZQ0KPiBzYW1lIGFwcGxpZXMgdG8gYWxsIGluc3RhbmNlcyBpbiB0aGlzIHBhdGNoLg0KDQpUaGUg
cmVhc29uIEkgc2F2ZWQgaXQgd2FzIGlmIF9fYmxvY2tkZXZfZGlyZWN0X0lPIGZhaWxzIGZvciBz
b21lDQpyZWFzb24sIHdlIHNob3VsZCByZXR1cm4gdGhlIG9yaWdpbmFsIGNhdXNlIG8gdGhlIGVy
cm9yLCB3aGljaCB3YXMgYW4NCkVJTy4uIGkuZS4gd2Ugc2hvdWxkbid0IGJlIGhpZGluZyB0aGUg
RUlPIGlmIHRoZSBkaXJlY3RfSU8gZmFpbHMgd2l0aA0Kc29tZXRoaW5nIGVsc2UuLg0KQnV0LCBo
b3cgZG9lcyBfRUlPQ0JRVUVVRUQgd29yaz8gTWF5YmUgd2UgbmVlZCBhbiBleGNlcHRpb24gZm9y
IGl0P8KgDQoNClRoYW5rcywNCgktVmlzaGFs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
