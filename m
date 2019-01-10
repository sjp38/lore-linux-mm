Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id C9B6B8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 09:35:09 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id w12so3229287wru.20
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 06:35:09 -0800 (PST)
Received: from NAM04-SN1-obe.outbound.protection.outlook.com (mail-oln040092011094.outbound.protection.outlook.com. [40.92.11.94])
        by mx.google.com with ESMTPS id f8si42690788wro.330.2019.01.10.06.35.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 10 Jan 2019 06:35:07 -0800 (PST)
From: =?utf-8?B?TGVvbmFyZG8gU29hcmVzIE3DvGxsZXI=?= <leozinho29_eu@hotmail.com>
Subject: Re: [PATCH] mm/mmu_notifier: mm/rmap.c: Fix a mmu_notifier range bug
 in try_to_unmap_one
Date: Thu, 10 Jan 2019 14:35:04 +0000
Message-ID: <FR1P152MB1479F6407724F66D1E008AEE97840@FR1P152MB1479.LAMP152.PROD.OUTLOOK.COM>
References: <20190110005117.18282-1-sean.j.christopherson@intel.com>
In-Reply-To: <20190110005117.18282-1-sean.j.christopherson@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <A0A6D18181535B4C94E809F6C041DA21@LAMP152.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sean Christopherson <sean.j.christopherson@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mike Galbraith <efault@gmx.de>, Adam Borowski <kilobyte@angband.pl>, =?utf-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, =?utf-8?B?Q2hyaXN0aWFuIEvDtm5pZw==?= <christian.koenig@amd.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <zwisler@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, =?utf-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Michal Hocko <mhocko@kernel.org>, Felix Kuehling <felix.kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

