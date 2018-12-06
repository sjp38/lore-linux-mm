Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8AB296B7BFB
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 15:19:38 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id o9so929345pgv.19
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 12:19:38 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e89si1034962plb.401.2018.12.06.12.19.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 12:19:37 -0800 (PST)
From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Subject: Re: [PATCH 1/2] vmalloc: New flag for flush before releasing pages
Date: Thu, 6 Dec 2018 20:19:35 +0000
Message-ID: <f6096b80bdab59d2d21ece4ff31fcfd36bf6b809.camel@intel.com>
References: <20181128000754.18056-1-rick.p.edgecombe@intel.com>
	 <20181128000754.18056-2-rick.p.edgecombe@intel.com>
	 <4883FED1-D0EC-41B0-A90F-1A697756D41D@gmail.com>
	 <20181204160304.GB7195@arm.com>
	 <51281e69a3722014f718a6840f43b2e6773eed90.camel@intel.com>
	 <CALCETrUiEWkSjnruCbBSi8WsDm071YiU5WEqoPhZbjezS0CrFw@mail.gmail.com>
	 <20181205114148.GA15160@arm.com>
	 <CALCETrUdTShjY+tQoRsE1uR1cnL9cr2Trbz-g5=WaLGA3rWXzA@mail.gmail.com>
	 <CAKv+Gu_EEjhwbfp1mdB0Pu3ZyAsZgNeaCDArs569hAeWzHMWpw@mail.gmail.com>
	 <CALCETrVedB7yacMU=i3JaUZxiwsnM+PnABfG48K9TZK32UWshA@mail.gmail.com>
	 <20181206190115.GC10086@cisco>
	 <CALCETrUmxht8dibJPBbPudQnoe6mHsKocEBgkJ7O1eFrVBfekQ@mail.gmail.com>
In-Reply-To: <CALCETrUmxht8dibJPBbPudQnoe6mHsKocEBgkJ7O1eFrVBfekQ@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <053DB746C6CC964FB3E0B891B858E078@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "luto@kernel.org" <luto@kernel.org>, "tycho@tycho.ws" <tycho@tycho.ws>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "daniel@iogearbox.net" <daniel@iogearbox.net>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "ast@kernel.org" <ast@kernel.org>, "rostedt@goodmis.org" <rostedt@goodmis.org>, "jeyu@kernel.org" <jeyu@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jannh@google.com" <jannh@google.com>, "nadav.amit@gmail.com" <nadav.amit@gmail.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "kristen@linux.intel.com" <kristen@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "mingo@redhat.com" <mingo@redhat.com>, "Keshavamurthy, Anil S" <anil.s.keshavamurthy@intel.com>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, "mhiramat@kernel.org" <mhiramat@kernel.org>, "naveen.n.rao@linux.vnet.ibm.com" <naveen.n.rao@linux.vnet.ibm.com>, "davem@davemloft.net" <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>

