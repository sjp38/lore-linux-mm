Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C75C78E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 09:28:28 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f13-v6so1038023pgs.15
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 06:28:28 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0129.outbound.protection.outlook.com. [104.47.40.129])
        by mx.google.com with ESMTPS id b129-v6si1050790pfa.12.2018.09.12.06.28.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Sep 2018 06:28:27 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH 2/4] mm: Create non-atomic version of SetPageReserved for
 init use
Date: Wed, 12 Sep 2018 13:28:25 +0000
Message-ID: <f4f6a343-7be1-4290-802e-7ff96e93bc2a@microsoft.com>
References: <20180910232615.4068.29155.stgit@localhost.localdomain>
 <20180910234348.4068.92164.stgit@localhost.localdomain>
In-Reply-To: <20180910234348.4068.92164.stgit@localhost.localdomain>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <569B95AED34CEF49BC65C5B37016D013@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "dave.jiang@intel.com" <dave.jiang@intel.com>, "mingo@kernel.org" <mingo@kernel.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "jglisse@redhat.com" <jglisse@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "logang@deltatee.com" <logang@deltatee.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

DQpPbiA5LzEwLzE4IDc6NDMgUE0sIEFsZXhhbmRlciBEdXljayB3cm90ZToNCj4gRnJvbTogQWxl
eGFuZGVyIER1eWNrIDxhbGV4YW5kZXIuaC5kdXlja0BpbnRlbC5jb20+DQo+IA0KPiBJdCBkb2Vz
bid0IG1ha2UgbXVjaCBzZW5zZSB0byB1c2UgdGhlIGF0b21pYyBTZXRQYWdlUmVzZXJ2ZWQgYXQg
aW5pdCB0aW1lDQo+IHdoZW4gd2UgYXJlIHVzaW5nIG1lbXNldCB0byBjbGVhciB0aGUgbWVtb3J5
IGFuZCBtYW5pcHVsYXRpbmcgdGhlIHBhZ2UNCj4gZmxhZ3MgdmlhIHNpbXBsZSAiJj0iIGFuZCAi
fD0iIG9wZXJhdGlvbnMgaW4gX19pbml0X3NpbmdsZV9wYWdlLg0KPiANCj4gVGhpcyBwYXRjaCBh
ZGRzIGEgbm9uLWF0b21pYyB2ZXJzaW9uIF9fU2V0UGFnZVJlc2VydmVkIHRoYXQgY2FuIGJlIHVz
ZWQNCj4gZHVyaW5nIHBhZ2UgaW5pdCBhbmQgc2hvd3MgYWJvdXQgYSAxMCUgaW1wcm92ZW1lbnQg
aW4gaW5pdGlhbGl6YXRpb24gdGltZXMNCj4gb24gdGhlIHN5c3RlbXMgSSBoYXZlIGF2YWlsYWJs
ZSBmb3IgdGVzdGluZy4gT24gdGhvc2Ugc3lzdGVtcyBJIHNhdw0KPiBpbml0aWFsaXphdGlvbiB0
aW1lcyBkcm9wIGZyb20gYXJvdW5kIDM1IHNlY29uZHMgdG8gYXJvdW5kIDMyIHNlY29uZHMgdG8N
Cj4gaW5pdGlhbGl6ZSBhIDNUQiBibG9jayBvZiBwZXJzaXN0ZW50IG1lbW9yeS4NCj4gDQo+IEkg
dHJpZWQgYWRkaW5nIGEgYml0IG9mIGRvY3VtZW50YXRpb24gYmFzZWQgb24gY29tbWl0IDxmMWRk
MmNkMTNjND4gKCJtbSwNCj4gbWVtb3J5X2hvdHBsdWc6IGRvIG5vdCBhc3NvY2lhdGUgaG90YWRk
ZWQgbWVtb3J5IHRvIHpvbmVzIHVudGlsIG9ubGluZSIpLg0KPiANCj4gSWRlYWxseSB0aGUgcmVz
ZXJ2ZWQgZmxhZyBzaG91bGQgYmUgc2V0IGVhcmxpZXIgc2luY2UgdGhlcmUgaXMgYSBicmllZg0K
PiB3aW5kb3cgd2hlcmUgdGhlIHBhZ2UgaXMgaW5pdGlhbGl6YXRpb24gdmlhIF9faW5pdF9zaW5n
bGVfcGFnZSBhbmQgd2UgaGF2ZQ0KPiBub3Qgc2V0IHRoZSBQR19SZXNlcnZlZCBmbGFnLiBJJ20g
bGVhdmluZyB0aGF0IGZvciBhIGZ1dHVyZSBwYXRjaCBzZXQgYXMNCj4gdGhhdCB3aWxsIHJlcXVp
cmUgYSBtb3JlIHNpZ25pZmljYW50IHJlZmFjdG9yLg0KPiANCj4gQWNrZWQtYnk6IE1pY2hhbCBI
b2NrbyA8bWhvY2tvQHN1c2UuY29tPg0KPiBTaWduZWQtb2ZmLWJ5OiBBbGV4YW5kZXIgRHV5Y2sg
PGFsZXhhbmRlci5oLmR1eWNrQGludGVsLmNvbT4NCg0KUmV2aWV3ZWQtYnk6IFBhdmVsIFRhdGFz
aGluIDxwYXZlbC50YXRhc2hpbkBtaWNyb3NvZnQuY29tPg0KDQpUaGFuayB5b3UsDQpQYXZlbA==
