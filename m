Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C32FB6B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 16:01:32 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fe3so105461546pab.1
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 13:01:32 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ln6si6900783pab.182.2016.03.28.13.01.31
        for <linux-mm@kvack.org>;
        Mon, 28 Mar 2016 13:01:31 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH 4/5] dax: use sb_issue_zerout instead of calling
 dax_clear_sectors
Date: Mon, 28 Mar 2016 20:01:29 +0000
Message-ID: <1459195288.15523.3.camel@intel.com>
References: <1458861450-17705-1-git-send-email-vishal.l.verma@intel.com>
	 <1458861450-17705-5-git-send-email-vishal.l.verma@intel.com>
	 <CAPcyv4iKK=1Nhz4QqEkhc4gum+UvUS4a=+Sza2zSa1Kyrth41w@mail.gmail.com>
	 <1458939796.5501.8.camel@intel.com>
	 <CAPcyv4jWqVcav7dQPh7WHpqB6QDrCezO5jbd9QW9xH3zsU4C1w@mail.gmail.com>
In-Reply-To: <CAPcyv4jWqVcav7dQPh7WHpqB6QDrCezO5jbd9QW9xH3zsU4C1w@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <59E72D7F52648141A4EC0A334887F2DC@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Cc: "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "axboe@fb.com" <axboe@fb.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew
 R" <matthew.r.wilcox@intel.com>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

