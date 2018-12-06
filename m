Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0661A6B7905
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 03:38:48 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 82so13247257pfs.20
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 00:38:47 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id c22si20182625pgb.254.2018.12.06.00.38.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 00:38:47 -0800 (PST)
From: "Sakkinen, Jarkko" <jarkko.sakkinen@intel.com>
Subject: Re: [RFC v2 06/13] mm: Add the encrypt_mprotect() system call
Date: Thu, 6 Dec 2018 08:38:42 +0000
Message-ID: <e1689769d007da71a61c3bf5de823ef919182ab8.camel@intel.com>
References: <cover.1543903910.git.alison.schofield@intel.com>
	 <0c5d9e96c75445ced3b22d9359a8cb3fa2b6f8ad.1543903910.git.alison.schofield@intel.com>
In-Reply-To: <0c5d9e96c75445ced3b22d9359a8cb3fa2b6f8ad.1543903910.git.alison.schofield@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <5EA6810AA7DCF44D89A204727D55EBB5@intel.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tglx@linutronix.de" <tglx@linutronix.de>, "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "peterz@infradead.org" <peterz@infradead.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "luto@kernel.org" <luto@kernel.org>, "bp@alien8.de" <bp@alien8.de>, Hansen,, Jun

T24gTW9uLCAyMDE4LTEyLTAzIGF0IDIzOjM5IC0wODAwLCBBbGlzb24gU2Nob2ZpZWxkIHdyb3Rl
Og0KPiBJbXBsZW1lbnQgbWVtb3J5IGVuY3J5cHRpb24gd2l0aCBhIG5ldyBzeXN0ZW0gY2FsbCB0
aGF0IGlzIGFuDQo+IGV4dGVuc2lvbiBvZiB0aGUgbGVnYWN5IG1wcm90ZWN0KCkgc3lzdGVtIGNh
bGwuDQo+IA0KPiBJbiBlbmNyeXB0X21wcm90ZWN0IHRoZSBjYWxsZXIgbXVzdCBwYXNzIGEgaGFu
ZGxlIHRvIGEgcHJldmlvdXNseQ0KPiBhbGxvY2F0ZWQgYW5kIHByb2dyYW1tZWQgZW5jcnlwdGlv
biBrZXkuIFZhbGlkYXRlIHRoZSBrZXkgYW5kIHN0b3JlDQo+IHRoZSBrZXlpZCBiaXRzIGluIHRo
ZSB2bV9wYWdlX3Byb3QgZm9yIGVhY2ggVk1BIGluIHRoZSBwcm90ZWN0aW9uDQo+IHJhbmdlLg0K
PiANCj4gU2lnbmVkLW9mZi1ieTogQWxpc29uIFNjaG9maWVsZCA8YWxpc29uLnNjaG9maWVsZEBp
bnRlbC5jb20+DQo+IFNpZ25lZC1vZmYtYnk6IEtpcmlsbCBBLiBTaHV0ZW1vdiA8a2lyaWxsLnNo
dXRlbW92QGxpbnV4LmludGVsLmNvbT4NCg0KV2h5IHlvdSBkb24ndCB1c2UgdGhhdCBOT19LRVkg
aW4gdGhpcyBwYXRjaD8NCg0KL0phcmtrbw0K
