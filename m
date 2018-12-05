Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D0DA6B71B2
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 20:22:47 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b8so15475803pfe.10
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 17:22:47 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-eopbgr760073.outbound.protection.outlook.com. [40.107.76.73])
        by mx.google.com with ESMTPS id d2si19737175plh.426.2018.12.04.17.22.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 04 Dec 2018 17:22:46 -0800 (PST)
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Subject: Re: [RFC PATCH 00/14] Heterogeneous Memory System (HMS) and hbind()
Date: Wed, 5 Dec 2018 01:22:41 +0000
Message-ID: <6960db38-3e40-d58c-c9a0-7e2fe259cac5@amd.com>
References: <20181203233509.20671-1-jglisse@redhat.com>
 <9d745b99-22e3-c1b5-bf4f-d3e83113f57b@intel.com>
 <20181204184919.GD2937@redhat.com>
 <20163c1e-00f1-7e02-82c0-7730ceabb9f2@intel.com>
 <20181204215711.GP2937@redhat.com>
In-Reply-To: <20181204215711.GP2937@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <80C2C78E879335428B6712D4691BFAF2@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Rafael J . Wysocki" <rafael@kernel.org>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Keith Busch <keith.busch@intel.com>, Dan Williams <dan.j.williams@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Yang, Philip" <Philip.Yang@amd.com>, Koenig,, Paul  <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@surriel.com>, Ben Woodard <woodard@redhat.com>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>