T24gRnJpLCAyMDE2LTAzLTI1IGF0IDE0OjIwIC0wNzAwLCBEYW4gV2lsbGlhbXMgd3JvdGU6DQo+
IE9uIEZyaSwgTWFyIDI1LCAyMDE2IGF0IDI6MDMgUE0sIFZlcm1hLCBWaXNoYWwgTA0KPiA8dmlz
aGFsLmwudmVybWFAaW50ZWwuY29tPiB3cm90ZToNCj4gPiANCj4gPiBPbiBGcmksIDIwMTYtMDMt
MjUgYXQgMTE6NDcgLTA3MDAsIERhbiBXaWxsaWFtcyB3cm90ZToNCj4gPiA+IA0KPiA+ID4gT24g
VGh1LCBNYXIgMjQsIDIwMTYgYXQgNDoxNyBQTSwgVmlzaGFsIFZlcm1hIDx2aXNoYWwubC52ZXJt
YUBpbnQNCj4gPiA+IGVsLmMNCj4gPiA+IG9tPiB3cm90ZToNCj4gPiA+ID4gDQo+ID4gPiA+IA0K
PiA+ID4gPiBGcm9tOiBNYXR0aGV3IFdpbGNveCA8bWF0dGhldy5yLndpbGNveEBpbnRlbC5jb20+
DQo+ID4gPiA+IA0KPiA+ID4gPiBkYXhfY2xlYXJfc2VjdG9ycygpIGNhbm5vdCBoYW5kbGUgcG9p
c29uZWQgYmxvY2tzLsKgwqBUaGVzZSBtdXN0DQo+ID4gPiA+IGJlDQo+ID4gPiA+IHplcm9lZCB1
c2luZyB0aGUgQklPIGludGVyZmFjZSBpbnN0ZWFkLsKgwqBDb252ZXJ0IGV4dDIgYW5kIFhGUw0K
PiA+ID4gPiB0bw0KPiA+ID4gPiB1c2UNCj4gPiA+ID4gb25seSBzYl9pc3N1ZV96ZXJvdXQoKS4N
Cj4gPiA+ID4gDQo+ID4gPiA+IFNpZ25lZC1vZmYtYnk6IE1hdHRoZXcgV2lsY294IDxtYXR0aGV3
LnIud2lsY294QGludGVsLmNvbT4NCj4gPiA+ID4gW3Zpc2hhbDogQWxzbyByZW1vdmUgdGhlIGRh
eF9jbGVhcl9zZWN0b3JzIGZ1bmN0aW9uIGVudGlyZWx5XQ0KPiA+ID4gPiBTaWduZWQtb2ZmLWJ5
OiBWaXNoYWwgVmVybWEgPHZpc2hhbC5sLnZlcm1hQGludGVsLmNvbT4NCj4gPiA+ID4gLS0tDQo+
ID4gPiA+IMKgZnMvZGF4LmPCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqB8IDMyIC0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQo+ID4gPiA+IMKgZnMvZXh0Mi9pbm9kZS5jwqDC
oMKgwqDCoMKgwqDCoHzCoMKgNyArKystLS0tDQo+ID4gPiA+IMKgZnMveGZzL3hmc19ibWFwX3V0
aWwuYyB8wqDCoDkgLS0tLS0tLS0tDQo+ID4gPiA+IMKgaW5jbHVkZS9saW51eC9kYXguaMKgwqDC
oMKgfMKgwqAxIC0NCj4gPiA+ID4gwqA0IGZpbGVzIGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwg
NDYgZGVsZXRpb25zKC0pDQo+ID4gPiA+IA0KPiA+ID4gPiBkaWZmIC0tZ2l0IGEvZnMvZGF4LmMg
Yi9mcy9kYXguYw0KPiA+ID4gPiBpbmRleCBiYjdlOWY4Li5hMzA0ODFlIDEwMDY0NA0KPiA+ID4g
PiAtLS0gYS9mcy9kYXguYw0KPiA+ID4gPiArKysgYi9mcy9kYXguYw0KPiA+ID4gPiBAQCAtNzgs
MzggKzc4LDYgQEAgc3RydWN0IHBhZ2UgKnJlYWRfZGF4X3NlY3RvcihzdHJ1Y3QNCj4gPiA+ID4g
YmxvY2tfZGV2aWNlDQo+ID4gPiA+ICpiZGV2LCBzZWN0b3JfdCBuKQ0KPiA+ID4gPiDCoMKgwqDC
oMKgwqDCoMKgcmV0dXJuIHBhZ2U7DQo+ID4gPiA+IMKgfQ0KPiA+ID4gPiANCj4gPiA+ID4gLS8q
DQo+ID4gPiA+IC0gKiBkYXhfY2xlYXJfc2VjdG9ycygpIGlzIGNhbGxlZCBmcm9tIHdpdGhpbiB0
cmFuc2FjdGlvbg0KPiA+ID4gPiBjb250ZXh0DQo+ID4gPiA+IGZyb20gWEZTLA0KPiA+ID4gPiAt
ICogYW5kIGhlbmNlIHRoaXMgbWVhbnMgdGhlIHN0YWNrIGZyb20gdGhpcyBwb2ludCBtdXN0IGZv
bGxvdw0KPiA+ID4gPiBHRlBfTk9GUw0KPiA+ID4gPiAtICogc2VtYW50aWNzIGZvciBhbGwgb3Bl
cmF0aW9ucy4NCj4gPiA+ID4gLSAqLw0KPiA+ID4gPiAtaW50IGRheF9jbGVhcl9zZWN0b3JzKHN0
cnVjdCBibG9ja19kZXZpY2UgKmJkZXYsIHNlY3Rvcl90DQo+ID4gPiA+IF9zZWN0b3IsDQo+ID4g
PiA+IGxvbmcgX3NpemUpDQo+ID4gPiA+IC17DQo+ID4gPiA+IC3CoMKgwqDCoMKgwqDCoHN0cnVj
dCBibGtfZGF4X2N0bCBkYXggPSB7DQo+ID4gPiA+IC3CoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqAuc2VjdG9yID0gX3NlY3RvciwNCj4gPiA+ID4gLcKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoC5zaXplID0gX3NpemUsDQo+ID4gPiA+IC3CoMKgwqDCoMKgwqDCoH07DQo+ID4gPiA+
IC0NCj4gPiA+ID4gLcKgwqDCoMKgwqDCoMKgbWlnaHRfc2xlZXAoKTsNCj4gPiA+ID4gLcKgwqDC
oMKgwqDCoMKgZG8gew0KPiA+ID4gPiAtwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgbG9u
ZyBjb3VudCwgc3o7DQo+ID4gPiA+IC0NCj4gPiA+ID4gLcKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoGNvdW50ID0gZGF4X21hcF9hdG9taWMoYmRldiwgJmRheCk7DQo+ID4gPiA+IC3CoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqBpZiAoY291bnQgPCAwKQ0KPiA+ID4gPiAtwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoHJldHVybiBjb3VudDsNCj4g
PiA+ID4gLcKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoHN6ID0gbWluX3QobG9uZywgY291
bnQsIFNaXzEyOEspOw0KPiA+ID4gPiAtwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgY2xl
YXJfcG1lbShkYXguYWRkciwgc3opOw0KPiA+ID4gPiAtwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgZGF4LnNpemUgLT0gc3o7DQo+ID4gPiA+IC3CoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqBkYXguc2VjdG9yICs9IHN6IC8gNTEyOw0KPiA+ID4gPiAtwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgZGF4X3VubWFwX2F0b21pYyhiZGV2LCAmZGF4KTsNCj4gPiA+ID4gLcKgwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoGNvbmRfcmVzY2hlZCgpOw0KPiA+ID4gPiAtwqDCoMKg
wqDCoMKgwqB9IHdoaWxlIChkYXguc2l6ZSk7DQo+ID4gPiA+IC0NCj4gPiA+ID4gLcKgwqDCoMKg
wqDCoMKgd21iX3BtZW0oKTsNCj4gPiA+ID4gLcKgwqDCoMKgwqDCoMKgcmV0dXJuIDA7DQo+ID4g
PiA+IC19DQo+ID4gPiA+IC1FWFBPUlRfU1lNQk9MX0dQTChkYXhfY2xlYXJfc2VjdG9ycyk7DQo+
ID4gPiBXaGF0IGFib3V0IHRoZSBvdGhlciB1bndyaXR0ZW4gZXh0ZW50IGNvbnZlcnNpb25zIGlu
IHRoZSBkYXgNCj4gPiA+IHBhdGg/DQo+ID4gPiBTaG91bGRuJ3QgdGhvc2UgYmUgY29udmVydGVk
IHRvIGJsb2NrLWxheWVyIHplcm8tb3V0cyBhcyB3ZWxsPw0KPiA+IENvdWxkIHlvdSBwb2ludCBt
ZSB0byB3aGVyZSB0aGVzZSBtaWdodCBiZT8gSSB0aG91Z2h0IG9uY2Ugd2UndmUNCj4gPiBjb252
ZXJ0ZWQgYWxsIHRoZSB6ZXJvb3V0IHR5cGUgY2FsbGVycyAoYnkgcmVtb3ZpbmcNCj4gPiBkYXhf
Y2xlYXJfc2VjdG9ycyksDQo+ID4gYW5kIGZpeGVkIHVwIGRheF9kb19pbyB0byB0cnkgYSBkcml2
ZXIgZmFsbGJhY2ssIHdlJ3ZlIGhhbmRsZWQgYWxsDQo+ID4gdGhlDQo+ID4gbWVkaWEgZXJyb3Ig
Y2FzZXMgaW4gZGF4Li4NCj4gZ3JlcCBmb3IgdXNhZ2VzIG9mIGNsZWFyX3BtZW0oKS4uLiB3aGlj
aCBJIHdhcyBob3BpbmcgdG8gZWxpbWluYXRlDQo+IGFmdGVyIHRoaXMgY2hhbmdlIHRvIHB1c2gg
emVyb2luZyBkb3duIHRvIHRoZSBkcml2ZXIuDQoNCk9rLCBzbyBJIGxvb2tlZCBhdCB0aGVzZSwg
YW5kIGl0IGxvb2tzIGxpa2UgdGhlIG1ham9yaXR5IG9mIGNhbGxlcnMgb2YNCmNsZWFyX3BtZW0g
YXJlIGZyb20gdGhlIGZhdWx0IHBhdGggKGVpdGhlciBwbWQgb3IgcmVndWxhciksIGFuZCBpbg0K
dGhvc2UgY2FzZXMgd2Ugc2hvdWxkIGJlICdwcm90ZWN0ZWQnLCBhcyB3ZSB3b3VsZCBoYXZlIGZh
aWxlZCBhdCBhDQpwcmlvciBzdGVwIChkYXhfbWFwX2F0b21pYykuDQoNClRoZSB0d28gY2FzZXMg
dGhhdCBtYXkgbm90IGJlIHdlbGwgaGFuZGxlZCBhcmUgdGhlIGNhbGxzIHRvDQpkYXhfemVyb19w
YWdlX3JhbmdlIGFuZCBkYXhfdHJ1bmNhdGVfcGFnZSB3aGljaCBhcmUgY2FsbGVkIGZyb20gZmls
ZQ0Kc3lzdGVtcy4gSSB0aGluayB3ZSBtYXkgbmVlZCB0byBkbyBhIGZhbGxiYWNrIHRvIHRoZSBk
cml2ZXIgZm9yIHRob3NlDQpjYXNlcyBqdXN0IGxpa2Ugd2UgZG8gZm9yIGRheF9kaXJlY3RfaW8u
LiBUaG91Z2h0cz8=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
