Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83A836B2A3C
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:13:23 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u129-v6so4565615qkf.15
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:13:23 -0700 (PDT)
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (mail-eopbgr680113.outbound.protection.outlook.com. [40.107.68.113])
        by mx.google.com with ESMTPS id 44-v6si945322qvk.145.2018.08.23.06.13.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 23 Aug 2018 06:13:22 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: A crash on ARM64 in move_freepages_block due to uninitialized
 pages in reserved memory
Date: Thu, 23 Aug 2018 13:13:20 +0000
Message-ID: <777276b8-9cd6-da4b-d1d9-c60f96a58122@microsoft.com>
References: 
 <alpine.LRH.2.02.1808171527220.2385@file01.intranet.prod.int.rdu2.redhat.com>
 <20180821104418.GA16611@dhcp22.suse.cz>
 <e35b7c14-c7ea-412d-2763-c961b74576f3@arm.com>
 <alpine.LRH.2.02.1808220808050.17906@file01.intranet.prod.int.rdu2.redhat.com>
 <20180823111024.GC29735@dhcp22.suse.cz>
 <alpine.LRH.2.02.1808230715050.30076@file01.intranet.prod.int.rdu2.redhat.com>
 <20180823112359.GE29735@dhcp22.suse.cz>
In-Reply-To: <20180823112359.GE29735@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <C35FBC9AC316594B85ABDC270FF04F52@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Mikulas Patocka <mpatocka@redhat.com>
Cc: James Morse <james.morse@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

T24gOC8yMy8xOCA3OjIzIEFNLCBNaWNoYWwgSG9ja28gd3JvdGU6DQo+IE9uIFRodSAyMy0wOC0x
OCAwNzoxNjozNCwgTWlrdWxhcyBQYXRvY2thIHdyb3RlOg0KPj4NCj4+DQo+PiBPbiBUaHUsIDIz
IEF1ZyAyMDE4LCBNaWNoYWwgSG9ja28gd3JvdGU6DQo+Pg0KPj4+IE9uIFRodSAyMy0wOC0xOCAw
NzowMjozNywgTWlrdWxhcyBQYXRvY2thIHdyb3RlOg0KPj4+IFsuLi5dDQo+Pj4+IFRoaXMgY3Jh
c2ggaXMgbm90IGZyb20gLUVOT0VOVC4gSXQgY3Jhc2hlcyBiZWNhdXNlIHBhZ2UtPmNvbXBvdW5k
X2hlYWQgaXMgDQo+Pj4+IDB4ZmZmZmZmZmZmZmZmZmZmZiAoc2VlIGJlbG93KS4NCj4+Pj4NCj4+
Pj4gSWYgSSBlbmFibGUgQ09ORklHX0RFQlVHX1ZNLCBJIGFsc28gZ2V0IFZNX0JVRy4NCj4+Pg0K
Pj4+IFRoaXMgc21lbGxzIGxpa2UgdGhlIHN0cnVjdCBwYWdlIGlzIG5vdCBpbml0aWFsaXplZCBw
cm9wZXJseS4gSG93IGlzDQo+Pj4gdGhpcyBtZW1vcnkgcmFuZ2UgYWRkZWQ/IEkgbWVhbiBpcyBp
dCBicm91Z2h0IHVwIGJ5IHRoZSBtZW1vcnkgaG90cGx1Zw0KPj4+IG9yIGR1cmluZyB0aGUgYm9v
dD8NCg0KSSBiZWxpZXZlIGl0IGlzIGR1ZSB0byB1bmluaXRpYWxpemVkIHN0cnVjdCBwYWdlcy4g
TWlrdWxhcywgY291bGQgeW91DQpwbGVhc2UgcHJvdmlkZSBjb25maWcgZmlsZSwgYW5kIGFsc28g
dGhlIGZ1bGwgY29uc29sZSBvdXRwdXQuDQoNClBsZWFzZSBtYWtlIHN1cmUgdGhhdCB5b3UgaGF2
ZToNCkNPTkZJR19ERUJVR19WTT15DQpDT05GSUdfQVJDSF9IQVNfREVCVUdfVklSVFVBTD15DQoN
Ckkgd29uZGVyIHdoYXQga2luZCBvZiBzdHJ1Y3QgcGFnZSBtZW1vcnkgbGF5b3V0IGlzIHVzZWQs
IGFuZCBhbHNvIGlmDQpkZWZlcnJlZCBzdHJ1Y3QgcGFnZXMgYXJlIGVuYWJsZWQgb3Igbm90Lg0K
DQpIYXZlIHlvdSB0cmllZCBiaXNlY3RpbmcgdGhlIHByb2JsZW0/DQoNClRoYW5rIHlvdSwNClBh
dmVs
