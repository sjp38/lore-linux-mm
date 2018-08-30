Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 556436B533D
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 16:28:21 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d22-v6so5379218pfn.3
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 13:28:21 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id bd6-v6si7051108plb.265.2018.08.30.13.28.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 13:28:20 -0700 (PDT)
From: "Verma, Vishal L" <vishal.l.verma@intel.com>
Subject: Re: [PATCH] mm: fix BUG_ON() in vmf_insert_pfn_pud() from
 VM_MIXEDMAP removal
Date: Thu, 30 Aug 2018 20:28:02 +0000
Message-ID: <1535660881.5995.74.camel@intel.com>
References: <153565957352.35524.1005746906902065126.stgit@djiang5-desk3.ch.intel.com>
In-Reply-To: <153565957352.35524.1005746906902065126.stgit@djiang5-desk3.ch.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <3623506BAFE2C247AD5BDA047AAF347C@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Jiang, Dave" <dave.jiang@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "Williams, Dan J" <dan.j.williams@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "jack@suse.com" <jack@suse.com>

DQpPbiBUaHUsIDIwMTgtMDgtMzAgYXQgMTM6MDYgLTA3MDAsIERhdmUgSmlhbmcgd3JvdGU6DQo+
IEl0IGxvb2tzIGxpa2UgSSBtaXNzZWQgdGhlIFBVRCBwYXRoIHdoZW4gZG9pbmcgVk1fTUlYRURN
QVAgcmVtb3ZhbC4NCj4gVGhpcyBjYW4gYmUgdHJpZ2dlcmVkIGJ5Og0KPiAxLiBCb290IHdpdGgg
bWVtbWFwPTRHIThHDQo+IDIuIGJ1aWxkIG5kY3RsIHdpdGggZGVzdHJ1Y3RpdmUgZmxhZyBvbg0K
PiAzLiBtYWtlIFRFU1RTPWRldmljZS1kYXggY2hlY2sNCj4gDQo+IFsgICswLjAwMDY3NV0ga2Vy
bmVsIEJVRyBhdCBtbS9odWdlX21lbW9yeS5jOjgyNCENCj4gDQo+IEFwcGx5aW5nIHRoZSBzYW1l
IGNoYW5nZSB0aGF0IHdhcyBhcHBsaWVkIHRvIHZtZl9pbnNlcnRfcGZuX3BtZCgpIGluDQo+IHRo
ZQ0KPiBvcmlnaW5hbCBwYXRjaC4NCj4gDQo+IEZpeGVzOiBlMWZiNGEwODY0OSAoImRheDogcmVt
b3ZlIFZNX01JWEVETUFQIGZvciBmc2RheCBhbmQgZGV2aWNlDQo+IGRheCIpDQo+IA0KPiBSZXBv
cnRlZC1ieTogVmlzaGFsIFZlcm1hIDx2aXNoYWwubC52ZXJtYUBpbnRlbC5jb20+DQo+IFNpZ25l
ZC1vZmYtYnk6IERhdmUgSmlhbmcgPGRhdmUuamlhbmdAaW50ZWwuY29tPg0KPiAtLS0NCj4gIG1t
L2h1Z2VfbWVtb3J5LmMgfCAgICA0ICsrLS0NCj4gIDEgZmlsZSBjaGFuZ2VkLCAyIGluc2VydGlv
bnMoKyksIDIgZGVsZXRpb25zKC0pDQoNClRoaXMgZml4ZXMgdGhlIHVuaXQgdGVzdCBmYWlsdXJl
LCBmZWVsIGZyZWUgdG8gYWRkOg0KVGVzdGVkLWJ5OiBWaXNoYWwgVmVybWEgPHZpc2hhbC5sLnZl
cm1hQGludGVsLmNvbT4NCg0KPiANCj4gZGlmZiAtLWdpdCBhL21tL2h1Z2VfbWVtb3J5LmMgYi9t
bS9odWdlX21lbW9yeS5jDQo+IGluZGV4IGMzYmM3ZTljOWEyYS4uNTMzZjliMDAxNDdkIDEwMDY0
NA0KPiAtLS0gYS9tbS9odWdlX21lbW9yeS5jDQo+ICsrKyBiL21tL2h1Z2VfbWVtb3J5LmMNCj4g
QEAgLTgyMSwxMSArODIxLDExIEBAIHZtX2ZhdWx0X3Qgdm1mX2luc2VydF9wZm5fcHVkKHN0cnVj
dA0KPiB2bV9hcmVhX3N0cnVjdCAqdm1hLCB1bnNpZ25lZCBsb25nIGFkZHIsDQo+ICAJICogYnV0
IHdlIG5lZWQgdG8gYmUgY29uc2lzdGVudCB3aXRoIFBURXMgYW5kIGFyY2hpdGVjdHVyZXMNCj4g
dGhhdA0KPiAgCSAqIGNhbid0IHN1cHBvcnQgYSAnc3BlY2lhbCcgYml0Lg0KPiAgCSAqLw0KPiAt
CUJVR19PTighKHZtYS0+dm1fZmxhZ3MgJiAoVk1fUEZOTUFQfFZNX01JWEVETUFQKSkpOw0KPiAr
CUJVR19PTighKHZtYS0+dm1fZmxhZ3MgJiAoVk1fUEZOTUFQfFZNX01JWEVETUFQKSkgJiYNCj4g
KwkJCSFwZm5fdF9kZXZtYXAocGZuKSk7DQo+ICAJQlVHX09OKCh2bWEtPnZtX2ZsYWdzICYgKFZN
X1BGTk1BUHxWTV9NSVhFRE1BUCkpID09DQo+ICAJCQkJCQkoVk1fUEZOTUFQfFZNX01JWEVETQ0K
PiBBUCkpOw0KPiAgCUJVR19PTigodm1hLT52bV9mbGFncyAmIFZNX1BGTk1BUCkgJiYgaXNfY293
X21hcHBpbmcodm1hLQ0KPiA+dm1fZmxhZ3MpKTsNCj4gLQlCVUdfT04oIXBmbl90X2Rldm1hcChw
Zm4pKTsNCj4gIA0KPiAgCWlmIChhZGRyIDwgdm1hLT52bV9zdGFydCB8fCBhZGRyID49IHZtYS0+
dm1fZW5kKQ0KPiAgCQlyZXR1cm4gVk1fRkFVTFRfU0lHQlVTOw0KPiANCg==
