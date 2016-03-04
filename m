Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6869C6B0254
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 21:43:54 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id fl4so25978544pad.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 18:43:54 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id i10si2283342pat.47.2016.03.03.18.43.53
        for <linux-mm@kvack.org>;
        Thu, 03 Mar 2016 18:43:53 -0800 (PST)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: [Qemu-devel] [RFC qemu 4/4] migration: filter out guest's free
 pages in ram bulk stage
Date: Fri, 4 Mar 2016 02:43:49 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E03770FEA@SHSMSX101.ccr.corp.intel.com>
References: <1457001868-15949-1-git-send-email-liang.z.li@intel.com>
 <1457001868-15949-5-git-send-email-liang.z.li@intel.com>
 <20160303124520.GE32270@redhat.com>
In-Reply-To: <20160303124520.GE32270@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Daniel P. Berrange" <berrange@redhat.com>
Cc: "quintela@redhat.com" <quintela@redhat.com>, "amit.shah@redhat.com" <amit.shah@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ehabkost@redhat.com" <ehabkost@redhat.com>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "mst@redhat.com" <mst@redhat.com>, "dgilbert@redhat.com" <dgilbert@redhat.com>, "virtualization@lists.linux-foundation.org" <virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rth@twiddle.net" <rth@twiddle.net>

PiBPbiBUaHUsIE1hciAwMywgMjAxNiBhdCAwNjo0NDoyOFBNICswODAwLCBMaWFuZyBMaSB3cm90
ZToNCj4gPiBHZXQgdGhlIGZyZWUgcGFnZXMgaW5mb3JtYXRpb24gdGhyb3VnaCB2aXJ0aW8gYW5k
IGZpbHRlciBvdXQgdGhlIGZyZWUNCj4gPiBwYWdlcyBpbiB0aGUgcmFtIGJ1bGsgc3RhZ2UuIFRo
aXMgY2FuIHNpZ25pZmljYW50bHkgcmVkdWNlIHRoZSB0b3RhbA0KPiA+IGxpdmUgbWlncmF0aW9u
IHRpbWUgYXMgd2VsbCBhcyBuZXR3b3JrIHRyYWZmaWMuDQo+ID4NCj4gPiBTaWduZWQtb2ZmLWJ5
OiBMaWFuZyBMaSA8bGlhbmcuei5saUBpbnRlbC5jb20+DQo+ID4gLS0tDQo+ID4gIG1pZ3JhdGlv
bi9yYW0uYyB8IDUyDQo+ID4gKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKy0tLS0tLQ0KPiA+ICAxIGZpbGUgY2hhbmdlZCwgNDYgaW5zZXJ0aW9ucygrKSwgNiBk
ZWxldGlvbnMoLSkNCj4gDQo+ID4gQEAgLTE5NDUsNiArMTk3MSwyMCBAQCBzdGF0aWMgaW50IHJh
bV9zYXZlX3NldHVwKFFFTVVGaWxlICpmLCB2b2lkDQo+ICpvcGFxdWUpDQo+ID4gICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgRElSVFlfTUVNT1JZX01JR1JBVElP
Tik7DQo+ID4gICAgICB9DQo+ID4gICAgICBtZW1vcnlfZ2xvYmFsX2RpcnR5X2xvZ19zdGFydCgp
Ow0KPiA+ICsNCj4gPiArICAgIGlmIChiYWxsb29uX2ZyZWVfcGFnZXNfc3VwcG9ydCgpICYmDQo+
ID4gKyAgICAgICAgYmFsbG9vbl9nZXRfZnJlZV9wYWdlcyhtaWdyYXRpb25fYml0bWFwX3JjdS0+
ZnJlZV9wYWdlc19ibWFwLA0KPiA+ICsgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgJmZy
ZWVfcGFnZXNfY291bnQpID09IDApIHsNCj4gPiArICAgICAgICBxZW11X211dGV4X3VubG9ja19p
b3RocmVhZCgpOw0KPiA+ICsgICAgICAgIHdoaWxlIChiYWxsb29uX2dldF9mcmVlX3BhZ2VzKG1p
Z3JhdGlvbl9iaXRtYXBfcmN1LQ0KPiA+ZnJlZV9wYWdlc19ibWFwLA0KPiA+ICsgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgICZmcmVlX3BhZ2VzX2NvdW50KSA9PSAwKSB7DQo+
ID4gKyAgICAgICAgICAgIHVzbGVlcCgxMDAwKTsNCj4gPiArICAgICAgICB9DQo+ID4gKyAgICAg
ICAgcWVtdV9tdXRleF9sb2NrX2lvdGhyZWFkKCk7DQo+ID4gKw0KPiA+ICsgICAgICAgIGZpbHRl
cl9vdXRfZ3Vlc3RfZnJlZV9wYWdlcyhtaWdyYXRpb25fYml0bWFwX3JjdS0NCj4gPmZyZWVfcGFn
ZXNfYm1hcCk7DQo+ID4gKyAgICB9DQo+IA0KPiBJSVVDLCB0aGlzIGNvZGUgaXMgc3luY2hyb25v
dXMgd3J0IHRvIHRoZSBndWVzdCBPUyBiYWxsb29uIGRyaXZlLiBpZSBpdCBpcyBhc2tpbmcNCj4g
dGhlIGdldXN0IGZvciBmcmVlIHBhZ2VzIGFuZCB3YWl0aW5nIGZvciBhIHJlc3BvbnNlLiBJZiB0
aGUgZ3Vlc3QgT1MgaGFzDQo+IGNyYXNoZWQgdGhpcyBpcyBnb2luZyB0byBtZWFuIFFFTVUgd2Fp
dHMgZm9yZXZlciBhbmQgdGh1cyBtaWdyYXRpb24gd29uJ3QNCj4gY29tcGxldGUuIFNpbWlsYXJs
eSB5b3UgbmVlZCB0byBjb25zaWRlciB0aGF0IHRoZSBndWVzdCBPUyBtYXkgYmUgbWFsaWNpb3Vz
DQo+IGFuZCBzaW1wbHkgbmV2ZXIgcmVzcG9uZC4NCj4gDQo+IFNvIGlmIHRoZSBtaWdyYXRpb24g
Y29kZSBpcyBnb2luZyB0byB1c2UgdGhlIGd1ZXN0IGJhbGxvb24gZHJpdmVyIHRvIGdldCBpbmZv
DQo+IGFib3V0IGZyZWUgcGFnZXMgaXQgaGFzIHRvIGJlIGRvbmUgaW4gYW4gYXN5bmNocm9ub3Vz
IG1hbm5lciBzbyB0aGF0DQo+IG1pZ3JhdGlvbiBjYW4gbmV2ZXIgYmUgc3RhbGxlZCBieSBhIHNs
b3cvY3Jhc2hlZC9tYWxpY2lvdXMgZ3Vlc3QgZHJpdmVyLg0KPiANCj4gUmVnYXJkcywNCj4gRGFu
aWVsDQoNClJlYWxseSwgIHRoYW5rcyBhIGxvdCENCg0KTGlhbmcNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
