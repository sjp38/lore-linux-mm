Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1939F6B007E
	for <linux-mm@kvack.org>; Sat, 30 Apr 2016 02:14:51 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k129so256311524iof.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 23:14:51 -0700 (PDT)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id l128si3843182iof.211.2016.04.29.23.14.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 23:14:50 -0700 (PDT)
From: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Subject: RE: [RFC PATCH v1 00/18] x86: Secure Memory Encryption (AMD)
Date: Sat, 30 Apr 2016 06:13:33 +0000
Message-ID: <94D0CD8314A33A4D9D801C0FE68B402963918FDA@G4W3296.americas.hpqcorp.net>
References: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160426225553.13567.19459.stgit@tlendack-t1.amdoffice.net>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Cc: =?utf-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBsaW51eC1rZXJuZWwtb3duZXJA
dmdlci5rZXJuZWwub3JnIFttYWlsdG86bGludXgta2VybmVsLQ0KPiBvd25lckB2Z2VyLmtlcm5l
bC5vcmddIE9uIEJlaGFsZiBPZiBUb20gTGVuZGFja3kNCj4gU2VudDogVHVlc2RheSwgQXByaWwg
MjYsIDIwMTYgNTo1NiBQTQ0KPiBTdWJqZWN0OiBbUkZDIFBBVENIIHYxIDAwLzE4XSB4ODY6IFNl
Y3VyZSBNZW1vcnkgRW5jcnlwdGlvbiAoQU1EKQ0KPiANCj4gVGhpcyBSRkMgcGF0Y2ggc2VyaWVz
IHByb3ZpZGVzIHN1cHBvcnQgZm9yIEFNRCdzIG5ldyBTZWN1cmUgTWVtb3J5DQo+IEVuY3J5cHRp
b24gKFNNRSkgZmVhdHVyZS4NCj4gDQo+IFNNRSBjYW4gYmUgdXNlZCB0byBtYXJrIGluZGl2aWR1
YWwgcGFnZXMgb2YgbWVtb3J5IGFzIGVuY3J5cHRlZCB0aHJvdWdoIHRoZQ0KPiBwYWdlIHRhYmxl
cy4gQSBwYWdlIG9mIG1lbW9yeSB0aGF0IGlzIG1hcmtlZCBlbmNyeXB0ZWQgd2lsbCBiZSBhdXRv
bWF0aWNhbGx5DQo+IGRlY3J5cHRlZCB3aGVuIHJlYWQgZnJvbSBEUkFNIGFuZCB3aWxsIGJlIGF1
dG9tYXRpY2FsbHkgZW5jcnlwdGVkIHdoZW4NCj4gd3JpdHRlbiB0byBEUkFNLiBEZXRhaWxzIG9u
IFNNRSBjYW4gZm91bmQgaW4gdGhlIGxpbmtzIGJlbG93Lg0KPiANCi4uLg0KPiAuLi4gIENlcnRh
aW4gZGF0YSBtdXN0IGJlIGFjY291bnRlZCBmb3INCj4gYXMgaGF2aW5nIGJlZW4gcGxhY2VkIGlu
IG1lbW9yeSBiZWZvcmUgU01FIHdhcyBlbmFibGVkIChFRkksIGluaXRyZCwgZXRjLikNCj4gYW5k
IGFjY2Vzc2VkIGFjY29yZGluZ2x5Lg0KPiANCi4uLg0KPiAgICAgICB4ODYvZWZpOiBBY2Nlc3Mg
RUZJIHJlbGF0ZWQgdGFibGVzIGluIHRoZSBjbGVhcg0KPiAgICAgICB4ODY6IEFjY2VzcyBkZXZp
Y2UgdHJlZSBpbiB0aGUgY2xlYXINCj4gICAgICAgeDg2OiBEbyBub3Qgc3BlY2lmeSBlbmNyeXB0
ZWQgbWVtb3J5IGZvciBWR0EgbWFwcGluZw0KDQpJZiB0aGUgU01FIGVuY3J5cHRpb24ga2V5ICJp
cyBjcmVhdGVkIHJhbmRvbWx5IGVhY2ggdGltZSBhIHN5c3RlbSBpcyBib290ZWQsIg0KZGF0YSBv
biBOVkRJTU1zIHdvbid0IGRlY3J5cHQgcHJvcGVybHkgb24gdGhlIG5leHQgYm9vdC4gIFlvdSBu
ZWVkIHRvIGV4Y2x1ZGUNCnBlcnNpc3RlbnQgbWVtb3J5IHJlZ2lvbnMgKHJlcG9ydGVkIGluIHRo
ZSBVRUZJIG1lbW9yeSBtYXAgYXMgDQpFZmlSZXNlcnZlZE1lbW9yeVR5cGUgd2l0aCB0aGUgTlYg
YXR0cmlidXRlLCBvciBhcyBFZmlQZXJzaXN0ZW50TWVtb3J5KS4NCg0KUGVyaGFwcyB0aGUgU0VW
IGZlYXR1cmUgd2lsbCBhbGxvdyBrZXkgZXhwb3J0L2ltcG9ydCB0aGF0IGNvdWxkIHdvcmsgZm9y
DQpOVkRJTU1zLg0KDQotLS0NClJvYmVydCBFbGxpb3R0LCBIUEUgUGVyc2lzdGVudCBNZW1vcnkN
Cg0KDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
