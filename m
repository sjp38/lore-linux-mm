Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8586C6B0253
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 19:38:05 -0400 (EDT)
Received: by pdbmi9 with SMTP id mi9so19372730pdb.3
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 16:38:05 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id qh6si9807563pdb.33.2015.08.20.16.38.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 20 Aug 2015 16:38:04 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v5 2/2] mm: hugetlb: proc: add HugetlbPages field to
 /proc/PID/status
Date: Thu, 20 Aug 2015 23:34:51 +0000
Message-ID: <20150820233450.GB10807@hori1.linux.bs1.fc.nec.co.jp>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
 <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1440059182-19798-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150820110004.GB4632@dhcp22.suse.cz>
In-Reply-To: <20150820110004.GB4632@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-ID: <7382E480AE244F4CB53C740BEE242B42@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, =?utf-8?B?SsO2cm4gRW5nZWw=?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

T24gVGh1LCBBdWcgMjAsIDIwMTUgYXQgMDE6MDA6MDVQTSArMDIwMCwgTWljaGFsIEhvY2tvIHdy
b3RlOg0KPiBPbiBUaHUgMjAtMDgtMTUgMDg6MjY6MjcsIE5hb3lhIEhvcmlndWNoaSB3cm90ZToN
Cj4gPiBDdXJyZW50bHkgdGhlcmUncyBubyBlYXN5IHdheSB0byBnZXQgcGVyLXByb2Nlc3MgdXNh
Z2Ugb2YgaHVnZXRsYiBwYWdlcywNCj4gDQo+IElzIHRoaXMgcmVhbGx5IHRoZSBjYXNlIGFmdGVy
IHlvdXIgcHJldmlvdXMgcGF0Y2g/IFlvdSBoYXZlIGJvdGggDQo+IEh1Z2V0bGJQYWdlcyBhbmQg
S2VybmVsUGFnZVNpemUgd2hpY2ggc2hvdWxkIGJlIHN1ZmZpY2llbnQgbm8/DQoNCldlIGNhbiBj
YWxjdXJhdGUgaXQgZnJvbSB0aGVzZSBpbmZvLCBzbyBzYXlpbmcgIm5vIGVhc3kgd2F5IiB3YXMg
aW5jb3JyZWN0IDooDQoNCj4gUmVhZGluZyBhIHNpbmdsZSBmaWxlIGlzLCBvZiBjb3Vyc2UsIGVh
c2llciBidXQgaXMgaXQgcmVhbGx5IHdvcnRoIHRoZQ0KPiBhZGRpdGlvbmFsIGNvZGU/IEkgaGF2
ZW4ndCByZWFsbHkgbG9va2VkIGF0IHRoZSBwYXRjaCBzbyBJIG1pZ2h0IGJlDQo+IG1pc3Npbmcg
c29tZXRoaW5nIGJ1dCB3aGF0IHdvdWxkIGJlIGFuIGFkdmFudGFnZSBvdmVyIHJlYWRpbmcNCj4g
L3Byb2MvPHBpZD4vc21hcHMgYW5kIGV4dHJhY3RpbmcgdGhlIGluZm9ybWF0aW9uIGZyb20gdGhl
cmU/DQoNCk15IGZpcnN0IGlkZWEgd2FzIGp1c3QgInVzZXJzIHNob3VsZCBmZWVsIGl0IHVzZWZ1
bCIsIGJ1dCBwZXJtaXNzaW9uIGFzIERhdmlkDQpjb21tZW50ZWQgc291bmRzIGEgZ29vZCB0ZWNo
bmljYWwgcmVhc29uIHRvIG1lLg0KDQpUaGFua3MsDQpOYW95YSBIb3JpZ3VjaGk=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
