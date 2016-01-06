Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id DEE176B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 11:57:16 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id yy13so143868167pab.3
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 08:57:16 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id k83si51809825pfj.103.2016.01.06.08.57.15
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 08:57:15 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH v7 3/3] x86, mce: Add __mcsafe_copy()
Date: Wed, 6 Jan 2016 16:57:13 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F39FA3D50@ORSMSX114.amr.corp.intel.com>
References: <cover.1451952351.git.tony.luck@intel.com>
	<5b0243c5df825ad0841f4bb5584cd15d3f013f09.1451952351.git.tony.luck@intel.com>
	<CAPcyv4jjWT3Od_XvGpVb+O7MT95mBRXviPXi1zUfM5o+kN4CUA@mail.gmail.com>
	<A527EC4B-4069-4FDE-BE4C-5279C45BCABE@intel.com>
	<CAPcyv4iijhdXnD-4PuHkzbhhPra8eCRZ=df3XTE=z-efbQmVww@mail.gmail.com>
 <CAPcyv4g1dGC2YMN+JZPKhzbCm8PQJ7nJqV4JGjJ3w1PAf12v+Q@mail.gmail.com>
In-Reply-To: <CAPcyv4g1dGC2YMN+JZPKhzbCm8PQJ7nJqV4JGjJ3w1PAf12v+Q@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew
 Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

Pj4gSSBkbyBzZWxlY3QgaXQsIGJ1dCBieSByYW5kY29uZmlnIEkgc3RpbGwgbmVlZCB0byBoYW5k
bGUgdGhlDQo+PiBDT05GSUdfWDg2X01DRT1uIGNhc2UuDQo+Pg0KPj4+IEknbSBzZXJpb3VzbHkg
d29uZGVyaW5nIHdoZXRoZXIgdGhlIGlmZGVmIHN0aWxsIG1ha2VzIHNlbnNlLiBOb3cgSSBkb24n
dCBoYXZlIGFuIGV4dHJhIGV4Y2VwdGlvbiB0YWJsZSBhbmQgcm91dGluZXMgdG8gc29ydC9zZWFy
Y2gvZml4dXAsIGl0IGRvZXNuJ3Qgc2VlbSBhcyB1c2VmdWwgYXMgaXQgd2FzIGEgZmV3IGl0ZXJh
dGlvbnMgYWdvLg0KPj4NCj4+IEVpdGhlciB3YXkgaXMgb2sgd2l0aCBtZS4gIFRoYXQgc2FpZCwg
dGhlIGV4dHJhIGRlZmluaXRpb25zIHRvIGFsbG93DQo+PiBpdCBjb21waWxlIG91dCB3aGVuIG5v
dCBlbmFibGVkIGRvbid0IHNlZW0gdG9vIG9uZXJvdXMuDQo+DQo+IFRoaXMgd29ya3MgZm9yIG1l
LCBiZWNhdXNlIGFsbCB3ZSBuZWVkIGlzIHRoZSBkZWZpbml0aW9ucy4gIEFzIGxvbmcgYXMNCj4g
d2UgZG9uJ3QgYXR0ZW1wdCB0byBsaW5rIHRvIG1jc2FmZV9jb3B5KCkgd2UgZ2V0IHRoZSBiZW5l
Zml0IG9mDQo+IGNvbXBpbGluZyB0aGlzIG91dCB3aGVuIGRlLXNlbGVjdGVkOg0KDQpJdCBzZWVt
cyAgdGhhdCBLY29uZmlnJ3MgInNlbGVjdCIgc3RhdGVtZW50IGRvZXNuJ3QgYXV0by1zZWxlY3Qg
b3RoZXIgdGhpbmdzDQp0aGF0IGFyZSBkZXBlbmRlbmNpZXMgb2YgdGhlIHN5bWJvbCB5b3UgY2hv
b3NlLg0KDQpDT05GSUdfTUNFX0tFUk5FTF9SRUNPVkVSWSByZWFsbHkgaXMgZGVwZW5kZW50IG9u
DQpDT05GSUdfWDg2X01DRSAuLi4gaGF2aW5nIHRoZSBjb2RlIGZvciB0aGUgX19tY3NhZmVfY29w
eSgpDQpsaW5rZWQgaW50byB0aGUga2VybmVsIHdvbid0IGRvIHlvdSBhbnkgZ29vZCB3aXRob3V0
IGEgbWFjaGluZQ0KY2hlY2sgaGFuZGxlciB0aGF0IGp1bXBzIHRvIHRoZSBmaXh1cCBjb2RlLg0K
DQpTbyBJIHRoaW5rIHlvdSBoYXZlIHRvIHNlbGVjdCBYODZfTUNFIGFzIHdlbGwgKG9yIEtjb25m
aWcgbmVlZHMNCnRvIGJlIHRhdWdodCB0byBkbyBpdCBhdXRvbWF0aWNhbGx5IC4uLiBidXQgSSBo
YXZlIGEgbmFnZ2luZyBmZWVsaW5nDQp0aGF0IHRoaXMgaXMga25vd24gYmVoYXZpb3IpLg0KDQot
VG9ueQ0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
