Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4866B2A41
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:14:14 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id r19-v6so5214058itc.4
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:14:14 -0700 (PDT)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-sn1nam02on0134.outbound.protection.outlook.com. [104.47.36.134])
        by mx.google.com with ESMTPS id b2-v6si3339108itg.7.2018.08.23.06.14.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 23 Aug 2018 06:14:12 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: A crash on ARM64 in move_freepages_block due to uninitialized
 pages in reserved memory
Date: Thu, 23 Aug 2018 13:14:10 +0000
Message-ID: <e27d6fcc-e860-8d51-1d0c-27391dca1b7b@microsoft.com>
References: 
 <alpine.LRH.2.02.1808171527220.2385@file01.intranet.prod.int.rdu2.redhat.com>
 <20180821104418.GA16611@dhcp22.suse.cz>
 <e35b7c14-c7ea-412d-2763-c961b74576f3@arm.com>
 <alpine.LRH.2.02.1808220808050.17906@file01.intranet.prod.int.rdu2.redhat.com>
 <20180823111024.GC29735@dhcp22.suse.cz>
 <alpine.LRH.2.02.1808230715050.30076@file01.intranet.prod.int.rdu2.redhat.com>
 <20180823112359.GE29735@dhcp22.suse.cz>
 <777276b8-9cd6-da4b-d1d9-c60f96a58122@microsoft.com>
In-Reply-To: <777276b8-9cd6-da4b-d1d9-c60f96a58122@microsoft.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <106B54EF74AA60458DBFF1B3637A8479@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mikulas Patocka <mpatocka@redhat.com>
Cc: James Morse <james.morse@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

DQoNCk9uIDgvMjMvMTggOToxMyBBTSwgUGF2ZWwgVGF0YXNoaW4gd3JvdGU6DQo+IE9uIDgvMjMv
MTggNzoyMyBBTSwgTWljaGFsIEhvY2tvIHdyb3RlOg0KPj4gT24gVGh1IDIzLTA4LTE4IDA3OjE2
OjM0LCBNaWt1bGFzIFBhdG9ja2Egd3JvdGU6DQo+Pj4NCj4+Pg0KPj4+IE9uIFRodSwgMjMgQXVn
IDIwMTgsIE1pY2hhbCBIb2NrbyB3cm90ZToNCj4+Pg0KPj4+PiBPbiBUaHUgMjMtMDgtMTggMDc6
MDI6MzcsIE1pa3VsYXMgUGF0b2NrYSB3cm90ZToNCj4+Pj4gWy4uLl0NCj4+Pj4+IFRoaXMgY3Jh
c2ggaXMgbm90IGZyb20gLUVOT0VOVC4gSXQgY3Jhc2hlcyBiZWNhdXNlIHBhZ2UtPmNvbXBvdW5k
X2hlYWQgaXMgDQo+Pj4+PiAweGZmZmZmZmZmZmZmZmZmZmYgKHNlZSBiZWxvdykuDQo+Pj4+Pg0K
Pj4+Pj4gSWYgSSBlbmFibGUgQ09ORklHX0RFQlVHX1ZNLCBJIGFsc28gZ2V0IFZNX0JVRy4NCj4+
Pj4NCj4+Pj4gVGhpcyBzbWVsbHMgbGlrZSB0aGUgc3RydWN0IHBhZ2UgaXMgbm90IGluaXRpYWxp
emVkIHByb3Blcmx5LiBIb3cgaXMNCj4+Pj4gdGhpcyBtZW1vcnkgcmFuZ2UgYWRkZWQ/IEkgbWVh
biBpcyBpdCBicm91Z2h0IHVwIGJ5IHRoZSBtZW1vcnkgaG90cGx1Zw0KPj4+PiBvciBkdXJpbmcg
dGhlIGJvb3Q/DQo+IA0KPiBJIGJlbGlldmUgaXQgaXMgZHVlIHRvIHVuaW5pdGlhbGl6ZWQgc3Ry
dWN0IHBhZ2VzLiBNaWt1bGFzLCBjb3VsZCB5b3UNCj4gcGxlYXNlIHByb3ZpZGUgY29uZmlnIGZp
bGUsIGFuZCBhbHNvIHRoZSBmdWxsIGNvbnNvbGUgb3V0cHV0Lg0KPiANCj4gUGxlYXNlIG1ha2Ug
c3VyZSB0aGF0IHlvdSBoYXZlOg0KPiBDT05GSUdfREVCVUdfVk09eQ0KPiBDT05GSUdfQVJDSF9I
QVNfREVCVUdfVklSVFVBTD15DQoNCkkgbWVhbnQ6DQpDT05GSUdfREVCVUdfVk09eQ0KQ09ORklH
X0RFQlVHX1ZNX1BHRkxBR1M9eQ0KDQo+IA0KPiBJIHdvbmRlciB3aGF0IGtpbmQgb2Ygc3RydWN0
IHBhZ2UgbWVtb3J5IGxheW91dCBpcyB1c2VkLCBhbmQgYWxzbyBpZg0KPiBkZWZlcnJlZCBzdHJ1
Y3QgcGFnZXMgYXJlIGVuYWJsZWQgb3Igbm90Lg0KPiANCj4gSGF2ZSB5b3UgdHJpZWQgYmlzZWN0
aW5nIHRoZSBwcm9ibGVtPw0KPiANCj4gVGhhbmsgeW91LA0KPiBQYXZlbA0KPiA=
