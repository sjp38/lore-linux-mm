Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 15AF28E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 03:16:05 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id b69-v6so2430691pfc.20
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 00:16:05 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id q4-v6si3501948pgh.412.2018.09.13.00.16.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 00:16:03 -0700 (PDT)
From: "Tian, Kevin" <kevin.tian@intel.com>
Subject: RE: [PATCH v2 01/40] iommu: Introduce Shared Virtual Addressing API
Date: Thu, 13 Sep 2018 07:15:54 +0000
Message-ID: <AADFC41AFE54684AB9EE6CBC0274A5D191301CAC@SHSMSX101.ccr.corp.intel.com>
References: <20180511190641.23008-1-jean-philippe.brucker@arm.com>
	<20180511190641.23008-2-jean-philippe.brucker@arm.com>
	<bf42affd-e9d0-e4fc-6d28-f3c3f7795348@redhat.com>
	<03d31ba5-1eda-ea86-8c0c-91d14c86fe83@arm.com>
	<ed39159c-087e-7e56-7d29-d1de9fa1677f@amd.com>
	<f0b317d5-e2e9-5478-952c-05e8b97bd68b@arm.com>
	<2fd4a0a1-1a35-bf82-df84-b995cce011d9@amd.com>
	<65e7accd-4446-19f5-c667-c6407e89cfa6@arm.com>
	<5bbc0332-b94b-75cc-ca42-a9b196811daf@amd.com>
 <20180907142504.5034351e@jacob-builder>
In-Reply-To: <20180907142504.5034351e@jacob-builder>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jacob Pan <jacob.jun.pan@linux.intel.com>, =?utf-8?B?Q2hyaXN0aWFuIEvDtm5pZw==?= <christian.koenig@amd.com>
Cc: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, Auger Eric <eric.auger@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "xieyisheng1@huawei.com" <xieyisheng1@huawei.com>, "liubo95@huawei.com" <liubo95@huawei.com>, "xuzaibo@huawei.com" <xuzaibo@huawei.com>, "thunder.leizhen@huawei.com" <thunder.leizhen@huawei.com>, Will Deacon <Will.Deacon@arm.com>, "okaya@codeaurora.org" <okaya@codeaurora.org>, "Liu,
 Yi L" <yi.l.liu@intel.com>, "Raj, Ashok" <ashok.raj@intel.com>, "tn@semihalf.com" <tn@semihalf.com>, "joro@8bytes.org" <joro@8bytes.org>, "bharatku@xilinx.com" <bharatku@xilinx.com>, "liudongdong3@huawei.com" <liudongdong3@huawei.com>, "rfranz@cavium.com" <rfranz@cavium.com>, "jcrouse@codeaurora.org" <jcrouse@codeaurora.org>, "rgummal@xilinx.com" <rgummal@xilinx.com>, "jonathan.cameron@huawei.com" <jonathan.cameron@huawei.com>, "shunyong.yang@hxt-semitech.com" <shunyong.yang@hxt-semitech.com>, Robin Murphy <Robin.Murphy@arm.com>, "ilias.apalodimas@linaro.org" <ilias.apalodimas@linaro.org>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "robdclark@gmail.com" <robdclark@gmail.com>, "dwmw2@infradead.org" <dwmw2@infradead.org>, "nwatters@codeaurora.org" <nwatters@codeaurora.org>, "baolu.lu@linux.intel.com" <baolu.lu@linux.intel.com>, Michal Hocko <mhocko@kernel.org>

