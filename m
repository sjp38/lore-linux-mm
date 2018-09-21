Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id E3CA28E0001
	for <linux-mm@kvack.org>; Fri, 21 Sep 2018 15:52:44 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id z25-v6so24408052iog.17
        for <linux-mm@kvack.org>; Fri, 21 Sep 2018 12:52:44 -0700 (PDT)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0092.outbound.protection.outlook.com. [104.47.38.92])
        by mx.google.com with ESMTPS id j6-v6si3769063ita.68.2018.09.21.12.52.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 21 Sep 2018 12:52:44 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH v4 1/5] mm: Provide kernel parameter to allow disabling
 page init poisoning
Date: Fri, 21 Sep 2018 19:52:42 +0000
Message-ID: <3c045f79-c18b-47dd-4017-a024edc9aa46@microsoft.com>
References: <20180920215824.19464.8884.stgit@localhost.localdomain>
 <20180920222415.19464.38400.stgit@localhost.localdomain>
 <a40a78c0-207b-03b7-344c-847b12a4f896@microsoft.com>
 <4d984974-ff16-35e4-76ff-f5e43e5e90da@deltatee.com>
In-Reply-To: <4d984974-ff16-35e4-76ff-f5e43e5e90da@deltatee.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <AEF40F3EFDE49F42BBBFD042E5E9A767@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>
Cc: "mhocko@suse.com" <mhocko@suse.com>, "dave.jiang@intel.com" <dave.jiang@intel.com>, "mingo@kernel.org" <mingo@kernel.org>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "jglisse@redhat.com" <jglisse@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

DQoNCk9uIDkvMjEvMTggMzo0MSBQTSwgTG9nYW4gR3VudGhvcnBlIHdyb3RlOg0KPiBPbiAyMDE4
LTA5LTIxIDE6MDQgUE0sIFBhc2hhIFRhdGFzaGluIHdyb3RlOg0KPj4NCj4+PiArCQkJcHJfZXJy
KCJ2bV9kZWJ1ZyBvcHRpb24gJyVjJyB1bmtub3duLiBza2lwcGVkXG4iLA0KPj4+ICsJCQkgICAg
ICAgKnN0cik7DQo+Pj4gKwkJfQ0KPj4+ICsNCj4+PiArCQlzdHIrKzsNCj4+PiArCX0NCj4+PiAr
b3V0Og0KPj4+ICsJaWYgKHBhZ2VfaW5pdF9wb2lzb25pbmcgJiYgIV9fcGFnZV9pbml0X3BvaXNv
bmluZykNCj4+PiArCQlwcl93YXJuKCJQYWdlIHN0cnVjdCBwb2lzb25pbmcgZGlzYWJsZWQgYnkg
a2VybmVsIGNvbW1hbmQgbGluZSBvcHRpb24gJ3ZtX2RlYnVnJ1xuIik7DQo+Pg0KPj4gTmV3IGxp
bmVzICdcbicgY2FuIGJlIHJlbW92ZWQsIHRoZXkgYXJlIG5vdCBuZWVkZWQgZm9yIGtwcmludGZz
Lg0KPiANCj4gTm8sIHRoYXQncyBub3QgY29ycmVjdC4NCj4gDQo+IEEgcHJpbnRrIHdpdGhvdXQg
YSBuZXdsaW5lIHRlcm1pbmF0aW9uIGlzIG5vdCBlbWl0dGVkDQo+IGFzIG91dHB1dCB1bnRpbCB0
aGUgbmV4dCBwcmludGsgY2FsbC4gKFRvIHN1cHBvcnQgS0VSTl9DT05UKS4NCj4gVGhlcmVmb3Jl
IHJlbW92aW5nIHRoZSAnXG4nIGNhdXNlcyBhIHByaW50ayB0byBub3QgYmUgcHJpbnRlZCB3aGVu
IGl0IGlzDQo+IGNhbGxlZCB3aGljaCBjYW4gY2F1c2UgbG9uZyBkZWxheWVkIG1lc3NhZ2VzIGFu
ZCBzdWJ0bGUgcHJvYmxlbXMgd2hlbg0KPiBkZWJ1Z2dpbmcuIEFsd2F5cyBrZWVwIHRoZSBuZXds
aW5lIGluIHBsYWNlIGV2ZW4gdGhvdWdoIHRoZSBrZXJuZWwgd2lsbA0KPiBhZGQgb25lIGZvciB5
b3UgaWYgaXQncyBtaXNzaW5nLg0KDQpPSy4gVGhhbmsgeW91IGZvciBjbGFyaWZ5aW5nIExvZ2Fu
LiBJJ3ZlIHNlZW4gbmV3IGxpbmVzIGFyZSBiZWluZw0KcmVtb3ZlZCBpbiBvdGhlciBwYXRjaGVz
LA0KDQpQYXZlbA==
