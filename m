Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id C0FCE6B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 17:17:33 -0500 (EST)
Received: by pfd5 with SMTP id 5so10790556pfd.2
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:17:33 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id t67si3702438pfa.123.2015.12.11.14.17.32
        for <linux-mm@kvack.org>;
        Fri, 11 Dec 2015 14:17:32 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCHV2 3/3] x86, ras: Add mcsafe_memcpy() function to recover
 from machine checks
Date: Fri, 11 Dec 2015 22:17:10 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F39F82EEF@ORSMSX114.amr.corp.intel.com>
References: <cover.1449861203.git.tony.luck@intel.com>
 <23b2515da9d06b198044ad83ca0a15ba38c24e6e.1449861203.git.tony.luck@intel.com>
 <CALCETrU026BDNk=WZWrsgzpe0yT2Z=DK4Cn6mNYi6yBgsh-+nQ@mail.gmail.com>
 <3908561D78D1C84285E8C5FCA982C28F39F82D87@ORSMSX114.amr.corp.intel.com>
 <CALCETrVeALAHbiLytBO=2WAwifon=K-wB6mCCWBfuuUu7dbBVA@mail.gmail.com>
In-Reply-To: <CALCETrVeALAHbiLytBO=2WAwifon=K-wB6mCCWBfuuUu7dbBVA@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew
 Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

PiBJJ20gbWlzc2luZyBzb21ldGhpbmcsIHRob3VnaC4gIFRoZSBub3JtYWwgZml4dXBfZXhjZXB0
aW9uIHBhdGgNCj4gZG9lc24ndCB0b3VjaCByYXggYXQgYWxsLiAgVGhlIG1lbW9yeV9mYWlsdXJl
IHBhdGggZG9lcy4gIEJ1dCBjb3VsZG4ndA0KPiB5b3UgZGlzdGluZ3Vpc2ggdGhlbSBieSBqdXN0
IHBvaW50aW5nIHRoZSBleGNlcHRpb24gaGFuZGxlcnMgYXQNCj4gZGlmZmVyZW50IGxhbmRpbmcg
cGFkcz8NCg0KUGVyaGFwcyBJJ20ganVzdCB0cnlpbmcgdG8gdGFrZSBhIHNob3J0IGN1dCB0byBh
dm9pZCB3cml0aW5nDQpzb21lIGNsZXZlciBmaXh1cCBjb2RlIGZvciB0aGUgdGFyZ2V0IGlwIHRo
YXQgZ29lcyBpbnRvIHRoZQ0KZXhjZXB0aW9uIHRhYmxlLg0KDQpGb3IgX19jb3B5X3VzZXJfbm9j
YWNoZSgpIHdlIGhhdmUgZm91ciBwb3NzaWJsZSB0YXJnZXRzDQpmb3IgZml4dXAgZGVwZW5kaW5n
IG9uIHdoZXJlIHdlIHdlcmUgaW4gdGhlIGZ1bmN0aW9uLg0KDQogICAgICAgIC5zZWN0aW9uIC5m
aXh1cCwiYXgiDQozMDogICAgIHNobGwgJDYsJWVjeA0KICAgICAgICBhZGRsICVlY3gsJWVkeA0K
ICAgICAgICBqbXAgNjBmDQo0MDogICAgIGxlYSAoJXJkeCwlcmN4LDgpLCVyZHgNCiAgICAgICAg
am1wIDYwZg0KNTA6ICAgICBtb3ZsICVlY3gsJWVkeA0KNjA6ICAgICBzZmVuY2UNCiAgICAgICAg
am1wIGNvcHlfdXNlcl9oYW5kbGVfdGFpbA0KICAgICAgICAucHJldmlvdXMNCg0KTm90ZSB0aGF0
IHRoaXMgY29kZSBhbHNvIHRha2VzIGEgc2hvcnRjdXQNCmJ5IGp1bXBpbmcgdG8gY29weV91c2Vy
X2hhbmRsZV90YWlsKCkgdG8NCmZpbmlzaCB1cCB0aGUgY29weSBhIGJ5dGUgYXQgYSB0aW1lIC4u
LiBhbmQNCnJ1bm5pbmcgYmFjayBpbnRvIHRoZSBzYW1lIHBhZ2UgZmF1bHQgYSAybmQNCnRpbWUg
dG8gbWFrZSBzdXJlIHRoZSBieXRlIGNvdW50IGlzIGV4YWN0bHkNCnJpZ2h0Lg0KDQpJIHJlYWxs
eSwgcmVhbGx5LCBkb24ndCB3YW50IHRvIHJ1biBiYWNrIGludG8NCnRoZSBwb2lzb24gYWdhaW4u
ICBJdCB3b3VsZCBwcm9iYWJseSB3b3JrLCBidXQNCmJlY2F1c2UgY3VycmVudCBnZW5lcmF0aW9u
IEludGVsIGNwdXMgYnJvYWRjYXN0IG1hY2hpbmUNCmNoZWNrcyB0byBldmVyeSBsb2dpY2FsIGNw
dSwgaXQgaXMgYSBsb3Qgb2Ygb3ZlcmhlYWQsDQphbmQgcG90ZW50aWFsbHkgcmlza3kuDQoNCj4g
QWxzbywgd291bGQgaXQgYmUgbW9yZSBzdHJhaWdodGZvcndhcmQgaWYgdGhlIG1jZXhjZXB0aW9u
IGxhbmRpbmcgcGFkDQo+IGxvb2tlZCB1cCB0aGUgdmEgLT4gcGEgbWFwcGluZyBieSBpdHNlbGY/
ICBPciBpcyB0aGF0IHNvbWVob3cgbm90DQo+IHJlbGlhYmxlPw0KDQpJZiB3ZSBkaWQgZ2V0IGFs
bCB0aGUgYWJvdmUgcmlnaHQsIHRoZW4gd2UgY291bGQgaGF2ZQ0KdGFyZ2V0IHVzZSB2aXJ0X3Rv
X3BoeXMoKSB0byBjb252ZXJ0IHRvIHBoeXNpY2FsIC4uLg0KSSBkb24ndCBzZWUgdGhhdCB0aGlz
IHBhcnQgd291bGQgYmUgYSBwcm9ibGVtLg0KDQotVG9ueQ0KDQoNCg0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
