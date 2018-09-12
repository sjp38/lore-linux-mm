Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A210F8E0002
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 13:46:57 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e62-v6so4704593itb.3
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 10:46:57 -0700 (PDT)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0108.outbound.protection.outlook.com. [104.47.41.108])
        by mx.google.com with ESMTPS id r19-v6si952571ioh.155.2018.09.12.10.46.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Sep 2018 10:46:56 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH 3/4] mm: Defer ZONE_DEVICE page initialization to the
 point where we init pgmap
Date: Wed, 12 Sep 2018 17:46:53 +0000
Message-ID: <fac5a6f4-3dda-2ec4-81ec-4a4a7ad2a571@microsoft.com>
References: <20180910232615.4068.29155.stgit@localhost.localdomain>
 <20180910234354.4068.65260.stgit@localhost.localdomain>
 <7b96298e-9590-befd-0670-ed0c9fcf53d5@microsoft.com>
 <CAKgT0UdKZVUPBk=rg5kfUuFBpuZQEKPuGw31x5O2nMyuULgi0g@mail.gmail.com>
 <CAPcyv4gEDwp8Xh4_E8RNBC_OqstwhqxkZOpvYjWd_siB4C=BEQ@mail.gmail.com>
In-Reply-To: 
 <CAPcyv4gEDwp8Xh4_E8RNBC_OqstwhqxkZOpvYjWd_siB4C=BEQ@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <6BC95DA5D70D7B4B9356E05A6683025F@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Alexander Duyck <alexander.duyck@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Michal Hocko <mhocko@suse.com>, Dave Jiang <dave.jiang@intel.com>, Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@intel.com>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

