Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 90A1C6B0031
	for <linux-mm@kvack.org>; Sat,  7 Jun 2014 09:56:15 -0400 (EDT)
Received: by mail-ob0-f171.google.com with SMTP id wn1so4029695obc.30
        for <linux-mm@kvack.org>; Sat, 07 Jun 2014 06:56:15 -0700 (PDT)
Received: from mail-oa0-x22f.google.com (mail-oa0-x22f.google.com [2607:f8b0:4003:c02::22f])
        by mx.google.com with ESMTPS id g3si19983102obd.23.2014.06.07.06.56.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 07 Jun 2014 06:56:14 -0700 (PDT)
Received: by mail-oa0-f47.google.com with SMTP id n16so46932oag.6
        for <linux-mm@kvack.org>; Sat, 07 Jun 2014 06:56:14 -0700 (PDT)
Message-ID: <539319fd.22abb60a.05d2.70c7@mx.google.com>
Date: Sat, 07 Jun 2014 08:56:08 -0500
Subject: Re: [PATCH 1/1] mm/zswap.c: add __init to zswap_entry_cache_destroy
From: Seth Jennings <sjennings@variantweb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: base64
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fabian Frederick <fabf@skynet.be>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Ck9uIEp1biA3LCAyMDE0IDY6MDggQU0sIEZhYmlhbiBGcmVkZXJpY2sgPGZhYmZAc2t5bmV0LmJl
PiB3cm90ZToKPgo+IHpzd2FwX2VudHJ5X2NhY2hlX2Rlc3Ryb3kgaXMgb25seSBjYWxsZWQgYnkg
X19pbml0IGluaXRfenN3YXAgCj4KPiBUaGlzIHBhdGNoIGFsc28gZml4ZXMgZnVuY3Rpb24gbmFt
ZSAKPiB6c3dhcF9lbnRyeV9jYWNoZV8gcy9kZXN0b3J5L2Rlc3Ryb3kKClRoYW5rcyBmb3IgdGhl
wqAgaW1wcm92ZW1lbnQg4pi6CgpBY2tlZC1ieSA8c2plbm5pbmdzQHZhcmlhbnR3ZWIubmV0PgoK
Pgo+IENjOiBTZXRoIEplbm5pbmdzIDxzamVubmluZ3NAdmFyaWFudHdlYi5uZXQ+IAo+IENjOiBs
aW51eC1tbUBrdmFjay5vcmcgCj4gQ2M6IEFuZHJldyBNb3J0b24gPGFrcG1AbGludXgtZm91bmRh
dGlvbi5vcmc+IAo+IFNpZ25lZC1vZmYtYnk6IEZhYmlhbiBGcmVkZXJpY2sgPGZhYmZAc2t5bmV0
LmJlPiAKPiAtLS0gCj4gbW0venN3YXAuYyB8IDQgKystLSAKPiAxIGZpbGUgY2hhbmdlZCwgMiBp
bnNlcnRpb25zKCspLCAyIGRlbGV0aW9ucygtKSAKPgo+IGRpZmYgLS1naXQgYS9tbS96c3dhcC5j
IGIvbW0venN3YXAuYyAKPiBpbmRleCBhZWFlZjBmLi5hYjdmYTBmIDEwMDY0NCAKPiAtLS0gYS9t
bS96c3dhcC5jIAo+ICsrKyBiL21tL3pzd2FwLmMgCj4gQEAgLTIwNyw3ICsyMDcsNyBAQCBzdGF0
aWMgaW50IHpzd2FwX2VudHJ5X2NhY2hlX2NyZWF0ZSh2b2lkKSAKPiByZXR1cm4genN3YXBfZW50
cnlfY2FjaGUgPT0gTlVMTDsgCj4gfSAKPgo+IC1zdGF0aWMgdm9pZCB6c3dhcF9lbnRyeV9jYWNo
ZV9kZXN0b3J5KHZvaWQpIAo+ICtzdGF0aWMgdm9pZCBfX2luaXQgenN3YXBfZW50cnlfY2FjaGVf
ZGVzdHJveSh2b2lkKSAKPiB7IAo+IGttZW1fY2FjaGVfZGVzdHJveSh6c3dhcF9lbnRyeV9jYWNo
ZSk7IAo+IH0gCj4gQEAgLTkyNiw3ICs5MjYsNyBAQCBzdGF0aWMgaW50IF9faW5pdCBpbml0X3pz
d2FwKHZvaWQpIAo+IHBjcHVmYWlsOiAKPiB6c3dhcF9jb21wX2V4aXQoKTsgCj4gY29tcGZhaWw6
IAo+IC0genN3YXBfZW50cnlfY2FjaGVfZGVzdG9yeSgpOyAKPiArIHpzd2FwX2VudHJ5X2NhY2hl
X2Rlc3Ryb3koKTsgCj4gY2FjaGVmYWlsOiAKPiB6YnVkX2Rlc3Ryb3lfcG9vbCh6c3dhcF9wb29s
KTsgCj4gZXJyb3I6IAo+IC0tIAo+IDEuOS4xIAo+Cg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
