Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2EEDE6B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 17:51:29 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id v86so19289403pfa.2
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 14:51:29 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id wf3si11821674pac.218.2015.12.16.14.51.28
        for <linux-mm@kvack.org>;
        Wed, 16 Dec 2015 14:51:28 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCHV3 1/3] x86, ras: Add new infrastructure for machine
 check fixup tables
Date: Wed, 16 Dec 2015 22:51:04 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F39F87180@ORSMSX114.amr.corp.intel.com>
References: <cover.1450283985.git.tony.luck@intel.com>
 <2e91c18f23be90b33c2cbfff6cce6b6f50592a96.1450283985.git.tony.luck@intel.com>
 <CALCETrVHqi9ixUQbeN82T14CVom1N6QegSNR+r=jtjRgcfC0kg@mail.gmail.com>
In-Reply-To: <CALCETrVHqi9ixUQbeN82T14CVom1N6QegSNR+r=jtjRgcfC0kg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Ingo Molnar <mingo@kernel.org>, Borislav Petkov <bp@alien8.de>, Andrew
 Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

PiBMb29rcyBnZW5lcmFsbHkgZ29vZC4NCj4NCj4gUmV2aWV3ZWQtYnk6IEFuZHkgTHV0b21pcnNr
aSA8bHV0b0BrZXJuZWwub3JnPg0KDQpZb3Ugc2F5IHRoYXQgdG8gcGFydCAxLzMgLi4uIHdoYXQg
aGFwcGVucyB3aGVuIHlvdSBnZXQgdG8gcGFydCAzLzMgYW5kIHlvdQ0KcmVhZCBteSBhdHRlbXB0
cyBhdCB3cml0aW5nIHg4NiBhc3NlbWJseSBjb2RlPw0KDQo+PiArI2lmZGVmIENPTkZJR19NQ0Vf
S0VSTkVMX1JFQ09WRVJZDQo+PiAraW50IGZpeHVwX21jZXhjZXB0aW9uKHN0cnVjdCBwdF9yZWdz
ICpyZWdzKQ0KPj4gK3sNCj4+ICsgICAgICAgY29uc3Qgc3RydWN0IGV4Y2VwdGlvbl90YWJsZV9l
bnRyeSAqZml4dXA7DQo+PiArICAgICAgIHVuc2lnbmVkIGxvbmcgbmV3X2lwOw0KPj4gKw0KPj4g
KyAgICAgICBmaXh1cCA9IHNlYXJjaF9tY2V4Y2VwdGlvbl90YWJsZXMocmVncy0+aXApOw0KPj4g
KyAgICAgICBpZiAoZml4dXApIHsNCj4+ICsgICAgICAgICAgICAgICBuZXdfaXAgPSBleF9maXh1
cF9hZGRyKGZpeHVwKTsNCj4+ICsNCj4+ICsgICAgICAgICAgICAgICByZWdzLT5pcCA9IG5ld19p
cDsNCj4NCj4gIFlvdSBjb3VsZCB2ZXJ5IGVhc2lseSBzYXZlIGEgbGluZSBvZiBjb2RlIGhlcmUg
OikNCg0KVHdvIGxpbmVzICh0aGUgZGVjbGFyYXRpb24gb2YgdGhlIHZhcmlhYmxlIGNhbiBnbyBh
d2F5IGFzIHdlbGwpLg0KV2lsbCBpbmNsdWRlIGlmIHdlIG5lZWQgYSBWNCB3aGVuIGV2ZXJ5b25l
IGVsc2UgZ2V0cyB0byBjb21tZW50aW5nLg0KDQotVG9ueQ0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
