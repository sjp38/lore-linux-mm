Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id C44F86B0038
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 21:15:44 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id 14so160750oii.2
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 18:15:44 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id 73si2340556oik.359.2017.10.16.18.15.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Oct 2017 18:15:43 -0700 (PDT)
From: "Liuwenliang (Lamb)" <liuwenliang@huawei.com>
Subject: =?utf-8?B?562U5aSNOiBbUEFUQ0ggMDAvMTFdIEtBU2FuIGZvciBhcm0=?=
Date: Tue, 17 Oct 2017 01:04:01 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C005CA4D@dggemm510-mbx.china.huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <CAK8P3a3OOMxsr0QM+Uukec4Uq4UxHnUYF6jozxbzwJisd7vOaA@mail.gmail.com>
In-Reply-To: <CAK8P3a3OOMxsr0QM+Uukec4Uq4UxHnUYF6jozxbzwJisd7vOaA@mail.gmail.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Russell King - ARM Linux <linux@armlinux.org.uk>, Andrey Ryabinin <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, Florian Fainelli <f.fainelli@gmail.com>, Laura
 Abbott <labbott@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Christoffer Dall <cdall@linaro.org>, Marc Zyngier <marc.zyngier@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, Thomas Gleixner <tglx@linutronix.de>, Thomas
 Garnier <thgarnie@google.com>, Kees Cook <keescook@chromium.org>, Vladimir
 Murzin <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, Ard
 Biesheuvel <ard.biesheuvel@linaro.org>, Robin Murphy <robin.murphy@arm.com>, Ingo Molnar <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Doug Berger <opendmb@gmail.com>, Linux
 ARM <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

T24gMTAvMTYvMjAxNyAwNzo1NyBQTSwgQWJib3R0IExpdSB3cm90ZToNCj5OaWNlIQ0KPg0KPldo
ZW4gSSBidWlsZC10ZXN0ZWQgS0FTQU4gb24geDg2IGFuZCBhcm02NCwgSSByYW4gaW50byBhIGxv
dCBvZiBidWlsZC10aW1lDQo+cmVncmVzc2lvbnMgKG1vc3RseSB3YXJuaW5ncyBidXQgYWxzbyBz
b21lIGVycm9ycyksIHNvIEknZCBsaWtlIHRvIGdpdmUgaXQNCj5hIHNwaW4gaW4gbXkgcmFuZGNv
bmZpZyB0cmVlIGJlZm9yZSB0aGlzIGdldHMgbWVyZ2VkLiBDYW4geW91IHBvaW50IG1lDQo+dG8g
YSBnaXQgVVJMIHRoYXQgSSBjYW4gcHVsbCBpbnRvIG15IHRlc3RpbmcgdHJlZT8NCj4NCj5JIGNv
dWxkIG9mIGNvdXJzZSBhcHBseSB0aGUgcGF0Y2hlcyBmcm9tIGVtYWlsLCBidXQgSSBleHBlY3Qg
dGhhdCB0aGVyZQ0KPndpbGwgYmUgdXBkYXRlZCB2ZXJzaW9ucyBvZiB0aGUgc2VyaWVzLCBzbyBp
dCdzIGVhc2llciBpZiBJIGNhbiBqdXN0IHB1bGwNCj50aGUgbGF0ZXN0IHZlcnNpb24uDQo+DQo+
ICAgICAgQXJuZA0KDQpJJ20gc29ycnkuIEkgZG9uJ3QgaGF2ZSBnaXQgc2VydmVyLiBUaGVzZSBw
YXRjaGVzIGJhc2Ugb246DQoxLiBnaXQgcmVtb3RlIC12DQpvcmlnaW4gIGdpdDovL2dpdC5rZXJu
ZWwub3JnL3B1Yi9zY20vbGludXgva2VybmVsL2dpdC90b3J2YWxkcy9saW51eC5naXQgKGZldGNo
KQ0Kb3JpZ2luICBnaXQ6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQv
dG9ydmFsZHMvbGludXguZ2l0IChwdXNoKQ0KDQoyLiB0aGUgY29tbWl0IGlzOg0KY29tbWl0IDQ2
YzFlNzlmZWU0MTdmMTUxNTQ3YWE0NmZhZTA0YWIwNmNiNjY2ZjQNCk1lcmdlOiBlYzg0NmVjIGIx
MzBhNjkNCkF1dGhvcjogTGludXMgVG9ydmFsZHMgPHRvcnZhbGRzQGxpbnV4LWZvdW5kYXRpb24u
b3JnPg0KRGF0ZTogICBXZWQgU2VwIDEzIDEyOjI0OjIwIDIwMTcgLTA3MDANCg0KICAgIE1lcmdl
IGJyYW5jaCAncGVyZi11cmdlbnQtZm9yLWxpbnVzJyBvZiBnaXQ6Ly9naXQua2VybmVsLm9yZy9w
dWIvc2NtL2xpbnV4L2tlcm5lbC9naXQvdGlwL3RpcA0KDQogICAgUHVsbCBwZXJmIGZpeGVzIGZy
b20gSW5nbyBNb2xuYXI6DQogICAgICJBIGhhbmRmdWwgb2YgdG9vbGluZyBmaXhlcyINCg0KICAg
ICogJ3BlcmYtdXJnZW50LWZvci1saW51cycgb2YgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3Nj
bS9saW51eC9rZXJuZWwvZ2l0L3RpcC90aXA6DQogICAgICBwZXJmIHN0YXQ6IFdhaXQgZm9yIHRo
ZSBjb3JyZWN0IGNoaWxkDQogICAgICBwZXJmIHRvb2xzOiBTdXBwb3J0IHJ1bm5pbmcgcGVyZiBi
aW5hcmllcyB3aXRoIGEgZGFzaCBpbiB0aGVpciBuYW1lDQogICAgICBwZXJmIGNvbmZpZzogQ2hl
Y2sgbm90IG9ubHkgc2VjdGlvbi0+ZnJvbV9zeXN0ZW1fY29uZmlnIGJ1dCBhbHNvIGl0ZW0ncw0K
ICAgICAgcGVyZiB1aSBwcm9ncmVzczogRml4IHByb2dyZXNzIHVwZGF0ZQ0KICAgICAgcGVyZiB1
aSBwcm9ncmVzczogTWFrZSBzdXJlIHdlIGFsd2F5cyBkZWZpbmUgc3RlcCB2YWx1ZQ0KICAgICAg
cGVyZiB0b29sczogT3BlbiBwZXJmLmRhdGEgd2l0aCBPX0NMT0VYRUMgZmxhZw0KICAgICAgdG9v
bHMgbGliIGFwaTogRml4IG1ha2UgREVCVUc9MSBidWlsZA0KICAgICAgcGVyZiB0ZXN0czogRml4
IGNvbXBpbGUgd2hlbiBsaWJ1bndpbmQncyB1bndpbmQuaCBpcyBhdmFpbGFibGUNCiAgICAgIHRv
b2xzIGluY2x1ZGUgbGludXg6IEd1YXJkIGFnYWluc3QgcmVkZWZpbml0aW9uIG9mIHNvbWUgbWFj
cm9zDQpJJ20gc29ycnkgdGhhdCBJIGRpZG4ndCBiYXNlIG9uIGEgc3RhYmUgdmVyc2lvbi4NCg0K
My4gY29uZmlnOiBhcmNoL2FybS9jb25maWdzL3ZleHByZXNzX2RlZmNvbmZpZw0KDQo0LiBnY2Mg
dmVyc2lvbjogZ2NjIHZlcnNpb24gNi4xLjANCg0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
