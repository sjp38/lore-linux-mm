Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2046B0069
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 23:50:13 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 72so9459128itk.3
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 20:50:13 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id 29si42294iol.168.2017.10.19.20.50.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 20:50:12 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH -mm -V2] mm, pagemap: Fix soft dirty marking for PMD
 migration entry
Date: Fri, 20 Oct 2017 03:48:53 +0000
Message-ID: <52a62b0e-f525-f532-3723-b8baf54357bf@ah.jp.nec.com>
References: <20171019151046.3443-1-ying.huang@intel.com>
In-Reply-To: <20171019151046.3443-1-ying.huang@intel.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="utf-8"
Content-ID: <2DA51B898B8A6F4EBCE48EA950273C60@gisp.nec.co.jp>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Arnd Bergmann <arnd@arndb.de>, Hugh Dickins <hughd@google.com>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Daniel Colascione <dancol@google.com>, Zi Yan <zi.yan@cs.rutgers.edu>

DQoNCk9uIDEwLzIwLzIwMTcgMTI6MTAgQU0sIEh1YW5nLCBZaW5nIHdyb3RlOg0KPiBGcm9tOiBI
dWFuZyBZaW5nIDx5aW5nLmh1YW5nQGludGVsLmNvbT4NCj4gDQo+IE5vdywgd2hlbiB0aGUgcGFn
ZSB0YWJsZSBpcyB3YWxrZWQgaW4gdGhlIGltcGxlbWVudGF0aW9uIG9mDQo+IC9wcm9jLzxwaWQ+
L3BhZ2VtYXAsIHBtZF9zb2Z0X2RpcnR5KCkgaXMgdXNlZCBmb3IgYm90aCB0aGUgUE1EIGh1Z2UN
Cj4gcGFnZSBtYXAgYW5kIHRoZSBQTUQgbWlncmF0aW9uIGVudHJpZXMuICBUaGF0IGlzIHdyb25n
LA0KPiBwbWRfc3dwX3NvZnRfZGlydHkoKSBzaG91bGQgYmUgdXNlZCBmb3IgdGhlIFBNRCBtaWdy
YXRpb24gZW50cmllcw0KPiBpbnN0ZWFkIGJlY2F1c2UgdGhlIGRpZmZlcmVudCBwYWdlIHRhYmxl
IGVudHJ5IGZsYWcgaXMgdXNlZC4NCj4gT3RoZXJ3aXNlLCB0aGUgc29mdCBkaXJ0eSBpbmZvcm1h
dGlvbiBpbiAvcHJvYy88cGlkPi9wYWdlbWFwIG1heSBiZQ0KPiB3cm9uZy4NCj4gDQo+IENjOiBN
aWNoYWwgSG9ja28gPG1ob2Nrb0BzdXNlLmNvbT4NCj4gQ2M6ICJLaXJpbGwgQS4gU2h1dGVtb3Yi
IDxraXJpbGwuc2h1dGVtb3ZAbGludXguaW50ZWwuY29tPg0KPiBDYzogRGF2aWQgUmllbnRqZXMg
PHJpZW50amVzQGdvb2dsZS5jb20+DQo+IENjOiBBcm5kIEJlcmdtYW5uIDxhcm5kQGFybmRiLmRl
Pg0KPiBDYzogSHVnaCBEaWNraW5zIDxodWdoZEBnb29nbGUuY29tPg0KPiBDYzogIkrDqXLDtG1l
IEdsaXNzZSIgPGpnbGlzc2VAcmVkaGF0LmNvbT4NCj4gQ2M6IERhbmllbCBDb2xhc2Npb25lIDxk
YW5jb2xAZ29vZ2xlLmNvbT4NCj4gQ2M6IFppIFlhbiA8emkueWFuQGNzLnJ1dGdlcnMuZWR1Pg0K
PiBDYzogTmFveWEgSG9yaWd1Y2hpIDxuLWhvcmlndWNoaUBhaC5qcC5uZWMuY29tPg0KPiBTaWdu
ZWQtb2ZmLWJ5OiAiSHVhbmcsIFlpbmciIDx5aW5nLmh1YW5nQGludGVsLmNvbT4NCj4gRml4ZXM6
IDg0YzNmYzRlOWM1NiAoIm1tOiB0aHA6IGNoZWNrIHBtZCBtaWdyYXRpb24gZW50cnkgaW4gY29t
bW9uIHBhdGgiKQ0KPiAtLS0NCj4gIGZzL3Byb2MvdGFza19tbXUuYyB8IDYgKysrKystDQo+ICAx
IGZpbGUgY2hhbmdlZCwgNSBpbnNlcnRpb25zKCspLCAxIGRlbGV0aW9uKC0pDQo+IA0KPiBkaWZm
IC0tZ2l0IGEvZnMvcHJvYy90YXNrX21tdS5jIGIvZnMvcHJvYy90YXNrX21tdS5jDQo+IGluZGV4
IDI1OTNhMGM2MDlkNy4uMDFhYWQ3NzJmOGRiIDEwMDY0NA0KPiAtLS0gYS9mcy9wcm9jL3Rhc2tf
bW11LmMNCj4gKysrIGIvZnMvcHJvYy90YXNrX21tdS5jDQo+IEBAIC0xMzExLDEzICsxMzExLDE1
IEBAIHN0YXRpYyBpbnQgcGFnZW1hcF9wbWRfcmFuZ2UocG1kX3QgKnBtZHAsIHVuc2lnbmVkIGxv
bmcgYWRkciwgdW5zaWduZWQgbG9uZyBlbmQsDQo+ICAJCXBtZF90IHBtZCA9ICpwbWRwOw0KPiAg
CQlzdHJ1Y3QgcGFnZSAqcGFnZSA9IE5VTEw7DQo+ICANCj4gLQkJaWYgKCh2bWEtPnZtX2ZsYWdz
ICYgVk1fU09GVERJUlRZKSB8fCBwbWRfc29mdF9kaXJ0eShwbWQpKQ0KPiArCQlpZiAodm1hLT52
bV9mbGFncyAmIFZNX1NPRlRESVJUWSkNCj4gIAkJCWZsYWdzIHw9IFBNX1NPRlRfRElSVFk7DQoN
CnJpZ2h0LCBjaGVja2luZyBiaXRzIGluIHBtZCBtdXN0IGJlIGRvbmUgYWZ0ZXIgcG1kX3ByZXNl
bnQgaXMgY29uZmlybWVkLg0KDQpBY2tlZC1ieTogTmFveWEgSG9yaWd1Y2hpIDxuLWhvcmlndWNo
aUBhaC5qcC5uZWMuY29tPg0KDQpUaGFua3MsDQpOYW95YSBIb3JpZ3VjaGkNCg0KPiAgDQo+ICAJ
CWlmIChwbWRfcHJlc2VudChwbWQpKSB7DQo+ICAJCQlwYWdlID0gcG1kX3BhZ2UocG1kKTsNCj4g
IA0KPiAgCQkJZmxhZ3MgfD0gUE1fUFJFU0VOVDsNCj4gKwkJCWlmIChwbWRfc29mdF9kaXJ0eShw
bWQpKQ0KPiArCQkJCWZsYWdzIHw9IFBNX1NPRlRfRElSVFk7DQo+ICAJCQlpZiAocG0tPnNob3df
cGZuKQ0KPiAgCQkJCWZyYW1lID0gcG1kX3BmbihwbWQpICsNCj4gIAkJCQkJKChhZGRyICYgflBN
RF9NQVNLKSA+PiBQQUdFX1NISUZUKTsNCj4gQEAgLTEzMjksNiArMTMzMSw4IEBAIHN0YXRpYyBp
bnQgcGFnZW1hcF9wbWRfcmFuZ2UocG1kX3QgKnBtZHAsIHVuc2lnbmVkIGxvbmcgYWRkciwgdW5z
aWduZWQgbG9uZyBlbmQsDQo+ICAJCQlmcmFtZSA9IHN3cF90eXBlKGVudHJ5KSB8DQo+ICAJCQkJ
KHN3cF9vZmZzZXQoZW50cnkpIDw8IE1BWF9TV0FQRklMRVNfU0hJRlQpOw0KPiAgCQkJZmxhZ3Mg
fD0gUE1fU1dBUDsNCj4gKwkJCWlmIChwbWRfc3dwX3NvZnRfZGlydHkocG1kKSkNCj4gKwkJCQlm
bGFncyB8PSBQTV9TT0ZUX0RJUlRZOw0KPiAgCQkJVk1fQlVHX09OKCFpc19wbWRfbWlncmF0aW9u
X2VudHJ5KHBtZCkpOw0KPiAgCQkJcGFnZSA9IG1pZ3JhdGlvbl9lbnRyeV90b19wYWdlKGVudHJ5
KTsNCj4gIAkJfQ0KPiA=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
