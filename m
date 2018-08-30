Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 754546B5301
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 15:38:07 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id a15-v6so9876110qtj.15
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 12:38:07 -0700 (PDT)
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680110.outbound.protection.outlook.com. [40.107.68.110])
        by mx.google.com with ESMTPS id k14-v6si3447703qtm.373.2018.08.30.12.38.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Aug 2018 12:38:06 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH RFCv2 4/6] powerpc/powernv: hold device_hotplug_lock when
 calling device_online()
Date: Thu, 30 Aug 2018 19:38:04 +0000
Message-ID: <7e9d1b8f-1637-5f24-3f64-c6e9927f6909@microsoft.com>
References: <20180821104418.12710-1-david@redhat.com>
 <20180821104418.12710-5-david@redhat.com>
In-Reply-To: <20180821104418.12710-5-david@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <04EA064F5EB9CF409A2AC76D0D341A0D@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Rashmica Gupta <rashmica.g@gmail.com>, Balbir Singh <bsingharora@gmail.com>, Michael Neuling <mikey@neuling.org>

UmV2aWV3ZWQtYnk6IFBhdmVsIFRhdGFzaGluIDxwYXZlbC50YXRhc2hpbkBtaWNyb3NvZnQuY29t
Pg0KDQpPbiA4LzIxLzE4IDY6NDQgQU0sIERhdmlkIEhpbGRlbmJyYW5kIHdyb3RlOg0KPiBkZXZp
Y2Vfb25saW5lKCkgc2hvdWxkIGJlIGNhbGxlZCB3aXRoIGRldmljZV9ob3RwbHVnX2xvY2soKSBo
ZWxkLg0KPiANCj4gQ2M6IEJlbmphbWluIEhlcnJlbnNjaG1pZHQgPGJlbmhAa2VybmVsLmNyYXNo
aW5nLm9yZz4NCj4gQ2M6IFBhdWwgTWFja2VycmFzIDxwYXVsdXNAc2FtYmEub3JnPg0KPiBDYzog
TWljaGFlbCBFbGxlcm1hbiA8bXBlQGVsbGVybWFuLmlkLmF1Pg0KPiBDYzogUmFzaG1pY2EgR3Vw
dGEgPHJhc2htaWNhLmdAZ21haWwuY29tPg0KPiBDYzogQmFsYmlyIFNpbmdoIDxic2luZ2hhcm9y
YUBnbWFpbC5jb20+DQo+IENjOiBNaWNoYWVsIE5ldWxpbmcgPG1pa2V5QG5ldWxpbmcub3JnPg0K
PiBTaWduZWQtb2ZmLWJ5OiBEYXZpZCBIaWxkZW5icmFuZCA8ZGF2aWRAcmVkaGF0LmNvbT4NCj4g
LS0tDQo+ICBhcmNoL3Bvd2VycGMvcGxhdGZvcm1zL3Bvd2VybnYvbWVtdHJhY2UuYyB8IDIgKysN
Cj4gIDEgZmlsZSBjaGFuZ2VkLCAyIGluc2VydGlvbnMoKykNCj4gDQo+IGRpZmYgLS1naXQgYS9h
cmNoL3Bvd2VycGMvcGxhdGZvcm1zL3Bvd2VybnYvbWVtdHJhY2UuYyBiL2FyY2gvcG93ZXJwYy9w
bGF0Zm9ybXMvcG93ZXJudi9tZW10cmFjZS5jDQo+IGluZGV4IDhmMWNkNGYzYmZkNS4uZWY3MTgx
ZDRmZTY4IDEwMDY0NA0KPiAtLS0gYS9hcmNoL3Bvd2VycGMvcGxhdGZvcm1zL3Bvd2VybnYvbWVt
dHJhY2UuYw0KPiArKysgYi9hcmNoL3Bvd2VycGMvcGxhdGZvcm1zL3Bvd2VybnYvbWVtdHJhY2Uu
Yw0KPiBAQCAtMjI5LDkgKzIyOSwxMSBAQCBzdGF0aWMgaW50IG1lbXRyYWNlX29ubGluZSh2b2lk
KQ0KPiAgCQkgKiB3ZSBuZWVkIHRvIG9ubGluZSB0aGUgbWVtb3J5IG91cnNlbHZlcy4NCj4gIAkJ
ICovDQo+ICAJCWlmICghbWVtaHBfYXV0b19vbmxpbmUpIHsNCj4gKwkJCWxvY2tfZGV2aWNlX2hv
dHBsdWcoKTsNCj4gIAkJCXdhbGtfbWVtb3J5X3JhbmdlKFBGTl9ET1dOKGVudC0+c3RhcnQpLA0K
PiAgCQkJCQkgIFBGTl9VUChlbnQtPnN0YXJ0ICsgZW50LT5zaXplIC0gMSksDQo+ICAJCQkJCSAg
TlVMTCwgb25saW5lX21lbV9ibG9jayk7DQo+ICsJCQl1bmxvY2tfZGV2aWNlX2hvdHBsdWcoKTsN
Cj4gIAkJfQ0KPiAgDQo+ICAJCS8qDQo+IA==
