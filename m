Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C362C8E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 16:59:21 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s11-v6so4588838pgv.9
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 13:59:21 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0126.outbound.protection.outlook.com. [104.47.41.126])
        by mx.google.com with ESMTPS id t80-v6si27269642pfk.228.2018.09.20.13.59.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 20 Sep 2018 13:59:20 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH 2/5] mm/memory_hotplug: Avoid
 node_set/clear_state(N_HIGH_MEMORY) when !CONFIG_HIGHMEM
Date: Thu, 20 Sep 2018 20:59:18 +0000
Message-ID: <e66c7d55-7145-dd6c-4b11-27893ed7a7d0@microsoft.com>
References: <20180919100819.25518-1-osalvador@techadventures.net>
 <20180919100819.25518-3-osalvador@techadventures.net>
In-Reply-To: <20180919100819.25518-3-osalvador@techadventures.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <1653609D10574F41B00EBFC6D9480070@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "david@redhat.com" <david@redhat.com>, "Jonathan.Cameron@huawei.com" <Jonathan.Cameron@huawei.com>, "yasu.isimatu@gmail.com" <yasu.isimatu@gmail.com>, "malat@debian.org" <malat@debian.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oscar Salvador <osalvador@suse.de>

DQoNCk9uIDkvMTkvMTggNjowOCBBTSwgT3NjYXIgU2FsdmFkb3Igd3JvdGU6DQo+IEZyb206IE9z
Y2FyIFNhbHZhZG9yIDxvc2FsdmFkb3JAc3VzZS5kZT4NCj4gDQo+IEN1cnJlbnRseSwgd2hlbiAh
Q09ORklHX0hJR0hNRU0sIHN0YXR1c19jaGFuZ2VfbmlkX2hpZ2ggaXMgYmVpbmcgc2V0DQo+IHRv
IHN0YXR1c19jaGFuZ2VfbmlkX25vcm1hbCwgYnV0IG9uIHN1Y2ggc3lzdGVtcyBOX0hJR0hfTUVN
T1JZIGZhbGxzDQo+IGJhY2sgdG8gTl9OT1JNQUxfTUVNT1JZLg0KPiBUaGF0IG1lYW5zIHRoYXQg
aWYgc3RhdHVzX2NoYW5nZV9uaWRfbm9ybWFsIGlzIG5vdCAtMSwNCj4gd2Ugd2lsbCBwZXJmb3Jt
IHR3byBjYWxscyB0byBub2RlX3NldF9zdGF0ZSBmb3IgdGhlIHNhbWUgbWVtb3J5IHR5cGUuDQo+
IA0KPiBTZXQgc3RhdHVzX2NoYW5nZV9uaWRfaGlnaCB0byAtMSBmb3IgIUNPTkZJR19ISUdITUVN
LCBzbyB3ZSBza2lwIHRoZQ0KPiBkb3VibGUgY2FsbCBpbiBub2RlX3N0YXRlc19zZXRfbm9kZS4N
Cj4gDQo+IFRoZSBzYW1lIGdvZXMgZm9yIG5vZGVfY2xlYXJfc3RhdGUuDQo+IA0KPiBTaWduZWQt
b2ZmLWJ5OiBPc2NhciBTYWx2YWRvciA8b3NhbHZhZG9yQHN1c2UuZGU+DQoNClJldmlld2VkLWJ5
OiBQYXZlbCBUYXRhc2hpbiA8cGF2ZWwudGF0YXNoaW5AbWljcm9zb2Z0LmNvbT4NCg0KVGhpcyBp
cyBhIHJhcmUgY2FzZSB3aGVyZSBJIHRoaW5rIGNvbW1lbnRzIGFyZSB1bm5lY2Vzc2FyeSBhcyB0
aGUgY29kZQ0KaXMgc2VsZiBleHBsYW5hdG9yeS4gU28sIEkgd291bGQgcmVtb3ZlIHRoZSBjb21t
ZW50cyBiZWZvcmU6DQoNCj4gKwlhcmctPnN0YXR1c19jaGFuZ2VfbmlkX2hpZ2ggPSAtMTsNCg0K
UGF2ZWwNCg0KPiAtLS0NCj4gIG1tL21lbW9yeV9ob3RwbHVnLmMgfCAxMiArKysrKysrKysrLS0N
Cj4gIDEgZmlsZSBjaGFuZ2VkLCAxMCBpbnNlcnRpb25zKCspLCAyIGRlbGV0aW9ucygtKQ0KPiAN
Cj4gZGlmZiAtLWdpdCBhL21tL21lbW9yeV9ob3RwbHVnLmMgYi9tbS9tZW1vcnlfaG90cGx1Zy5j
DQo+IGluZGV4IDYzZmFjZmM1NzIyNC4uYzJjNzM1OWJkMGE3IDEwMDY0NA0KPiAtLS0gYS9tbS9t
ZW1vcnlfaG90cGx1Zy5jDQo+ICsrKyBiL21tL21lbW9yeV9ob3RwbHVnLmMNCj4gQEAgLTczMSw3
ICs3MzEsMTEgQEAgc3RhdGljIHZvaWQgbm9kZV9zdGF0ZXNfY2hlY2tfY2hhbmdlc19vbmxpbmUo
dW5zaWduZWQgbG9uZyBucl9wYWdlcywNCj4gIAllbHNlDQo+ICAJCWFyZy0+c3RhdHVzX2NoYW5n
ZV9uaWRfaGlnaCA9IC0xOw0KPiAgI2Vsc2UNCj4gLQlhcmctPnN0YXR1c19jaGFuZ2VfbmlkX2hp
Z2ggPSBhcmctPnN0YXR1c19jaGFuZ2VfbmlkX25vcm1hbDsNCj4gKwkvKg0KPiArCSAqIFdoZW4g
IUNPTkZJR19ISUdITUVNLCBOX0hJR0hfTUVNT1JZIGVxdWFscyBOX05PUk1BTF9NRU1PUlkNCj4g
KwkgKiBzbyBzZXR0aW5nIHRoZSBub2RlIGZvciBOX05PUk1BTF9NRU1PUlkgaXMgZW5vdWdoLg0K
PiArCSAqLw0KPiArCWFyZy0+c3RhdHVzX2NoYW5nZV9uaWRfaGlnaCA9IC0xOw0KPiAgI2VuZGlm
DQo+ICANCj4gIAkvKg0KPiBAQCAtMTU1NSw3ICsxNTU5LDExIEBAIHN0YXRpYyB2b2lkIG5vZGVf
c3RhdGVzX2NoZWNrX2NoYW5nZXNfb2ZmbGluZSh1bnNpZ25lZCBsb25nIG5yX3BhZ2VzLA0KPiAg
CWVsc2UNCj4gIAkJYXJnLT5zdGF0dXNfY2hhbmdlX25pZF9oaWdoID0gLTE7DQo+ICAjZWxzZQ0K
PiAtCWFyZy0+c3RhdHVzX2NoYW5nZV9uaWRfaGlnaCA9IGFyZy0+c3RhdHVzX2NoYW5nZV9uaWRf
bm9ybWFsOw0KPiArCS8qDQo+ICsJICogV2hlbiAhQ09ORklHX0hJR0hNRU0sIE5fSElHSF9NRU1P
UlkgZXF1YWxzIE5fTk9STUFMX01FTU9SWQ0KPiArCSAqIHNvIGNsZWFyaW5nIHRoZSBub2RlIGZv
ciBOX05PUk1BTF9NRU1PUlkgaXMgZW5vdWdoLg0KPiArCSAqLw0KPiArCWFyZy0+c3RhdHVzX2No
YW5nZV9uaWRfaGlnaCA9IC0xOw0KPiAgI2VuZGlmDQo+ICANCj4gIAkvKg0KPiA=