DQoNCk9uIDkvMTIvMTggMTI6NTAgUE0sIERhbiBXaWxsaWFtcyB3cm90ZToNCj4gT24gV2VkLCBT
ZXAgMTIsIDIwMTggYXQgODo0OCBBTSwgQWxleGFuZGVyIER1eWNrDQo+IDxhbGV4YW5kZXIuZHV5
Y2tAZ21haWwuY29tPiB3cm90ZToNCj4+IE9uIFdlZCwgU2VwIDEyLCAyMDE4IGF0IDY6NTkgQU0g
UGFzaGEgVGF0YXNoaW4NCj4+IDxQYXZlbC5UYXRhc2hpbkBtaWNyb3NvZnQuY29tPiB3cm90ZToN
Cj4+Pg0KPj4+IEhpIEFsZXgsDQo+Pg0KPj4gSGkgUGF2ZWwsDQo+Pg0KPj4+IFBsZWFzZSByZS1i
YXNlIG9uIGxpbnV4LW5leHQsICBtZW1tYXBfaW5pdF96b25lKCkgaGFzIGJlZW4gdXBkYXRlZCB0
aGVyZQ0KPj4+IGNvbXBhcmVkIHRvIG1haW5saW5lLiBZb3UgbWlnaHQgZXZlbiBmaW5kIGEgd2F5
IHRvIHVuaWZ5IHNvbWUgcGFydHMgb2YNCj4+PiBtZW1tYXBfaW5pdF96b25lIGFuZCBtZW1tYXBf
aW5pdF96b25lX2RldmljZSBhcyBtZW1tYXBfaW5pdF96b25lKCkgaXMgYQ0KPj4+IGxvdCBzaW1w
bGVyIG5vdy4NCj4+DQo+PiBUaGlzIHBhdGNoIGFwcGxpZWQgdG8gdGhlIGxpbnV4LW5leHQgdHJl
ZSB3aXRoIG9ubHkgYSBsaXR0bGUgYml0IG9mDQo+PiBmdXp6LiBJdCBsb29rcyBsaWtlIGl0IGlz
IG1vc3RseSBkdWUgdG8gc29tZSBjb2RlIHlvdSBoYWQgYWRkZWQgYWJvdmUNCj4+IHRoZSBmdW5j
dGlvbiBhcyB3ZWxsLiBJIGhhdmUgdXBkYXRlZCB0aGlzIHBhdGNoIHNvIHRoYXQgaXQgd2lsbCBh
cHBseQ0KPj4gdG8gYm90aCBsaW51eCBhbmQgbGludXgtbmV4dCBieSBqdXN0IG1vdmluZyB0aGUg
bmV3IGZ1bmN0aW9uIHRvDQo+PiB1bmRlcm5lYXRoIG1lbW1hcF9pbml0X3pvbmUgaW5zdGVhZCBv
ZiBhYm92ZSBpdC4NCj4+DQo+Pj4gSSB0aGluayBfX2luaXRfc2luZ2xlX3BhZ2UoKSBzaG91bGQg
c3RheSBsb2NhbCB0byBwYWdlX2FsbG9jLmMgdG8ga2VlcA0KPj4+IHRoZSBpbmxpbmluZyBvcHRp
bWl6YXRpb24uDQo+Pg0KPj4gSSBhZ3JlZS4gSW4gYWRkaXRpb24gaXQgd2lsbCBtYWtlIHB1bGxp
bmcgY29tbW9uIGluaXQgdG9nZXRoZXIgaW50bw0KPj4gb25lIHNwYWNlIGVhc2llci4gSSB3b3Vs
ZCByYXRoZXIgbm90IGhhdmUgdXMgY3JlYXRlIGFuIG9wcG9ydHVuaXR5IGZvcg0KPj4gdGhpbmdz
IHRvIGZ1cnRoZXIgZGl2ZXJnZSBieSBtYWtpbmcgaXQgYXZhaWxhYmxlIGZvciBhbnlib2R5IHRv
IHVzZS4NCj4gDQo+IEknbGwgYnV5IHRoZSBpbmxpbmUgYXJndW1lbnQgZm9yIGtlZXBpbmcgdGhl
IG5ldyByb3V0aW5lIGluDQo+IHBhZ2VfYWxsb2MuYywgYnV0IEkgb3RoZXJ3aXNlIGRvIG5vdCBz
ZWUgdGhlIGRpdmVyZ2VuY2UgZGFuZ2VyIG9yDQo+ICJtYWtpbmcgX19pbml0X3NpbmdsZV9wYWdl
KCkgYXZhaWxhYmxlIGZvciBhbnlib2R5IiBnaXZlbiB0aGUgdGhlDQo+IGRlY2xhcmF0aW9uIGlz
IGxpbWl0ZWQgaW4gc2NvcGUgdG8gYSBtbS8gbG9jYWwgaGVhZGVyIGZpbGUuDQo+IA0KDQpIaSBE
YW4sDQoNCkl0IGlzIG11Y2ggaGFyZGVyIGZvciBjb21waWxlciB0byBkZWNpZGUgdGhhdCBmdW5j
dGlvbiBjYW4gYmUgaW5saW5lZA0Kb25jZSBpdCBpcyBub24tc3RhdGljLiBPZiBjb3Vyc2UsIHdl
IGNhbiBzaW1wbHkgbW92ZSB0aGlzIGZ1bmN0aW9uIHRvIGENCmhlYWRlciBmaWxlLCBhbmQgZGVj
bGFyZSBpdCBpbmxpbmUgdG8gYmVnaW4gd2l0aC4NCg0KQnV0LCBzdGlsbCBfX2luaXRfc2luZ2xl
X3BhZ2UoKSBpcyBzbyBwZXJmb3JtYW5jZSBzZW5zaXRpdmUsIHRoYXQgSSdkDQpsaWtlIHRvIHJl
ZHVjZSBudW1iZXIgb2YgY2FsbGVycyB0byB0aGlzIGZ1bmN0aW9uLCBhbmQga2VlcCBpdCBpbiAu
YyBmaWxlLg0KDQpUaGFuayB5b3UsDQpQYXZlbA==
