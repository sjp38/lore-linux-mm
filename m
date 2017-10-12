Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D79576B0033
	for <linux-mm@kvack.org>; Thu, 12 Oct 2017 07:30:00 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v2so11736869pfa.4
        for <linux-mm@kvack.org>; Thu, 12 Oct 2017 04:30:00 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id k13si2326187pgo.453.2017.10.12.04.29.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Oct 2017 04:29:59 -0700 (PDT)
From: "Liuwenliang (Lamb)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 06/11] change memory_is_poisoned_16 for aligned error
Date: Thu, 12 Oct 2017 11:27:40 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330B2528234@dggemm510-mbs.china.huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-7-liuwenliang@huawei.com>
 <20171011162345.f601c29d12c81af85bf38565@linux-foundation.org>
 <CACT4Y+Ym3kq5RZ-4F=f97bvT2pNpzDf0kerf6tebzLOY_crR8Q@mail.gmail.com>
In-Reply-To: <CACT4Y+Ym3kq5RZ-4F=f97bvT2pNpzDf0kerf6tebzLOY_crR8Q@mail.gmail.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, Laura Abbott <labbott@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Matthew
 Wilcox <mawilcox@microsoft.com>, Thomas Gleixner <tglx@linutronix.de>, Thomas Garnier <thgarnie@google.com>, Kees Cook <keescook@chromium.org>, Arnd Bergmann <arnd@arndb.de>, Vladimir Murzin <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, Ingo Molnar <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, Alexander Potapenko <glider@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>, "Liuwenliang (Lamb)" <liuwenliang@huawei.com>

