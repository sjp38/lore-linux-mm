Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id CF5B46B0035
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 18:09:55 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id et14so4276632pad.30
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 15:09:55 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id zp8si9075187pac.130.2014.08.28.15.09.54
        for <linux-mm@kvack.org>;
        Thu, 28 Aug 2014 15:09:54 -0700 (PDT)
From: "Zwisler, Ross" <ross.zwisler@intel.com>
Subject: Re: [PATCH v10 00/21] Support ext4 on NV-DIMMs
Date: Thu, 28 Aug 2014 22:09:45 +0000
Message-ID: <1409263783.27285.7.camel@rzwisler-mobl1.amr.corp.intel.com>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
	 <53FEE379.9060204@gmail.com>
In-Reply-To: <53FEE379.9060204@gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <A9DC40E375DCAF47BEAC93C3D4371464@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "openosd@gmail.com" <openosd@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "willy@linux.intel.com" <willy@linux.intel.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

T24gVGh1LCAyMDE0LTA4LTI4IGF0IDExOjA4ICswMzAwLCBCb2F6IEhhcnJvc2ggd3JvdGU6DQo+
IE9uIDA4LzI3LzIwMTQgMDY6NDUgQU0sIE1hdHRoZXcgV2lsY294IHdyb3RlOg0KPiA+IE9uZSBv
ZiB0aGUgcHJpbWFyeSB1c2VzIGZvciBOVi1ESU1NcyBpcyB0byBleHBvc2UgdGhlbSBhcyBhIGJs
b2NrIGRldmljZQ0KPiA+IGFuZCB1c2UgYSBmaWxlc3lzdGVtIHRvIHN0b3JlIGZpbGVzIG9uIHRo
ZSBOVi1ESU1NLiAgV2hpbGUgdGhhdCB3b3JrcywNCj4gPiBpdCBjdXJyZW50bHkgd2FzdGVzIG1l
bW9yeSBhbmQgQ1BVIHRpbWUgYnVmZmVyaW5nIHRoZSBmaWxlcyBpbiB0aGUgcGFnZQ0KPiA+IGNh
Y2hlLiAgV2UgaGF2ZSBzdXBwb3J0IGluIGV4dDIgZm9yIGJ5cGFzc2luZyB0aGUgcGFnZSBjYWNo
ZSwgYnV0IGl0DQo+ID4gaGFzIHNvbWUgcmFjZXMgd2hpY2ggYXJlIHVuZml4YWJsZSBpbiB0aGUg
Y3VycmVudCBkZXNpZ24uICBUaGlzIHNlcmllcw0KPiA+IG9mIHBhdGNoZXMgcmV3cml0ZSB0aGUg
dW5kZXJseWluZyBzdXBwb3J0LCBhbmQgYWRkIHN1cHBvcnQgZm9yIGRpcmVjdA0KPiA+IGFjY2Vz
cyB0byBleHQ0Lg0KPiA+IA0KPiA+IE5vdGUgdGhhdCBwYXRjaCA2LzIxIGhhcyBiZWVuIGluY2x1
ZGVkIGluDQo+ID4gaHR0cHM6Ly9naXQua2VybmVsLm9yZy9jZ2l0L2xpbnV4L2tlcm5lbC9naXQv
dmlyby92ZnMuZ2l0L2xvZy8/aD1mb3ItbmV4dC1jYW5kaWRhdGUNCj4gPiANCj4gDQo+IE1hdHRo
ZXcgaGkNCj4gDQo+IENvdWxkIHlvdSBwbGVhc2UgcHVzaCB0aGlzIHRvIHRoZSByZWd1bGFyIG9y
IGEgbmV3IHB1YmxpYyB0cmVlPw0KPiANCj4gKE9sZCB2ZXJzaW9ucyBhcmUgYXQ6IGh0dHBzOi8v
Z2l0aHViLmNvbS8wMW9yZy9wcmQpDQo+IA0KPiBUaGFua3MNCj4gQm9heg0KDQpIaSBCb2F6LA0K
DQpJJ3ZlIHB1c2hlZCB0aGUgdXBkYXRlZCB0cmVlIHRvIGh0dHBzOi8vZ2l0aHViLmNvbS8wMW9y
Zy9wcmQgaW4gdGhlIG1hc3Rlcg0KYnJhbmNoLiAgQWxsIHRoZSBvbGRlciB2ZXJzaW9ucyBvZiB0
aGUgY29kZSB0aGF0IHdlJ3ZlIGhhZCB3aGlsZSByZWJhc2luZyBhcmUNCnN0aWxsIGF2YWlsYWJs
ZSBpbiB0aGVpciBvd24gYnJhbmNoZXMuDQoNClRoYW5rcywNCi0gUm9zcw0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
