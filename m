Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id DA44B6B0257
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 11:29:55 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id cy9so284551259pac.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 08:29:55 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id 12si5894358pfn.169.2016.01.08.08.29.54
        for <linux-mm@kvack.org>;
        Fri, 08 Jan 2016 08:29:54 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH v7 1/3] x86: Add classes to exception tables
Date: Fri, 8 Jan 2016 16:29:49 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F39FA7163@ORSMSX114.amr.corp.intel.com>
References: <cover.1451952351.git.tony.luck@intel.com>
 <b5dc7a1ee68f48dc61c10959b2209851f6eb6aab.1451952351.git.tony.luck@intel.com>
 <20160106123346.GC19507@pd.tnic>
 <CALCETrVXD5YB_1UzR4LnSOCgV+ZzhDi9JRZrcxhMAjbvSzO6MQ@mail.gmail.com>
 <20160106175948.GA16647@pd.tnic>
 <CALCETrXsC9eiQ8yF555-8G88pYEms4bDsS060e24FoadAOK+kw@mail.gmail.com>
 <20160106194222.GC16647@pd.tnic> <20160107121131.GB23768@pd.tnic>
 <20160108014526.GA31242@agluck-desk.sc.intel.com>
 <20160108103733.GC12132@pd.tnic>
In-Reply-To: <20160108103733.GC12132@pd.tnic>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

Pj4gK0VYUE9SVF9TWU1CT0woZXhfaGFuZGxlcl9kZWZhdWx0KTsNCj4NCj4gV2h5IG5vdCBFWFBP
UlRfU1lNQk9MX0dQTCgpID8NCj4NCj4gV2UgZG8gbm90IGNhcmUgYWJvdXQgZXh0ZXJuYWwgbW9k
dWxlcy4NCg0KSSB0aG91Z2h0IHRoZSBndWlkZWxpbmUgd2FzIHRoYXQgbmV3IGZlYXR1cmVzIGFy
ZSBHUEwsIGJ1dCBjaGFuZ2VzDQp0byBleGlzdGluZyBmZWF0dXJlcyBzaG91bGRuJ3QgYnJlYWsg
YnkgYWRkaW5nIG5ldyBHUEwgcmVxdWlyZW1lbnRzLg0KDQpUaGUgcG9pbnQgaXMgbW9vdCB0aG91
Z2ggYmVjYXVzZSAgdGhlIHNoYXJlZCBoYWxsdWNpbmF0aW9ucyB3b3JlDQpvZmYgdGhpcyBtb3Ju
aW5nIGFuZCBJIHJlYWxpemVkIHRoYXQgaGF2aW5nIHRoZSAiaGFuZGxlciIgYmUgYSBwb2ludGVy
DQp0byBhIGZ1bmN0aW9uIGNhbid0IHdvcmsuIFdlJ3JlIHN0b3JpbmcgdGhlIDMyLWJpdCBzaWdu
ZWQgb2Zmc2V0IGZyb20NCnRoZSBleHRhYmxlIHRvIHRoZSB0YXJnZXQgYWRkcmVzcy4gVGhpcyBp
cyBmaW5lIGlmIHRoZSB0YWJsZSBhbmQgdGhlDQphZGRyZXNzIGFyZSBjbG9zZSB0b2dldGhlci4g
QnV0IGZvciBtb2R1bGVzIHdlIGhhdmUgYW4gZXhjZXB0aW9uDQp0YWJsZSB3aGVyZXZlciB2bWFs
bG9jKCkgbG9hZGVkIHRoZSBtb2R1bGUsIGFuZCBhIGZ1bmN0aW9uIGJhY2sNCmluIHRoZSBiYXNl
IGtlcm5lbC4NCg0KU28gYmFjayB0byB5b3VyICIubG9uZyAwIiBmb3IgdGhlIGRlZmF1bHQgY2Fz
ZS4gIEFuZCBpZiB3ZSB3YW50IHRvIGFsbG93DQptb2R1bGVzIHRvIHVzZSBhbnkgb2YgdGhlIG5l
dyBoYW5kbGVycywgdGhlbiB3ZSBjYW4ndCB1c2UNCnJlbGF0aXZlIGZ1bmN0aW9uIHBvaW50ZXJz
IGZvciB0aGVtIGVpdGhlci4NCg0KU28gSSdtIGxvb2tpbmcgYXQgbWFraW5nIHRoZSBuZXcgZmll
bGQganVzdCBhIHNpbXBsZSBpbnRlZ2VyIGFuZCB1c2luZw0KaXQgdG8gaW5kZXggYW4gYXJyYXkg
b2YgZnVuY3Rpb24gcG9pbnRlcnMgKGxpa2UgaW4gdjcpLg0KDQpVbmxlc3Mgc29tZW9uZSBoYXMg
YSBiZXR0ZXIgaWRlYT8NCg0KLVRvbnkNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
