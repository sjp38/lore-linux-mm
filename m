Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7688E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 16:16:57 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id d18so16364770pfe.0
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 13:16:57 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-eopbgr800079.outbound.protection.outlook.com. [40.107.80.79])
        by mx.google.com with ESMTPS id ba9si15490195plb.109.2018.12.12.13.16.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Dec 2018 13:16:56 -0800 (PST)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH v2 4/4] x86/vmalloc: Add TLB efficient x86 arch_vunmap
Date: Wed, 12 Dec 2018 21:16:50 +0000
Message-ID: <C555A142-AA07-465C-AC9B-6DF3683A8F42@vmware.com>
References: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
 <20181212000354.31955-5-rick.p.edgecombe@intel.com>
 <90B10050-0CF1-48B2-B671-508FB092C2FE@vmware.com>
 <2604df8fb817d8f0c38f572f4fb184db36554bed.camel@intel.com>
In-Reply-To: <2604df8fb817d8f0c38f572f4fb184db36554bed.camel@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <02BAECB73A3B174FB12C4382C97AF68F@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "jeyu@kernel.org" <jeyu@kernel.org>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "ast@kernel.org" <ast@kernel.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jannh@google.com" <jannh@google.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, "mhiramat@kernel.org" <mhiramat@kernel.org>, "naveen.n.rao@linux.vnet.ibm.com" <naveen.n.rao@linux.vnet.ibm.com>, "davem@davemloft.net" <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>

PiBPbiBEZWMgMTIsIDIwMTgsIGF0IDE6MDUgUE0sIEVkZ2Vjb21iZSwgUmljayBQIDxyaWNrLnAu
ZWRnZWNvbWJlQGludGVsLmNvbT4gd3JvdGU6DQo+IA0KPiBPbiBXZWQsIDIwMTgtMTItMTIgYXQg
MDY6MzAgKzAwMDAsIE5hZGF2IEFtaXQgd3JvdGU6DQo+Pj4gT24gRGVjIDExLCAyMDE4LCBhdCA0
OjAzIFBNLCBSaWNrIEVkZ2Vjb21iZSA8cmljay5wLmVkZ2Vjb21iZUBpbnRlbC5jb20+DQo+Pj4g
d3JvdGU6DQo+Pj4gDQo+Pj4gVGhpcyBhZGRzIGEgbW9yZSBlZmZpY2llbnQgeDg2IGFyY2hpdGVj
dHVyZSBzcGVjaWZpYyBpbXBsZW1lbnRhdGlvbiBvZg0KPj4+IGFyY2hfdnVubWFwLCB0aGF0IGNh
biBmcmVlIGFueSB0eXBlIG9mIHNwZWNpYWwgcGVybWlzc2lvbiBtZW1vcnkgd2l0aCBvbmx5IDEN
Cj4+PiBUTEINCj4+PiBmbHVzaC4NCj4+PiANCj4+PiBJbiBvcmRlciB0byBlbmFibGUgdGhpcywg
X3NldF9wYWdlc19wIGFuZCBfc2V0X3BhZ2VzX25wIGFyZSBtYWRlIG5vbi1zdGF0aWMNCj4+PiBh
bmQNCj4+PiByZW5hbWVkIHNldF9wYWdlc19wX25vZmx1c2ggYW5kIHNldF9wYWdlc19ucF9ub2Zs
dXNoIHRvIGJldHRlciBjb21tdW5pY2F0ZQ0KPj4+IHRoZWlyIGRpZmZlcmVudCAobm9uLWZsdXNo
aW5nKSBiZWhhdmlvciBmcm9tIHRoZSByZXN0IG9mIHRoZSBzZXRfcGFnZXNfKg0KPj4+IGZ1bmN0
aW9ucy4NCj4+PiANCj4+PiBUaGUgbWV0aG9kIGZvciBkb2luZyB0aGlzIHdpdGggb25seSAxIFRM
QiBmbHVzaCB3YXMgc3VnZ2VzdGVkIGJ5IEFuZHkNCj4+PiBMdXRvbWlyc2tpLg0KPj4gDQo+PiBb
c25pcF0NCj4+IA0KPj4+ICsJLyoNCj4+PiArCSAqIElmIHRoZSB2bSBiZWluZyBmcmVlZCBoYXMg
c2VjdXJpdHkgc2Vuc2l0aXZlIGNhcGFiaWxpdGllcyBzdWNoIGFzDQo+Pj4gKwkgKiBleGVjdXRh
YmxlIHdlIG5lZWQgdG8gbWFrZSBzdXJlIHRoZXJlIGlzIG5vIFcgd2luZG93IG9uIHRoZSBkaXJl
Y3RtYXANCj4+PiArCSAqIGJlZm9yZSByZW1vdmluZyB0aGUgWCBpbiB0aGUgVExCLiBTbyB3ZSBz
ZXQgbm90IHByZXNlbnQgZmlyc3Qgc28gd2UNCj4+PiArCSAqIGNhbiBmbHVzaCB3aXRob3V0IGFu
eSBvdGhlciBDUFUgcGlja2luZyB1cCB0aGUgbWFwcGluZy4gVGhlbiB3ZSByZXNldA0KPj4+ICsJ
ICogUlcrUCB3aXRob3V0IGEgZmx1c2gsIHNpbmNlIE5QIHByZXZlbnRlZCBpdCBmcm9tIGJlaW5n
IGNhY2hlZCBieQ0KPj4+ICsJICogb3RoZXIgY3B1cy4NCj4+PiArCSAqLw0KPj4+ICsJc2V0X2Fy
ZWFfZGlyZWN0X25wKGFyZWEpOw0KPj4+ICsJdm1fdW5tYXBfYWxpYXNlcygpOw0KPj4gDQo+PiBE
b2VzIHZtX3VubWFwX2FsaWFzZXMoKSBmbHVzaCBpbiB0aGUgVExCIHRoZSBkaXJlY3QgbWFwcGlu
ZyByYW5nZSBhcyB3ZWxsPyBJDQo+PiBjYW4gb25seSBmaW5kIHRoZSBmbHVzaCBvZiB0aGUgdm1h
bGxvYyByYW5nZS4NCj4gSG1tbS4gSXQgc2hvdWxkIHVzdWFsbHkgKEkgdGVzdGVkKSwgYnV0IG5v
dyBJIHdvbmRlciBpZiB0aGVyZSBhcmUgY2FzZXMgd2hlcmUgaXQNCj4gZG9lc24ndCBhbmQgaXQg
Y291bGQgZGVwZW5kIG9uIGFyY2hpdGVjdHVyZSBhcyB3ZWxsLiBJJ2xsIGhhdmUgdG8gdHJhY2Ug
dGhyb3VnaA0KPiB0aGlzIHRvIHZlcmlmeSwgdGhhbmtzLg0KDQpJIHRoaW5rIHRoYXQgaXQgbW9z
dGx5IGRvZXMsIHNpbmNlIHlvdSB0cnkgdG8gZmx1c2ggbW9yZSB0aGFuIDMzIFBURXMgKHRoZQ0K
dGhyZXNob2xkIHRvIGZsdXNoIHRoZSB3aG9sZSBUTEIgaW5zdGVhZCBvZiBpbmRpdmlkdWFsIGVu
dHJpZXMpLiBCdXQgeW91DQpzaG91bGRu4oCZdCBjb3VudCBvbiBpdC4gRXZlbiB0aGlzIHRocmVz
aG9sZCBpcyBjb25maWd1cmFibGUuDQoNCg==
