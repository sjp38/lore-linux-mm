Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 40C9E6B025E
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 17:03:22 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id fe3so53176184pab.1
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 14:03:22 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id sk6si674464pab.138.2016.03.25.14.03.21
        for <linux-mm@kvack.org>;
        Fri, 25 Mar 2016 14:03:21 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH 4/5] dax: use sb_issue_zerout instead of calling
 dax_clear_sectors
Date: Fri, 25 Mar 2016 21:03:19 +0000
Message-ID: <1458939796.5501.8.camel@intel.com>
References: <1458861450-17705-1-git-send-email-vishal.l.verma@intel.com>
	 <1458861450-17705-5-git-send-email-vishal.l.verma@intel.com>
	 <CAPcyv4iKK=1Nhz4QqEkhc4gum+UvUS4a=+Sza2zSa1Kyrth41w@mail.gmail.com>
In-Reply-To: <CAPcyv4iKK=1Nhz4QqEkhc4gum+UvUS4a=+Sza2zSa1Kyrth41w@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <908F3F139AEC484E8BF8AC328A859865@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Cc: "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "axboe@fb.com" <axboe@fb.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

T24gRnJpLCAyMDE2LTAzLTI1IGF0IDExOjQ3IC0wNzAwLCBEYW4gV2lsbGlhbXMgd3JvdGU6DQo+
IE9uIFRodSwgTWFyIDI0LCAyMDE2IGF0IDQ6MTcgUE0sIFZpc2hhbCBWZXJtYSA8dmlzaGFsLmwu
dmVybWFAaW50ZWwuYw0KPiBvbT4gd3JvdGU6DQo+ID4gDQo+ID4gRnJvbTogTWF0dGhldyBXaWxj
b3ggPG1hdHRoZXcuci53aWxjb3hAaW50ZWwuY29tPg0KPiA+IA0KPiA+IGRheF9jbGVhcl9zZWN0
b3JzKCkgY2Fubm90IGhhbmRsZSBwb2lzb25lZCBibG9ja3MuwqDCoFRoZXNlIG11c3QgYmUNCj4g
PiB6ZXJvZWQgdXNpbmcgdGhlIEJJTyBpbnRlcmZhY2UgaW5zdGVhZC7CoMKgQ29udmVydCBleHQy
IGFuZCBYRlMgdG8NCj4gPiB1c2UNCj4gPiBvbmx5IHNiX2lzc3VlX3plcm91dCgpLg0KPiA+IA0K
PiA+IFNpZ25lZC1vZmYtYnk6IE1hdHRoZXcgV2lsY294IDxtYXR0aGV3LnIud2lsY294QGludGVs
LmNvbT4NCj4gPiBbdmlzaGFsOiBBbHNvIHJlbW92ZSB0aGUgZGF4X2NsZWFyX3NlY3RvcnMgZnVu
Y3Rpb24gZW50aXJlbHldDQo+ID4gU2lnbmVkLW9mZi1ieTogVmlzaGFsIFZlcm1hIDx2aXNoYWwu
bC52ZXJtYUBpbnRlbC5jb20+DQo+ID4gLS0tDQo+ID4gwqBmcy9kYXguY8KgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoHwgMzIgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCj4g
PiDCoGZzL2V4dDIvaW5vZGUuY8KgwqDCoMKgwqDCoMKgwqB8wqDCoDcgKysrLS0tLQ0KPiA+IMKg
ZnMveGZzL3hmc19ibWFwX3V0aWwuYyB8wqDCoDkgLS0tLS0tLS0tDQo+ID4gwqBpbmNsdWRlL2xp
bnV4L2RheC5owqDCoMKgwqB8wqDCoDEgLQ0KPiA+IMKgNCBmaWxlcyBjaGFuZ2VkLCAzIGluc2Vy
dGlvbnMoKyksIDQ2IGRlbGV0aW9ucygtKQ0KPiA+IA0KPiA+IGRpZmYgLS1naXQgYS9mcy9kYXgu
YyBiL2ZzL2RheC5jDQo+ID4gaW5kZXggYmI3ZTlmOC4uYTMwNDgxZSAxMDA2NDQNCj4gPiAtLS0g
YS9mcy9kYXguYw0KPiA+ICsrKyBiL2ZzL2RheC5jDQo+ID4gQEAgLTc4LDM4ICs3OCw2IEBAIHN0
cnVjdCBwYWdlICpyZWFkX2RheF9zZWN0b3Ioc3RydWN0IGJsb2NrX2RldmljZQ0KPiA+ICpiZGV2
LCBzZWN0b3JfdCBuKQ0KPiA+IMKgwqDCoMKgwqDCoMKgwqByZXR1cm4gcGFnZTsNCj4gPiDCoH0N
Cj4gPiANCj4gPiAtLyoNCj4gPiAtICogZGF4X2NsZWFyX3NlY3RvcnMoKSBpcyBjYWxsZWQgZnJv
bSB3aXRoaW4gdHJhbnNhY3Rpb24gY29udGV4dA0KPiA+IGZyb20gWEZTLA0KPiA+IC0gKiBhbmQg
aGVuY2UgdGhpcyBtZWFucyB0aGUgc3RhY2sgZnJvbSB0aGlzIHBvaW50IG11c3QgZm9sbG93DQo+
ID4gR0ZQX05PRlMNCj4gPiAtICogc2VtYW50aWNzIGZvciBhbGwgb3BlcmF0aW9ucy4NCj4gPiAt
ICovDQo+ID4gLWludCBkYXhfY2xlYXJfc2VjdG9ycyhzdHJ1Y3QgYmxvY2tfZGV2aWNlICpiZGV2
LCBzZWN0b3JfdCBfc2VjdG9yLA0KPiA+IGxvbmcgX3NpemUpDQo+ID4gLXsNCj4gPiAtwqDCoMKg
wqDCoMKgwqBzdHJ1Y3QgYmxrX2RheF9jdGwgZGF4ID0gew0KPiA+IC3CoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqAuc2VjdG9yID0gX3NlY3RvciwNCj4gPiAtwqDCoMKgwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgLnNpemUgPSBfc2l6ZSwNCj4gPiAtwqDCoMKgwqDCoMKgwqB9Ow0KPiA+IC0N
Cj4gPiAtwqDCoMKgwqDCoMKgwqBtaWdodF9zbGVlcCgpOw0KPiA+IC3CoMKgwqDCoMKgwqDCoGRv
IHsNCj4gPiAtwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgbG9uZyBjb3VudCwgc3o7DQo+
ID4gLQ0KPiA+IC3CoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqBjb3VudCA9IGRheF9tYXBf
YXRvbWljKGJkZXYsICZkYXgpOw0KPiA+IC3CoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqBp
ZiAoY291bnQgPCAwKQ0KPiA+IC3CoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgcmV0dXJuIGNvdW50Ow0KPiA+IC3CoMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKg
wqBzeiA9IG1pbl90KGxvbmcsIGNvdW50LCBTWl8xMjhLKTsNCj4gPiAtwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgY2xlYXJfcG1lbShkYXguYWRkciwgc3opOw0KPiA+IC3CoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgwqBkYXguc2l6ZSAtPSBzejsNCj4gPiAtwqDCoMKgwqDCoMKgwqDC
oMKgwqDCoMKgwqDCoMKgZGF4LnNlY3RvciArPSBzeiAvIDUxMjsNCj4gPiAtwqDCoMKgwqDCoMKg
wqDCoMKgwqDCoMKgwqDCoMKgZGF4X3VubWFwX2F0b21pYyhiZGV2LCAmZGF4KTsNCj4gPiAtwqDC
oMKgwqDCoMKgwqDCoMKgwqDCoMKgwqDCoMKgY29uZF9yZXNjaGVkKCk7DQo+ID4gLcKgwqDCoMKg
wqDCoMKgfSB3aGlsZSAoZGF4LnNpemUpOw0KPiA+IC0NCj4gPiAtwqDCoMKgwqDCoMKgwqB3bWJf
cG1lbSgpOw0KPiA+IC3CoMKgwqDCoMKgwqDCoHJldHVybiAwOw0KPiA+IC19DQo+ID4gLUVYUE9S
VF9TWU1CT0xfR1BMKGRheF9jbGVhcl9zZWN0b3JzKTsNCj4gV2hhdCBhYm91dCB0aGUgb3RoZXIg
dW53cml0dGVuIGV4dGVudCBjb252ZXJzaW9ucyBpbiB0aGUgZGF4IHBhdGg/DQo+IFNob3VsZG4n
dCB0aG9zZSBiZSBjb252ZXJ0ZWQgdG8gYmxvY2stbGF5ZXIgemVyby1vdXRzIGFzIHdlbGw/DQoN
CkNvdWxkIHlvdSBwb2ludCBtZSB0byB3aGVyZSB0aGVzZSBtaWdodCBiZT8gSSB0aG91Z2h0IG9u
Y2Ugd2UndmUNCmNvbnZlcnRlZCBhbGwgdGhlIHplcm9vdXQgdHlwZSBjYWxsZXJzIChieSByZW1v
dmluZyBkYXhfY2xlYXJfc2VjdG9ycyksDQphbmQgZml4ZWQgdXAgZGF4X2RvX2lvIHRvIHRyeSBh
IGRyaXZlciBmYWxsYmFjaywgd2UndmUgaGFuZGxlZCBhbGwgdGhlDQptZWRpYSBlcnJvciBjYXNl
cyBpbiBkYXguLg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