QWZ0ZXIgYXBwbHlpbmcgdGhpcyBwYXRjaCwgSSdtIG5vIGxvbmdlciBzZWVpbmcgZG1lc2cgbWVz
c2FnZXMgd2l0aA0KV0FSTklOR3MgYW5kIEJVR3MsIGFuZCBib3RoIGhvc3QgYW5kIGd1ZXN0cyBh
cmUgc3RhYmxlLg0KDQpUaGFuayB5b3UuDQoNCsOAcyAyMjo1MSBkZSAwOS8wMS8yMDE5LCBTZWFu
IENocmlzdG9waGVyc29uIGVzY3JldmV1Og0KPiBUaGUgY29udmVyc2lvbiB0byB1c2UgYSBzdHJ1
Y3R1cmUgZm9yIG1tdV9ub3RpZmllcl9pbnZhbGlkYXRlX3JhbmdlXyooKQ0KPiB1bmludGVudGlv
bmFsbHkgY2hhbmdlZCB0aGUgdXNhZ2UgaW4gdHJ5X3RvX3VubWFwX29uZSgpIHRvIGluaXQgdGhl
DQo+ICdzdHJ1Y3QgbW11X25vdGlmaWVyX3JhbmdlJyB3aXRoIHZtYS0+dm1fc3RhcnQgaW5zdGVh
ZCBvZiBAYWRkcmVzcywNCj4gaS5lLiBpdCBpbnZhbGlkYXRlcyB0aGUgd3JvbmcgYWRkcmVzcyBy
YW5nZS4gIFJldmVydCB0byB0aGUgY29ycmVjdA0KPiBhZGRyZXNzIHJhbmdlLg0KPiANCj4gTWFu
aWZlc3RzIGFzIEtWTSB1c2UtYWZ0ZXItZnJlZSBXQVJOSU5HcyBhbmQgc3Vic2VxdWVudCAiQlVH
OiBCYWQgcGFnZQ0KPiBzdGF0ZSBpbiBwcm9jZXNzIFgiIGVycm9ycyB3aGVuIHJlY2xhaW1pbmcg
ZnJvbSBhIEtWTSBndWVzdCBkdWUgdG8gS1ZNDQo+IHJlbW92aW5nIHRoZSB3cm9uZyBwYWdlcyBm
cm9tIGl0cyBvd24gbWFwcGluZ3MuDQo+IA0KPiBSZXBvcnRlZC1ieTogbGVvemluaG8yOV9ldUBo
b3RtYWlsLmNvbQ0KPiBSZXBvcnRlZC1ieTogTWlrZSBHYWxicmFpdGggPGVmYXVsdEBnbXguZGU+
DQo+IFJlcG9ydGVkLWJ5OiBBZGFtIEJvcm93c2tpIDxraWxvYnl0ZUBhbmdiYW5kLnBsPg0KPiBD
YzogSsOpcsO0bWUgR2xpc3NlIDxqZ2xpc3NlQHJlZGhhdC5jb20+DQo+IENjOiBDaHJpc3RpYW4g
S8O2bmlnIDxjaHJpc3RpYW4ua29lbmlnQGFtZC5jb20+DQo+IENjOiBKYW4gS2FyYSA8amFja0Bz
dXNlLmN6Pg0KPiBDYzogTWF0dGhldyBXaWxjb3ggPG1hd2lsY294QG1pY3Jvc29mdC5jb20+DQo+
IENjOiBSb3NzIFp3aXNsZXIgPHp3aXNsZXJAa2VybmVsLm9yZz4NCj4gQ2M6IERhbiBXaWxsaWFt
cyA8ZGFuLmoud2lsbGlhbXNAaW50ZWwuY29tPg0KPiBDYzogUGFvbG8gQm9uemluaSA8cGJvbnpp
bmlAcmVkaGF0LmNvbT4NCj4gQ2M6IFJhZGltIEtyxI1tw6HFmSA8cmtyY21hckByZWRoYXQuY29t
Pg0KPiBDYzogTWljaGFsIEhvY2tvIDxtaG9ja29Aa2VybmVsLm9yZz4NCj4gQ2M6IEZlbGl4IEt1
ZWhsaW5nIDxmZWxpeC5rdWVobGluZ0BhbWQuY29tPg0KPiBDYzogUmFscGggQ2FtcGJlbGwgPHJj
YW1wYmVsbEBudmlkaWEuY29tPg0KPiBDYzogSm9obiBIdWJiYXJkIDxqaHViYmFyZEBudmlkaWEu
Y29tPg0KPiBDYzogQW5kcmV3IE1vcnRvbiA8YWtwbUBsaW51eC1mb3VuZGF0aW9uLm9yZz4NCj4g
Q2M6IExpbnVzIFRvcnZhbGRzIDx0b3J2YWxkc0BsaW51eC1mb3VuZGF0aW9uLm9yZz4NCj4gRml4
ZXM6IGFjNDZkNGYzYzQzMiAoIm1tL21tdV9ub3RpZmllcjogdXNlIHN0cnVjdHVyZSBmb3IgaW52
YWxpZGF0ZV9yYW5nZV9zdGFydC9lbmQgY2FsbHMgdjIiKQ0KPiBTaWduZWQtb2ZmLWJ5OiBTZWFu
IENocmlzdG9waGVyc29uIDxzZWFuLmouY2hyaXN0b3BoZXJzb25AaW50ZWwuY29tPg0KPiAtLS0N
Cj4gDQo+IEZXSVcsIEkgbG9va2VkIHRocm91Z2ggYWxsIG90aGVyIGNhbGxzIHRvIG1tdV9ub3Rp
Zmllcl9yYW5nZV9pbml0KCkgaW4NCj4gdGhlIHBhdGNoIGFuZCBkaWRuJ3Qgc3BvdCBhbnkgb3Ro
ZXIgdW5pbnRlbnRpb25hbCBmdW5jdGlvbmFsIGNoYW5nZXMuDQo+IA0KPiAgbW0vcm1hcC5jIHwg
NCArKy0tDQo+ICAxIGZpbGUgY2hhbmdlZCwgMiBpbnNlcnRpb25zKCspLCAyIGRlbGV0aW9ucygt
KQ0KPiANCj4gZGlmZiAtLWdpdCBhL21tL3JtYXAuYyBiL21tL3JtYXAuYw0KPiBpbmRleCA2OGEx
YTViODY5YTUuLjA0NTRlY2MyOTUzNyAxMDA2NDQNCj4gLS0tIGEvbW0vcm1hcC5jDQo+ICsrKyBi
L21tL3JtYXAuYw0KPiBAQCAtMTM3MSw4ICsxMzcxLDggQEAgc3RhdGljIGJvb2wgdHJ5X3RvX3Vu
bWFwX29uZShzdHJ1Y3QgcGFnZSAqcGFnZSwgc3RydWN0IHZtX2FyZWFfc3RydWN0ICp2bWEsDQo+
ICAJICogTm90ZSB0aGF0IHRoZSBwYWdlIGNhbiBub3QgYmUgZnJlZSBpbiB0aGlzIGZ1bmN0aW9u
IGFzIGNhbGwgb2YNCj4gIAkgKiB0cnlfdG9fdW5tYXAoKSBtdXN0IGhvbGQgYSByZWZlcmVuY2Ug
b24gdGhlIHBhZ2UuDQo+ICAJICovDQo+IC0JbW11X25vdGlmaWVyX3JhbmdlX2luaXQoJnJhbmdl
LCB2bWEtPnZtX21tLCB2bWEtPnZtX3N0YXJ0LA0KPiAtCQkJCW1pbih2bWEtPnZtX2VuZCwgdm1h
LT52bV9zdGFydCArDQo+ICsJbW11X25vdGlmaWVyX3JhbmdlX2luaXQoJnJhbmdlLCB2bWEtPnZt
X21tLCBhZGRyZXNzLA0KPiArCQkJCW1pbih2bWEtPnZtX2VuZCwgYWRkcmVzcyArDQo+ICAJCQkJ
ICAgIChQQUdFX1NJWkUgPDwgY29tcG91bmRfb3JkZXIocGFnZSkpKSk7DQo+ICAJaWYgKFBhZ2VI
dWdlKHBhZ2UpKSB7DQo+ICAJCS8qDQo+IA0K
