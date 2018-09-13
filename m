Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 377B98E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 03:28:05 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d10-v6so2288334pll.22
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 00:28:05 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 1-v6si3376043plr.326.2018.09.13.00.28.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 00:28:04 -0700 (PDT)
From: "Tian, Kevin" <kevin.tian@intel.com>
Subject: RE: [PATCH v2 01/40] iommu: Introduce Shared Virtual Addressing API
Date: Thu, 13 Sep 2018 07:26:30 +0000
Message-ID: <AADFC41AFE54684AB9EE6CBC0274A5D191301D0A@SHSMSX101.ccr.corp.intel.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
	<20180511190641.23008-2-jean-philippe.brucker@arm.com>
	<bf42affd-e9d0-e4fc-6d28-f3c3f7795348@redhat.com>
	<03d31ba5-1eda-ea86-8c0c-91d14c86fe83@arm.com>
	<ed39159c-087e-7e56-7d29-d1de9fa1677f@amd.com>
	<f0b317d5-e2e9-5478-952c-05e8b97bd68b@arm.com>
 <2fd4a0a1-1a35-bf82-df84-b995cce011d9@amd.com>
In-Reply-To: <2fd4a0a1-1a35-bf82-df84-b995cce011d9@amd.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?utf-8?B?Q2hyaXN0aWFuIEvDtm5pZw==?= <christian.koenig@amd.com>, Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, Auger Eric <eric.auger@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "Raj, Ashok" <ashok.raj@intel.com>, "rfranz@cavium.com" <rfranz@cavium.com>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "rgummal@xilinx.com" <rgummal@xilinx.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "liubo95@huawei.com" <liubo95@huawei.com>, "robin.murphy@arm.com" <robin.murphy@arm.com>

PiBGcm9tOiBDaHJpc3RpYW4gS8O2bmlnDQo+IFNlbnQ6IEZyaWRheSwgU2VwdGVtYmVyIDcsIDIw
MTggNDo1NiBQTQ0KPiANCj4gNS4gSXQgd291bGQgYmUgbmljZSB0byBoYXZlIHRvIGFsbG9jYXRl
IG11bHRpcGxlIFBBU0lEcyBmb3IgdGhlIHNhbWUNCj4gcHJvY2VzcyBhZGRyZXNzIHNwYWNlLg0K
PiAgwqDCoMKgIMKgwqDCoCBFLmcuIHNvbWUgdGVhbXMgYXQgQU1EIHdhbnQgdG8gdXNlIGEgc2Vw
YXJhdGUgR1BVIGFkZHJlc3Mgc3BhY2UNCj4gZm9yIHRoZWlyIHVzZXJzcGFjZSBjbGllbnQgbGli
cmFyeS4gSSdtIHN0aWxsIHRyeWluZyB0byBhdm9pZCB0aGF0LCBidXQNCj4gaXQgaXMgcGVyZmVj
dGx5IHBvc3NpYmxlIHRoYXQgd2UgYXJlIGdvaW5nIHRvIG5lZWQgdGhhdC4NCj4gIMKgwqDCoCDC
oMKgwqAgQWRkaXRpb25hbCB0byB0aGF0IGl0IGlzIHNvbWV0aW1lcyBxdWl0ZSB1c2VmdWwgZm9y
IGRlYnVnZ2luZw0KPiB0byBpc29sYXRlIHdoZXJlIGV4YWN0bHkgYW4gaW5jb3JyZWN0IGFjY2Vz
cyAoc2VnZmF1bHQpIGlzIGNvbWluZyBmcm9tLg0KPiANCj4gTGV0IG1lIGtub3cgaWYgdGhlcmUg
YXJlIHNvbWUgcHJvYmxlbXMgd2l0aCB0aGF0LCBlc3BlY2lhbGx5IEkgd2FudCB0bw0KPiBrbm93
IGlmIHRoZXJlIGlzIHB1c2hiYWNrIG9uICM1IHNvIHRoYXQgSSBjYW4gZm9yd2FyZCB0aGF0IDop
DQo+IA0KDQpXZSBoYXZlIHNpbWlsYXIgcmVxdWlyZW1lbnQsIGV4Y2VwdCB0aGF0IGl0IGlzICJt
dWx0aXBsZSBQQVNJRHMgZm9yDQpzYW1lIHByb2Nlc3MiIGluc3RlYWQgb2YgImZvciBzYW1lIHBy
b2Nlc3MgYWRkcmVzcyBzcGFjZSIuDQoNCkludGVsIFZULWQgZ29lcyB0byBhICd0cnVlJyBzeXN0
ZW0td2lkZSBQQVNJRCBhbGxvY2F0aW9uIHBvbGljeSwgDQpjcm9zcyBib3RoIGhvc3QgcHJvY2Vz
c2VzIGFuZCBndWVzdCBwcm9jZXNzZXMuIEFzIEphY29iIGV4cGxhaW5zLA0KdGhlcmUgd2lsbCBi
ZSBhIHZpcnR1YWwgY21kIHJlZ2lzdGVyIG9uIHZpcnR1YWwgdnRkLCB0aHJvdWdoIHdoaWNoDQpn
dWVzdCBJT01NVSBkcml2ZXIgcmVxdWVzdHMgdG8gZ2V0IHN5c3RlbS13aWRlIFBBU0lEcyBhbGxv
Y2F0ZWQNCmJ5IGhvc3QgSU9NTVUgZHJpdmVyLg0KDQp3aXRoIHRoYXQgZGVzaWduLCBRZW11IHJl
cHJlc2VudHMgYWxsIGd1ZXN0IHByb2Nlc3NlcyBpbiBob3N0DQpzaWRlLCB0aHVzIHdpbGwgZ2V0
ICJtdWx0aXBsZSBQQVNJRHMgYWxsb2NhdGVkIGZvciBzYW1lIHByb2Nlc3MiLg0KSG93ZXZlciBp
bnN0ZWFkIG9mIGJpbmRpbmcgYWxsIFBBU0lEcyB0byBzYW1lIGhvc3QgYWRkcmVzcyBzcGFjZQ0K
b2YgIFFlbXUsIGVhY2ggb2YgUEFTSUQgZW50cnkgcG9pbnRzIHRvIGd1ZXN0IGFkZHJlc3Mgc3Bh
Y2UgaWYgDQp1c2VkIGJ5IGd1ZXN0IHByb2Nlc3MuDQoNClRoYW5rcw0KS2V2aW4NCg==