T24gVGh1LCAyMDE4LTEyLTA2IGF0IDExOjE5IC0wODAwLCBBbmR5IEx1dG9taXJza2kgd3JvdGU6
DQo+IE9uIFRodSwgRGVjIDYsIDIwMTggYXQgMTE6MDEgQU0gVHljaG8gQW5kZXJzZW4gPHR5Y2hv
QHR5Y2hvLndzPiB3cm90ZToNCj4gPiANCj4gPiBPbiBUaHUsIERlYyAwNiwgMjAxOCBhdCAxMDo1
Mzo1MEFNIC0wODAwLCBBbmR5IEx1dG9taXJza2kgd3JvdGU6DQo+ID4gPiA+IElmIHdlIGFyZSBn
b2luZyB0byB1bm1hcCB0aGUgbGluZWFyIGFsaWFzLCB3aHkgbm90IGRvIGl0IGF0IHZtYWxsb2Mo
KQ0KPiA+ID4gPiB0aW1lIHJhdGhlciB0aGFuIHZmcmVlKCkgdGltZT8NCj4gPiA+IA0KPiA+ID4g
VGhhdOKAmXMgbm90IHRvdGFsbHkgbnV0cy4gRG8gd2UgZXZlciBoYXZlIGNvZGUgdGhhdCBleHBl
Y3RzIF9fdmEoKSB0bw0KPiA+ID4gd29yayBvbiBtb2R1bGUgZGF0YT8gIFBlcmhhcHMgY3J5cHRv
IGNvZGUgdHJ5aW5nIHRvIGVuY3J5cHQgc3RhdGljDQo+ID4gPiBkYXRhIGJlY2F1c2Ugb3VyIEFQ
SXMgZG9u4oCZdCB1bmRlcnN0YW5kIHZpcnR1YWwgYWRkcmVzc2VzLiAgSSBndWVzcyBpZg0KPiA+
ID4gaGlnaG1lbSBpcyBldmVyIHVzZWQgZm9yIG1vZHVsZXMsIHRoZW4gd2Ugc2hvdWxkIGJlIGZp
bmUuDQo+ID4gPiANCj4gPiA+IFJPIGluc3RlYWQgb2Ygbm90IHByZXNlbnQgbWlnaHQgYmUgc2Fm
ZXIuICBCdXQgSSBkbyBsaWtlIHRoZSBpZGVhIG9mDQo+ID4gPiByZW5hbWluZyBSaWNrJ3MgZmxh
ZyB0byBzb21ldGhpbmcgbGlrZSBWTV9YUEZPIG9yIFZNX05PX0RJUkVDVF9NQVAgYW5kDQo+ID4g
PiBtYWtpbmcgaXQgZG8gYWxsIG9mIHRoaXMuDQo+ID4gDQo+ID4gWWVhaCwgZG9pbmcgaXQgZm9y
IGV2ZXJ5dGhpbmcgYXV0b21hdGljYWxseSBzZWVtZWQgbGlrZSBpdCB3YXMvaXMNCj4gPiBnb2lu
ZyB0byBiZSBhIGxvdCBvZiB3b3JrIHRvIGRlYnVnIGFsbCB0aGUgY29ybmVyIGNhc2VzIHdoZXJl
IHRoaW5ncw0KPiA+IGV4cGVjdCBtZW1vcnkgdG8gYmUgbWFwcGVkIGJ1dCBkb24ndCBleHBsaWNp
dGx5IHNheSBpdC4gQW5kIGluDQo+ID4gcGFydGljdWxhciwgdGhlIFhQRk8gc2VyaWVzIG9ubHkg
ZG9lcyBpdCBmb3IgdXNlciBtZW1vcnksIHdoZXJlYXMgYW4NCj4gPiBhZGRpdGlvbmFsIGZsYWcg
bGlrZSB0aGlzIHdvdWxkIHdvcmsgZm9yIGV4dHJhIHBhcmFub2lkIGFsbG9jYXRpb25zDQo+ID4g
b2Yga2VybmVsIG1lbW9yeSB0b28uDQo+ID4gDQo+IA0KPiBJIGp1c3QgcmVhZCB0aGUgY29kZSwg
YW5kIEkgbG9va3MgbGlrZSB2bWFsbG9jKCkgaXMgYWxyZWFkeSB1c2luZw0KPiBoaWdobWVtIChf
X0dGUF9ISUdIKSBpZiBhdmFpbGFibGUsIHNvLCBvbiBiaWcgeDg2XzMyIHN5c3RlbXMsIGZvcg0K
PiBleGFtcGxlLCB3ZSBhbHJlYWR5IGRvbid0IGhhdmUgbW9kdWxlcyBpbiB0aGUgZGlyZWN0IG1h
cC4NCj4gDQo+IFNvIEkgc2F5IHdlIGdvIGZvciBpdC4gIFRoaXMgc2hvdWxkIGJlIHF1aXRlIHNp
bXBsZSB0byBpbXBsZW1lbnQgLS0NCj4gdGhlIHBhZ2VhdHRyIGNvZGUgYWxyZWFkeSBoYXMgYWxt
b3N0IGFsbCB0aGUgbmVlZGVkIGxvZ2ljIG9uIHg4Ni4gIFRoZQ0KPiBvbmx5IGFyY2ggc3VwcG9y
dCB3ZSBzaG91bGQgbmVlZCBpcyBhIHBhaXIgb2YgZnVuY3Rpb25zIHRvIHJlbW92ZSBhDQo+IHZt
YWxsb2MgYWRkcmVzcyByYW5nZSBmcm9tIHRoZSBhZGRyZXNzIG1hcCAoaWYgaXQgd2FzIHByZXNl
bnQgaW4gdGhlDQo+IGZpcnN0IHBsYWNlKSBhbmQgYSBmdW5jdGlvbiB0byBwdXQgaXQgYmFjay4g
IE9uIHg4NiwgdGhpcyBzaG91bGQgb25seQ0KPiBiZSBhIGZldyBsaW5lcyBvZiBjb2RlLg0KPiAN
Cj4gV2hhdCBkbyB5b3UgYWxsIHRoaW5rPyAgVGhpcyBzaG91bGQgc29sdmUgbW9zdCBvZiB0aGUg
cHJvYmxlbXMgd2UgaGF2ZS4NCj4gDQo+IElmIHdlIHJlYWxseSB3YW50ZWQgdG8gb3B0aW1pemUg
dGhpcywgd2UnZCBtYWtlIGl0IHNvIHRoYXQNCj4gbW9kdWxlX2FsbG9jKCkgYWxsb2NhdGVzIG1l
bW9yeSB0aGUgbm9ybWFsIHdheSwgdGhlbiwgbGF0ZXIgb24sIHdlDQo+IGNhbGwgc29tZSBmdW5j
dGlvbiB0aGF0LCBhbGwgYXQgb25jZSwgcmVtb3ZlcyB0aGUgbWVtb3J5IGZyb20gdGhlDQo+IGRp
cmVjdCBtYXAgYW5kIGFwcGxpZXMgdGhlIHJpZ2h0IHBlcm1pc3Npb25zIHRvIHRoZSB2bWFsbG9j
IGFsaWFzIChvcg0KPiBqdXN0IG1ha2VzIHRoZSB2bWFsbG9jIGFsaWFzIG5vdC1wcmVzZW50IHNv
IHdlIGNhbiBhZGQgcGVybWlzc2lvbnMNCj4gbGF0ZXIgd2l0aG91dCBmbHVzaGluZyksIGFuZCBm
bHVzaGVzIHRoZSBUTEIuICBBbmQgd2UgYXJyYW5nZSBmb3INCj4gdnVubWFwIHRvIHphcCB0aGUg
dm1hbGxvYyByYW5nZSwgdGhlbiBwdXQgdGhlIG1lbW9yeSBiYWNrIGludG8gdGhlDQo+IGRpcmVj
dCBtYXAsIHRoZW4gZnJlZSB0aGUgcGFnZXMgYmFjayB0byB0aGUgcGFnZSBhbGxvY2F0b3IsIHdp
dGggdGhlDQo+IGZsdXNoIGluIHRoZSBhcHByb3ByaWF0ZSBwbGFjZS4NCj4gDQo+IEkgZG9uJ3Qg
c2VlIHdoeSB0aGUgcGFnZSBhbGxvY2F0b3IgbmVlZHMgdG8ga25vdyBhYm91dCBhbnkgb2YgdGhp
cy4NCj4gSXQncyBhbHJlYWR5IG9rYXkgd2l0aCB0aGUgcGVybWlzc2lvbnMgYmVpbmcgY2hhbmdl
ZCBvdXQgZnJvbSB1bmRlciBpdA0KPiBvbiB4ODYsIGFuZCBpdCBzZWVtcyBmaW5lLiAgUmljaywg
ZG8geW91IHdhbnQgdG8gZ2l2ZSBzb21lIHZhcmlhbnQgb2YNCj4gdGhpcyBhIHRyeT8NCkhpLA0K
DQpTb3JyeSwgSSd2ZSBiZWVuIGhhdmluZyBlbWFpbCB0cm91YmxlcyB0b2RheS4NCg0KSSBmb3Vu
ZCBzb21lIGNhc2VzIHdoZXJlIHZtYXAgd2l0aCBQQUdFX0tFUk5FTF9STyBoYXBwZW5zLCB3aGlj
aCB3b3VsZCBub3Qgc2V0DQpOUC9STyBpbiB0aGUgZGlyZWN0bWFwLCBzbyBpdCB3b3VsZCBiZSBz
b3J0IG9mIGluY29uc2lzdGVudCB3aGV0aGVyIHRoZQ0KZGlyZWN0bWFwIG9mIHZtYWxsb2MgcmFu
Z2UgYWxsb2NhdGlvbnMgd2VyZSByZWFkYWJsZSBvciBub3QuIEkgY291bGRuJ3Qgc2VlIGFueQ0K
cGxhY2VzIHdoZXJlIGl0IHdvdWxkIGNhdXNlIHByb2JsZW1zIHRvZGF5IHRob3VnaC4NCg0KSSB3
YXMgcmVhZHkgdG8gYXNzdW1lIHRoYXQgYWxsIFRMQnMgZG9uJ3QgY2FjaGUgTlAsIGJlY2F1c2Ug
SSBkb24ndCBrbm93IGhvdw0KdXNhZ2VzIHdoZXJlIGEgcGFnZSBmYXVsdCBpcyB1c2VkIHRvIGxv
YWQgc29tZXRoaW5nIGNvdWxkIHdvcmsgd2l0aG91dCBsb3RzIG9mDQpmbHVzaGVzLiBJZiB0aGF0
J3MgdGhlIGNhc2UsIHRoZW4gYWxsIGFyY2hzIHdpdGggZGlyZWN0bWFwIHBlcm1pc3Npb25zIGNv
dWxkDQpzaGFyZSBhIHNpbmdsZSB2bWFsbG9jIHNwZWNpYWwgcGVybWlzc2lvbiBmbHVzaCBpbXBs
ZW1lbnRhdGlvbiB0aGF0IHdvcmtzIGxpa2UNCkFuZHkgZGVzY3JpYmVkIG9yaWdpbmFsbHkuIEl0
IGNvdWxkIGJlIGNvbnRyb2xsZWQgd2l0aCBhbg0KQVJDSF9IQVNfRElSRUNUX01BUF9QRVJNUy4g
V2Ugd291bGQganVzdCBuZWVkIHNvbWV0aGluZyBsaWtlIHNldF9wYWdlc19ucCBhbmQNCnNldF9w
YWdlc19ydyBvbiBhbnkgYXJjaHMgd2l0aCBkaXJlY3RtYXAgcGVybWlzc2lvbnMuIFNvIHNlZW1z
IHNpbXBsZXIgdG8gbWUNCihhbmQgd2hhdCBJIGhhdmUgYmVlbiBkb2luZykgdW5sZXNzIEknbSBt
aXNzaW5nIHRoZSBwcm9ibGVtLg0KDQpJZiB5b3UgYWxsIHRoaW5rIHNvIEkgY2FuIGluZGVlZCB0
YWtlIGEgc2hvdCBhdCBpdCwgSSBqdXN0IGRvbid0IHNlZSB3aGF0IHRoZQ0KcHJvYmxlbSB3YXMg
d2l0aCB0aGUgb3JpZ2luYWwgc29sdXRpb24sIHRoYXQgc2VlbXMgbGVzcyBsaWtlbHkgdG8gYnJl
YWsNCmFueXRoaW5nLg0KDQpUaGFua3MsDQoNClJpY2sNCg==
