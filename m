Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id D49CA6B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 13:37:04 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id zy2so140812730pac.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:37:04 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id c84si3251808pfb.8.2016.04.15.10.37.03
        for <linux-mm@kvack.org>;
        Fri, 15 Apr 2016 10:37:04 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
Date: Fri, 15 Apr 2016 17:37:02 +0000
Message-ID: <1460741821.3012.11.camel@intel.com>
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	 <1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
	 <x49twj26edj.fsf@segfault.boston.devel.redhat.com>
	 <1460739288.3012.3.camel@intel.com>
	 <x49potq6bm2.fsf@segfault.boston.devel.redhat.com>
In-Reply-To: <x49potq6bm2.fsf@segfault.boston.devel.redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <CCD91253E6E05545B2738755BAAADF3C@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "jmoyer@redhat.com" <jmoyer@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "hch@infradead.org" <hch@infradead.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "axboe@fb.com" <axboe@fb.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

T24gRnJpLCAyMDE2LTA0LTE1IGF0IDEzOjExIC0wNDAwLCBKZWZmIE1veWVyIHdyb3RlOg0KPiAi
VmVybWEsIFZpc2hhbCBMIiA8dmlzaGFsLmwudmVybWFAaW50ZWwuY29tPiB3cml0ZXM6DQo+IA0K
PiA+IA0KPiA+IE9uIEZyaSwgMjAxNi0wNC0xNSBhdCAxMjoxMSAtMDQwMCwgSmVmZiBNb3llciB3
cm90ZToNCj4gPiA+IA0KPiA+ID4gVmlzaGFsIFZlcm1hIDx2aXNoYWwubC52ZXJtYUBpbnRlbC5j
b20+IHdyaXRlczoNCj4gPiA+ID4gDQo+ID4gPiA+ICsJaWYgKElTX0RBWChpbm9kZSkpIHsNCj4g
PiA+ID4gKwkJcmV0ID0gZGF4X2RvX2lvKGlvY2IsIGlub2RlLCBpdGVyLCBvZmZzZXQsDQo+ID4g
PiA+IGJsa2Rldl9nZXRfYmxvY2ssDQo+ID4gPiA+IMKgCQkJCU5VTEwsIERJT19TS0lQX0RJT19D
T1VOVCk7DQo+ID4gPiA+IC0JcmV0dXJuIF9fYmxvY2tkZXZfZGlyZWN0X0lPKGlvY2IsIGlub2Rl
LA0KPiA+ID4gPiBJX0JERVYoaW5vZGUpLA0KPiA+ID4gPiBpdGVyLCBvZmZzZXQsDQo+ID4gPiA+
ICsJCWlmIChyZXQgPT0gLUVJTyAmJiAoaW92X2l0ZXJfcncoaXRlcikgPT0NCj4gPiA+ID4gV1JJ
VEUpKQ0KPiA+ID4gPiArCQkJcmV0X3NhdmVkID0gcmV0Ow0KPiA+ID4gPiArCQllbHNlDQo+ID4g
PiA+ICsJCQlyZXR1cm4gcmV0Ow0KPiA+ID4gPiArCX0NCj4gPiA+ID4gKw0KPiA+ID4gPiArCXJl
dCA9IF9fYmxvY2tkZXZfZGlyZWN0X0lPKGlvY2IsIGlub2RlLCBJX0JERVYoaW5vZGUpLA0KPiA+
ID4gPiBpdGVyLCBvZmZzZXQsDQo+ID4gPiA+IMKgCQkJCcKgwqDCoMKgYmxrZGV2X2dldF9ibG9j
aywgTlVMTCwNCj4gPiA+ID4gTlVMTCwNCj4gPiA+ID4gwqAJCQkJwqDCoMKgwqBESU9fU0tJUF9E
SU9fQ09VTlQpOw0KPiA+ID4gPiArCWlmIChyZXQgPCAwICYmIHJldF9zYXZlZCkNCj4gPiA+ID4g
KwkJcmV0dXJuIHJldF9zYXZlZDsNCj4gPiA+ID4gKw0KPiA+ID4gSG1tLCBkaWQgeW91IGp1c3Qg
YnJlYWsgYXN5bmMgRElPP8KgwqBJIHRoaW5rIHlvdSBkaWQhwqDCoDopDQo+ID4gPiBfX2Jsb2Nr
ZGV2X2RpcmVjdF9JTyBjYW4gcmV0dXJuIC1FSU9DQlFVRVVFRCwgYW5kIHlvdSd2ZSBub3cNCj4g
PiA+IHR1cm5lZA0KPiA+ID4gdGhhdA0KPiA+ID4gaW50byAtRUlPLsKgwqBSZWFsbHksIEkgZG9u
J3Qgc2VlIGEgcmVhc29uIHRvIHNhdmUgdGhhdCBmaXJzdA0KPiA+ID4gLUVJTy7CoMKgVGhlDQo+
ID4gPiBzYW1lIGFwcGxpZXMgdG8gYWxsIGluc3RhbmNlcyBpbiB0aGlzIHBhdGNoLg0KPiA+IFRo
ZSByZWFzb24gSSBzYXZlZCBpdCB3YXMgaWYgX19ibG9ja2Rldl9kaXJlY3RfSU8gZmFpbHMgZm9y
IHNvbWUNCj4gPiByZWFzb24sIHdlIHNob3VsZCByZXR1cm4gdGhlIG9yaWdpbmFsIGNhdXNlIG8g
dGhlIGVycm9yLCB3aGljaCB3YXMNCj4gPiBhbg0KPiA+IEVJTy4uIGkuZS4gd2Ugc2hvdWxkbid0
IGJlIGhpZGluZyB0aGUgRUlPIGlmIHRoZSBkaXJlY3RfSU8gZmFpbHMNCj4gPiB3aXRoDQo+ID4g
c29tZXRoaW5nIGVsc2UuLg0KPiBPSy4NCj4gDQo+ID4gDQo+ID4gQnV0LCBob3cgZG9lcyBfRUlP
Q0JRVUVVRUQgd29yaz8gTWF5YmUgd2UgbmVlZCBhbiBleGNlcHRpb24gZm9yIGl0Pw0KPiBGb3Ig
YXN5bmMgZGlyZWN0IEkvTywgb25seSB0aGUgc2V0dXAgcGhhc2Ugb2YgdGhlIEkvTyBpcyBwZXJm
b3JtZWQNCj4gYW5kDQo+IHRoZW4gd2UgcmV0dXJuIHRvIHRoZSBjYWxsZXIuwqDCoC1FSU9DQlFV
RVVFRCBzaWduaWZpZXMgdGhpcy4NCj4gDQo+IFlvdSdyZSBoZWFkaW5nIHRvd2FyZHMgY29kZSB0
aGF0IGxvb2tzIGxpa2UgdGhpczoNCj4gDQo+IMKgwqDCoMKgwqDCoMKgwqBpZiAoSVNfREFYKGlu
b2RlKSkgew0KPiDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoHJldCA9IGRheF9kb19p
byhpb2NiLCBpbm9kZSwgaXRlciwgb2Zmc2V0LA0KPiBibGtkZXZfZ2V0X2Jsb2NrLA0KPiDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgTlVMTCwgRElPX1NLSVBfRElPX0NPVU5UKTsNCj4gwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqBpZiAocmV0ID09IC1FSU8gJiYgKGlvdl9pdGVyX3J3KGl0ZXIpID09IFdSSVRFKSkN
Cj4gwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgcmV0X3Nh
dmVkID0gcmV0Ow0KPiDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoGVsc2UNCj4gwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgcmV0dXJuIHJldDsN
Cj4gwqDCoMKgwqDCoMKgwqDCoH0NCj4gDQo+IMKgwqDCoMKgwqDCoMKgwqByZXQgPSBfX2Jsb2Nr
ZGV2X2RpcmVjdF9JTyhpb2NiLCBpbm9kZSwgSV9CREVWKGlub2RlKSwgaXRlciwNCj4gb2Zmc2V0
LA0KPiDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqBibGtkZXZfZ2V0X2Jsb2NrLCBOVUxMLCBOVUxMLA0KPiDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqBESU9fU0tJUF9ESU9fQ09VTlQpOw0KPiDCoMKgwqDCoMKgwqDCoMKgaWYgKHJl
dCA8IDAgJiYgcmV0ICE9IC1FSU9DQlFVRVVFRCAmJiByZXRfc2F2ZWQpDQo+IMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgcmV0dXJuIHJldF9zYXZlZDsNCj4gDQo+IFRoZXJlJ3MgYSBs
b3Qgb2Ygc3BlY2lhbCBjYXNpbmcgaGVyZSwgc28geW91IG1pZ2h0IGNvbnNpZGVyIGFkZGluZw0K
PiBjb21tZW50cy4NCg0KQ29ycmVjdCAtIG1heWJlIHdlIHNob3VsZCByZWNvbnNpZGVyIHdyYXBw
ZXItaXppbmcgdGhpcz8gOikNCg0KVGhhbmtzIGZvciB0aGUgZXhwbGFuYXRpb24gYW5kIGZvciBj
YXRjaGluZyB0aGlzLiBJJ2xsIGZpeCBpdCBmb3IgdGhlDQpuZXh0IHJldmlzaW9uLg0KDQo+IA0K
PiBDaGVlcnMsDQo+IEplZmY=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