DQpPbiAyMDE4LTEyLTA0IDQ6NTcgcC5tLiwgSmVyb21lIEdsaXNzZSB3cm90ZToNCj4gT24gVHVl
LCBEZWMgMDQsIDIwMTggYXQgMDE6Mzc6NTZQTSAtMDgwMCwgRGF2ZSBIYW5zZW4gd3JvdGU6DQo+
PiBZZWFoLCBvdXIgTlVNQSBtZWNoYW5pc21zIGFyZSBmb3IgbWFuYWdpbmcgbWVtb3J5IHRoYXQg
dGhlIGtlcm5lbCBpdHNlbGYNCj4+IG1hbmFnZXMgaW4gdGhlICJub3JtYWwiIGFsbG9jYXRvciBh
bmQgc3VwcG9ydHMgYSBmdWxsIGZlYXR1cmUgc2V0IG9uLg0KPj4gVGhhdCBoYXMgYSBidW5jaCBv
ZiBpbXBsaWNhdGlvbnMsIGxpa2UgdGhhdCB0aGUgbWVtb3J5IGlzIGNhY2hlIGNvaGVyZW50DQo+
PiBhbmQgYWNjZXNzaWJsZSBmcm9tIGV2ZXJ5d2hlcmUuDQo+Pg0KPj4gVGhlIEhNQVQgcGF0Y2hl
cyBvbmx5IGNvbXByZWhlbmQgdGhpcyAibm9ybWFsIiBtZW1vcnksIHdoaWNoIGlzIHdoeQ0KPj4g
d2UncmUgZXh0ZW5kaW5nIHRoZSBleGlzdGluZyAvc3lzL2RldmljZXMvc3lzdGVtL25vZGUgaW5m
cmFzdHJ1Y3R1cmUuDQo+Pg0KPj4gVGhpcyBzZXJpZXMgaGFzIGEgbXVjaCBtb3JlIGFnZ3Jlc3Np
dmUgZ29hbCwgd2hpY2ggaXMgY29tcHJlaGVuZGluZyB0aGUNCj4+IGNvbm5lY3Rpb25zIG9mIGV2
ZXJ5IG1lbW9yeS10YXJnZXQgdG8gZXZlcnkgbWVtb3J5LWluaXRpYXRvciwgbm8gbWF0dGVyDQo+
PiB3aG8gaXMgbWFuYWdpbmcgdGhlIG1lbW9yeSwgd2hvIGNhbiBhY2Nlc3MgaXQsIG9yIHdoYXQg
aXQgY2FuIGJlIHVzZWQgZm9yLg0KPj4NCj4+IFRoZW9yZXRpY2FsbHksIEhNUyBjb3VsZCBiZSB1
c2VkIGZvciBldmVyeXRoaW5nIHRoYXQgd2UncmUgZG9pbmcgd2l0aA0KPj4gL3N5cy9kZXZpY2Vz
L3N5c3RlbS9ub2RlLCBhcyBsb25nIGFzIGl0J3MgdGllZCBiYWNrIGludG8gdGhlIGV4aXN0aW5n
DQo+PiBOVU1BIGluZnJhc3RydWN0dXJlIF9zb21laG93Xy4NCj4+DQo+PiBSaWdodD8NCj4gRnVs
bHkgY29ycmVjdCBtaW5kIGlmIGkgc3RlYWwgdGhhdCBwZXJmZWN0IHN1bW1hcnkgZGVzY3JpcHRp
b24gbmV4dCB0aW1lDQo+IGkgcG9zdCA/IEkgYW0gc28gYmFkIGF0IGV4cGxhaW5pbmcgdGhpbmcg
OikNCj4NCj4gSW50ZW50aW9uIGlzIHRvIGFsbG93IHByb2dyYW0gdG8gZG8gZXZlcnl0aGluZyB0
aGV5IGRvIHdpdGggbWJpbmQoKSB0b2RheQ0KPiBhbmQgdG9tb3Jyb3cgd2l0aCB0aGUgSE1BVCBw
YXRjaHNldCBhbmQgb24gdG9wIG9mIHRoYXQgdG8gYWxzbyBiZSBhYmxlIHRvDQo+IGRvIHdoYXQg
dGhleSBkbyB0b2RheSB0aHJvdWdoIEFQSSBsaWtlIE9wZW5DTCwgUk9DbSwgQ1VEQSAuLi4gU28g
aXQgaXMgb25lDQo+IGtlcm5lbCBBUEkgdG8gcnVsZSB0aGVtIGFsbCA7KQ0KDQpBcyBmb3IgUk9D
bSwgSSdtIGxvb2tpbmcgZm9yd2FyZCB0byB1c2luZyBoYmluZCBpbiBvdXIgb3duIEFQSXMuIEl0
IHdpbGwNCnNhdmUgdXMgc29tZSB0aW1lIGFuZCB0cm91YmxlIG5vdCBoYXZpbmcgdG8gaW1wbGVt
ZW50IGFsbCB0aGUgbG93LWxldmVsDQpwb2xpY3kgYW5kIHRyYWNraW5nIG9mIHZpcnR1YWwgYWRk
cmVzcyByYW5nZXMgaW4gb3VyIGRldmljZSBkcml2ZXIuDQpHb2luZyBmb3J3YXJkLCBoYXZpbmcg
YSBjb21tb24gQVBJIHRvIG1hbmFnZSB0aGUgdG9wb2xvZ3kgYW5kIG1lbW9yeQ0KYWZmaW5pdHkg
d291bGQgYWxzbyBlbmFibGUgc2FuZSB3YXlzIG9mIGhhdmluZyBhY2NlbGVyYXRvcnMgYW5kIG1l
bW9yeQ0KZGV2aWNlcyBmcm9tIGRpZmZlcmVudCB2ZW5kb3JzIGludGVyYWN0IHVuZGVyIGNvbnRy
b2wgb2YgYQ0KdG9wb2xvZ3ktYXdhcmUgYXBwbGljYXRpb24uDQoNCkRpc2NsYWltZXI6IEkgaGF2
ZW4ndCBoYWQgYSBjaGFuY2UgdG8gcmV2aWV3IHRoZSBwYXRjaGVzIGluIGRldGFpbCB5ZXQuDQpH
b3QgY2F1Z2h0IHVwIGluIHRoZSBkb2N1bWVudGF0aW9uIGFuZCBkaXNjdXNzaW9uIC4uLg0KDQpS
ZWdhcmRzLA0KwqAgRmVsaXgNCg0KDQo+DQo+IEFsc28gYXQgZmlyc3QgaSBpbnRlbmQgdG8gc3Bl
Y2lhbCBjYXNlIHZtYSBhbGxvYyBwYWdlIHdoZW4gdGhleSBhcmUgSE1TDQo+IHBvbGljeSwgbG9u
ZyB0ZXJtIGkgd291bGQgbGlrZSB0byBtZXJnZSBjb2RlIHBhdGggaW5zaWRlIHRoZSBrZXJuZWwu
IEJ1dA0KPiBpIGRvIG5vdCB3YW50IHRvIGRpc3J1cHQgZXhpc3RpbmcgY29kZSBwYXRoIHRvZGF5
LCBpIHJhdGhlciBncm93IHRvIHRoYXQNCj4gb3JnYW5pY2FseS4gU3RlcCBieSBzdGVwLiBUaGUg
bWJpbmQoKSB3b3VsZCBzdGlsbCB3b3JrIHVuLWFmZmVjdGVkIGluDQo+IHRoZSBlbmQganVzdCB0
aGUgcGx1bWJpbmcgd291bGQgYmUgc2xpZ2h0bHkgZGlmZmVyZW50Lg0KPg0KPiBDaGVlcnMsDQo+
IErDqXLDtG1lDQo=
