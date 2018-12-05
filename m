Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 08A3C6B7199
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 19:54:07 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id 186-v6so11833517ybd.21
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 16:54:07 -0800 (PST)
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (mail-eopbgr710070.outbound.protection.outlook.com. [40.107.71.70])
        by mx.google.com with ESMTPS id y68-v6si10866880ybc.169.2018.12.04.16.54.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 04 Dec 2018 16:54:05 -0800 (PST)
From: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
Date: Wed, 5 Dec 2018 00:54:01 +0000
Message-ID: <935c9f17-d2df-9eff-eef6-52e57711fecc@amd.com>
References: <20181203233509.20671-1-jglisse@redhat.com>
 <20181203233509.20671-3-jglisse@redhat.com> <875zw98bm4.fsf@linux.intel.com>
 <20181204182421.GC2937@redhat.com>
 <CAPcyv4gtv7eUc1_3Yhz-f-B3Lct=Vq7zqUJKOqCtWYb4BS6i9g@mail.gmail.com>
 <20181204185725.GE2937@redhat.com>
 <de7c1099-2717-6396-bf56-c4ab4085ee83@deltatee.com>
In-Reply-To: <de7c1099-2717-6396-bf56-c4ab4085ee83@deltatee.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <92BCC906D3DCC547BF0D7773D5CA21BC@namprd12.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>, Jerome Glisse <jglisse@redhat.com>, Dan Williams <dan.j.williams@intel.com>
Cc: Andi Kleen <ak@linux.intel.com>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Rafael J. Wysocki" <rafael@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, "balbirs@au1.ibm.com" <balbirs@au1.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Yang, Philip" <Philip.Yang@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, "Blinzer, Paul" <Paul.Blinzer@amd.com>, John Hubbard <jhubbard@nvidia.com>, "rcampbell@nvidia.com" <rcampbell@nvidia.com>

T24gMjAxOC0xMi0wNCAyOjExIHAubS4sIExvZ2FuIEd1bnRob3JwZSB3cm90ZToNCj4gQWxzbywg
aW4gdGhlIHNhbWUgdmVpbiwgSSB0aGluayBpdCdzIHdyb25nIHRvIGhhdmUgdGhlIEFQSSBlbnVt
ZXJhdGUgYWxsDQo+IHRoZSBkaWZmZXJlbnQgbWVtb3J5IGF2YWlsYWJsZSBpbiB0aGUgc3lzdGVt
LiBUaGUgQVBJIHNob3VsZCBzaW1wbHkNCj4gYWxsb3cgdXNlcnNwYWNlIHRvIHNheSBpdCB3YW50
cyBtZW1vcnkgdGhhdCBjYW4gYmUgYWNjZXNzZWQgYnkgYSBzZXQgb2YNCj4gaW5pdGlhdG9ycyB3
aXRoIGEgY2VydGFpbiBzZXQgb2YgYXR0cmlidXRlcyBhbmQgdGhlIGJpbmQgY2FsbCB0cmllcyB0
bw0KPiBmdWxmaWxsIHRoYXQgb3IgZmFsbGJhY2sgb24gc3lzdGVtIG1lbW9yeS9obW0gbWlncmF0
aW9uL3doYXRldmVyLg0KDQpUaGF0IGdldHMgcHJldHR5IGNvbXBsZXggd2hlbiB5b3UgYWxzbyBo
YXZlIHRha2UgaW50byBhY2NvdW50IGNvbnRlbnRpb24NCm9mIGxpbmtzIGFuZCBicmlkZ2VzIHdo
ZW4gbXVsdGlwbGUgaW5pdGlhdG9ycyBhcmUgYWNjZXNzaW5nIG11bHRpcGxlDQp0YXJnZXRzIHNp
bXVsdGFuZW91c2x5LiBJZiB5b3Ugd2FudCB0aGUga2VybmVsIHRvIG1ha2Ugc2FuZSBkZWNpc2lv
bnMsDQppdCBuZWVkcyBhIGxvdCBtb3JlIGluZm9ybWF0aW9uIGFib3V0IHRoZSBleHBlY3RlZCBt
ZW1vcnkgYWNjZXNzIHBhdHRlcm5zLg0KDQpIaWdobHkgb3B0aW1pemVkIGFsZ29yaXRobXMgdGhh
dCB1c2UgbXVsdGlwbGUgR1BVcyBhbmQgY29sbGVjdGl2ZQ0KY29tbXVuaWNhdGlvbnMgYmV0d2Vl
biB0aGVtIHdhbnQgdG8gYmUgYWJsZSB0byBwbGFjZSB0aGVpciBtZW1vcnkNCm9iamVjdHMgaW4g
dGhlIHJpZ2h0IGxvY2F0aW9uIHRvIGF2b2lkIHN1Y2ggY29udGVudGlvbi4gWW91IGRvbid0IHdh
bnQNCnN1Y2ggYW4gYWxnb3JpdGhtIHRvIGd1ZXNzIGFib3V0IG9wYXF1ZSBwb2xpY3kgZGVjaXNp
b25zIGluIHRoZSBrZXJuZWwuDQpJZiB0aGUgcG9saWN5IGNoYW5nZXMsIHlvdSBoYXZlIHRvIHJl
LW9wdGltaXplIHRoZSBhbGdvcml0aG0uDQoNClJlZ2FyZHMsDQrCoCBGZWxpeA0KDQoNCj4NCj4g
TG9nYW4NCg==