PiBGcm9tOiBKYWNvYiBQYW4gW21haWx0bzpqYWNvYi5qdW4ucGFuQGxpbnV4LmludGVsLmNvbV0N
Cj4gU2VudDogU2F0dXJkYXksIFNlcHRlbWJlciA4LCAyMDE4IDU6MjUgQU0NCj4gPiA+IGlvbW11
LXN2YSBleHBlY3RzIGV2ZXJ5d2hlcmUgdGhhdCB0aGUgZGV2aWNlIGhhcyBhbiBpb21tdV9kb21h
aW4sDQo+ID4gPiBpdCdzIHRoZSBmaXJzdCB0aGluZyB3ZSBjaGVjayBvbiBlbnRyeS4gQnlwYXNz
aW5nIGFsbCBvZiB0aGlzIHdvdWxkDQo+ID4gPiBjYWxsIGlkcl9hbGxvYygpIGRpcmVjdGx5LCBh
bmQgd291bGRuJ3QgaGF2ZSBhbnkgY29kZSBpbiBjb21tb24NCj4gPiA+IHdpdGggdGhlIGN1cnJl
bnQgaW9tbXUtc3ZhLiBTbyBpdCBzZWVtcyBsaWtlIHlvdSBuZWVkIGEgbGF5ZXIgb24NCj4gPiA+
IHRvcCBvZiBpb21tdS1zdmEgY2FsbGluZyBpZHJfYWxsb2MoKSB3aGVuIGFuIElPTU1VIGlzbid0
IHByZXNlbnQsDQo+ID4gPiBidXQgSSBkb24ndCB0aGluayBpdCBzaG91bGQgYmUgaW4gZHJpdmVy
cy9pb21tdS8NCj4gPg0KPiA+IEluIHRoaXMgY2FzZSBJIHF1ZXN0aW9uIGlmIHRoZSBQQVNJRCBo
YW5kbGluZyBzaG91bGQgYmUgdW5kZXINCj4gPiBkcml2ZXJzL2lvbW11IGF0IGFsbC4NCj4gPg0K
PiA+IFNlZSBJIGNhbiBoYXZlIGEgbWl4IG9mIFZNIGNvbnRleHQgd2hpY2ggYXJlIGJvdW5kIHRv
IHByb2Nlc3NlcyAoc29tZQ0KPiA+IGZldykgYW5kIFZNIGNvbnRleHRzIHdoaWNoIGFyZSBzdGFu
ZGFsb25lIGFuZCBkb2Vzbid0IGNhcmUgZm9yIGENCj4gPiBwcm9jZXNzIGFkZHJlc3Mgc3BhY2Uu
IEJ1dCBmb3IgZWFjaCBWTSBjb250ZXh0IEkgbmVlZCBhIGRpc3RpbmN0DQo+ID4gUEFTSUQgZm9y
IHRoZSBoYXJkd2FyZSB0byB3b3JrLg0KDQpJJ20gY29uZnVzZWQgYWJvdXQgVk0gY29udGV4dCB2
cy4gcHJvY2Vzcy4gSXMgVk0gcmVmZXJyaW5nIHRvIFZpcnR1YWwNCk1hY2hpbmUgb3Igc29tZXRo
aW5nIGVsc2U/IElmIHllcywgSSBkb24ndCB1bmRlcnN0YW5kIHRoZSBiaW5kaW5nIHBhcnQNCi0g
d2hhdCBWTSBjb250ZXh0IGlzIGJvdW5kIHRvIChob3N0PykgcHJvY2Vzcz8NCg0KPiA+DQo+ID4g
SSBjYW4gbGl2ZSBpZiB3ZSBzYXkgaWYgSU9NTVUgaXMgY29tcGxldGVseSBkaXNhYmxlZCB3ZSB1
c2UgYSBzaW1wbGUNCj4gPiBpZGEgdG8gYWxsb2NhdGUgdGhlbSwgYnV0IHdoZW4gSU9NTVUgaXMg
ZW5hYmxlZCBJIGNlcnRhaW5seSBuZWVkIGENCj4gPiB3YXkgdG8gcmVzZXJ2ZSBhIFBBU0lEIHdp
dGhvdXQgYW4gYXNzb2NpYXRlZCBwcm9jZXNzLg0KPiA+DQo+IFZULWQgd291bGQgYWxzbyBoYXZl
IHN1Y2ggcmVxdWlyZW1lbnQuIFRoZXJlIGlzIGEgdmlydHVhbCBjb21tYW5kDQo+IHJlZ2lzdGVy
IGZvciBhbGxvY2F0ZSBhbmQgZnJlZSBQQVNJRCBmb3IgVk0gdXNlLiBXaGVuIHRoYXQgUEFTSUQN
Cj4gYWxsb2NhdGlvbiByZXF1ZXN0IGdldHMgcHJvcGFnYXRlZCB0byB0aGUgaG9zdCBJT01NVSBk
cml2ZXIsIHdlIG5lZWQgdG8NCj4gYWxsb2NhdGUgUEFTSUQgdy9vIG1tLg0KPiANCg0KVlQtZCBp
cyBhIGJpdCBkaWZmZXJlbnQuIEluIGhvc3Qgc2lkZSwgUEFTSUQgYWxsb2NhdGlvbiBhbHdheXMg
aGFwcGVucyBpbg0KUWVtdSdzIGNvbnRleHQsIHNvIHRob3NlIFBBU0lEcyBhcmUgcmVjb3JkZWQg
d2l0aCBRZW11IHByb2Nlc3MsIA0KdGhvdWdoIHRoZSBlbnRyaWVzIG1heSBwb2ludCB0byBndWVz
dCBwYWdlIHRhYmxlcyBpbnN0ZWFkIG9mIGhvc3QgbW0NCm9mIFFlbXUuDQoNClRoYW5rcw0KS2V2
aW4NCg==