Pj4gLSBJIGRvbid0IHVuZGVyc3RhbmQgd2h5IHRoaXMgaXMgbmVjZXNzYXJ5LiAgbWVtb3J5X2lz
X3BvaXNvbmVkXzE2KCkNCj4+ICAgYWxyZWFkeSBoYW5kbGVzIHVuYWxpZ25lZCBhZGRyZXNzZXM/
DQo+Pg0KPj4gLSBJZiBpdCdzIG5lZWRlZCBvbiBBUk0gdGhlbiBwcmVzdW1hYmx5IGl0IHdpbGwg
YmUgbmVlZGVkIG9uIG90aGVyDQo+PiAgIGFyY2hpdGVjdHVyZXMsIHNvIENPTkZJR19BUk0gaXMg
aW5zdWZmaWNpZW50bHkgZ2VuZXJhbC4NCj4+DQo+PiAtIElmIHRoZSBwcmVzZW50IG1lbW9yeV9p
c19wb2lzb25lZF8xNigpIGluZGVlZCBkb2Vzbid0IHdvcmsgb24gQVJNLA0KPj4gICBpdCB3b3Vs
ZCBiZSBiZXR0ZXIgdG8gZ2VuZXJhbGl6ZS9maXggaXQgaW4gc29tZSBmYXNoaW9uIHJhdGhlciB0
aGFuDQo+PiAgIGNyZWF0aW5nIGEgbmV3IHZhcmlhbnQgb2YgdGhlIGZ1bmN0aW9uLg0KDQoNCj5Z
ZXMsIEkgdGhpbmsgaXQgd2lsbCBiZSBiZXR0ZXIgdG8gZml4IHRoZSBjdXJyZW50IGZ1bmN0aW9u
IHJhdGhlciB0aGVuDQo+aGF2ZSAyIHNsaWdodGx5IGRpZmZlcmVudCBjb3BpZXMgd2l0aCBpZmRl
ZidzLg0KPldpbGwgc29tZXRoaW5nIGFsb25nIHRoZXNlIGxpbmVzIHdvcmsgZm9yIGFybT8gMTYt
Ynl0ZSBhY2Nlc3NlcyBhcmUNCj5ub3QgdG9vIGNvbW1vbiwgc28gaXQgc2hvdWxkIG5vdCBiZSBh
IHBlcmZvcm1hbmNlIHByb2JsZW0uIEFuZA0KPnByb2JhYmx5IG1vZGVybiBjb21waWxlcnMgY2Fu
IHR1cm4gMiAxLWJ5dGUgY2hlY2tzIGludG8gYSAyLWJ5dGUgY2hlY2sNCj53aGVyZSBzYWZlICh4
ODYpLg0KDQo+c3RhdGljIF9fYWx3YXlzX2lubGluZSBib29sIG1lbW9yeV9pc19wb2lzb25lZF8x
Nih1bnNpZ25lZCBsb25nIGFkZHIpDQo+ew0KPiAgICAgICAgdTggKnNoYWRvd19hZGRyID0gKHU4
ICopa2FzYW5fbWVtX3RvX3NoYWRvdygodm9pZCAqKWFkZHIpOw0KPg0KPiAgICAgICAgaWYgKHNo
YWRvd19hZGRyWzBdIHx8IHNoYWRvd19hZGRyWzFdKQ0KPiAgICAgICAgICAgICAgICByZXR1cm4g
dHJ1ZTsNCj4gICAgICAgIC8qIFVuYWxpZ25lZCAxNi1ieXRlcyBhY2Nlc3MgbWFwcyBpbnRvIDMg
c2hhZG93IGJ5dGVzLiAqLw0KPiAgICAgICAgaWYgKHVubGlrZWx5KCFJU19BTElHTkVEKGFkZHIs
IEtBU0FOX1NIQURPV19TQ0FMRV9TSVpFKSkpDQo+ICAgICAgICAgICAgICAgIHJldHVybiBtZW1v
cnlfaXNfcG9pc29uZWRfMShhZGRyICsgMTUpOw0KPiAgICAgICAgcmV0dXJuIGZhbHNlOw0KPn0N
Cg0KVGhhbmtzIGZvciBBbmRyZXcgTW9ydG9uIGFuZCBEbWl0cnkgVnl1a292J3MgcmV2aWV3LiAN
CklmIHRoZSBwYXJhbWV0ZXIgYWRkcj0weGMwMDAwMDA4LCBub3cgaW4gZnVuY3Rpb246DQpzdGF0
aWMgX19hbHdheXNfaW5saW5lIGJvb2wgbWVtb3J5X2lzX3BvaXNvbmVkXzE2KHVuc2lnbmVkIGxv
bmcgYWRkcikNCnsNCiAtLS0gICAgIC8vc2hhZG93X2FkZHIgPSAodTE2ICopKEtBU0FOX09GRlNF
VCsweDE4MDAwMDAxKD0weGMwMDAwMDA4Pj4zKSkgaXMgbm90IA0KIC0tLSAgICAgLy8gdW5zaWdu
ZWQgYnkgMiBieXRlcy4NCiAgICAgICAgdTE2ICpzaGFkb3dfYWRkciA9ICh1MTYgKilrYXNhbl9t
ZW1fdG9fc2hhZG93KCh2b2lkICopYWRkcik7IA0KDQogICAgICAgIC8qIFVuYWxpZ25lZCAxNi1i
eXRlcyBhY2Nlc3MgbWFwcyBpbnRvIDMgc2hhZG93IGJ5dGVzLiAqLw0KICAgICAgICBpZiAodW5s
aWtlbHkoIUlTX0FMSUdORUQoYWRkciwgS0FTQU5fU0hBRE9XX1NDQUxFX1NJWkUpKSkNCiAgICAg
ICAgICAgICAgICByZXR1cm4gKnNoYWRvd19hZGRyIHx8IG1lbW9yeV9pc19wb2lzb25lZF8xKGFk
ZHIgKyAxNSk7DQotLS0tICAgICAgLy9oZXJlIGlzIGdvaW5nIHRvIGJlIGVycm9yIG9uIGFybSwg
c3BlY2lhbGx5IHdoZW4ga2VybmVsIGhhcyBub3QgZmluaXNoZWQgeWV0Lg0KLS0tLSAgICAgIC8v
QmVjYXVzZSB0aGUgdW5zaWduZWQgYWNjZXNzaW5nIGNhdXNlIERhdGFBYm9ydCBFeGNlcHRpb24g
d2hpY2ggaXMgbm90DQotLS0tICAgICAgLy9pbml0aWFsaXplZCB3aGVuIGtlcm5lbCBpcyBzdGFy
dGluZy4gDQogICAgICAgIHJldHVybiAqc2hhZG93X2FkZHI7DQp9DQoNCkkgYWxzbyB0aGluayBp
dCBpcyBiZXR0ZXIgdG8gZml4IHRoaXMgcHJvYmxlbS4gDQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
