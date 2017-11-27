Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C87E6B0253
	for <linux-mm@kvack.org>; Sun, 26 Nov 2017 20:28:36 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 4so27471356pge.8
        for <linux-mm@kvack.org>; Sun, 26 Nov 2017 17:28:36 -0800 (PST)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id a6si21643106pgq.757.2017.11.26.17.28.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 26 Nov 2017 17:28:34 -0800 (PST)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: =?gb2312?B?tPC4tDogW1BBVENIIDAxLzExXSBJbml0aWFsaXplIHRoZSBtYXBwaW5nIG9m?=
 =?gb2312?Q?_KASan_shadow_memory?=
Date: Mon, 27 Nov 2017 01:26:32 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C006C4ED@dggemm510-mbs.china.huawei.com>
References: <87po8ir1kg.fsf@on-the-bus.cambridge.arm.com>
 <B8AC3E80E903784988AB3003E3E97330C006371B@dggemm510-mbs.china.huawei.com>
 <87375eqobb.fsf@on-the-bus.cambridge.arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0063816@dggemm510-mbs.china.huawei.com>
 <20171117073556.GB28855@cbox>
 <B8AC3E80E903784988AB3003E3E97330C00638D4@dggemm510-mbs.china.huawei.com>
 <20171118134841.3f6c9183@why.wild-wind.fr.eu.org>
 <B8AC3E80E903784988AB3003E3E97330C0068F12@dggemm510-mbx.china.huawei.com>
 <20171121122938.sydii3i36jbzi7x4@lakrids.cambridge.arm.com>
 <B8AC3E80E903784988AB3003E3E97330C0069032@dggemm510-mbx.china.huawei.com>
 <20171123153133.mwyuxthy2ysktx7c@lakrids.cambridge.arm.com>
In-Reply-To: <20171123153133.mwyuxthy2ysktx7c@lakrids.cambridge.arm.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Marc Zyngier <marc.zyngier@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "mhocko@suse.com" <mhocko@suse.com>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "glider@google.com" <glider@google.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "mingo@kernel.org" <mingo@kernel.org>, Christoffer Dall <cdall@linaro.org>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, Dailei <dylix.dailei@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "labbott@redhat.com" <labbott@redhat.com>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, Zengweilin <zengweilin@huawei.com>, "opendmb@gmail.com" <opendmb@gmail.com>, Heshaoliang <heshaoliang@huawei.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "dvyukov@google.com" <dvyukov@google.com>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jiazhenghua <jiazhenghua@huawei.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "thgarnie@google.com" <thgarnie@google.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>

T24gTm92IDIzLCAyMDE3ICAyMzozMiAgTWFyayBSdXRsYW5kIFttYWlsdG86bWFyay5ydXRsYW5k
QGFybS5jb21dIHdyb3RlOg0KPk9uIFdlZCwgTm92IDIyLCAyMDE3IGF0IDEyOjU2OjQ0UE0gKzAw
MDAsIExpdXdlbmxpYW5nIChBYmJvdHQgTGl1KSB3cm90ZToNCj4+ICtzdGF0aWMgaW5saW5lIHU2
NCBnZXRfdHRicjAodm9pZCkNCj4+ICt7DQo+PiArIGlmIChJU19FTkFCTEVEKENPTkZJR19BUk1f
TFBBRSkpDQo+PiArICAgICAgICAgcmV0dXJuIHJlYWRfc3lzcmVnKFRUQlIwXzY0KTsNCj4+ICsg
ZWxzZQ0KPj4gKyAgICAgICAgIHJldHVybiAodTY0KXJlYWRfc3lzcmVnKFRUQlIwXzMyKTsNCj4+
ICt9DQo+DQo+PiArc3RhdGljIGlubGluZSB1NjQgZ2V0X3R0YnIxKHZvaWQpDQo+PiArew0KPj4g
KyBpZiAoSVNfRU5BQkxFRChDT05GSUdfQVJNX0xQQUUpKQ0KPj4gKyAgICAgICAgIHJldHVybiBy
ZWFkX3N5c3JlZyhUVEJSMV82NCk7DQo+PiArIGVsc2UNCj4+ICsgICAgICAgICByZXR1cm4gKHU2
NClyZWFkX3N5c3JlZyhUVEJSMV8zMik7DQo+PiArfQ0KPg0KPkluIGFkZGl0aW9uIHRvIHRoZSB3
aGl0ZXNwYWNlIGRhbWFnZSB0aGF0IG5lZWQgdG8gYmUgZml4ZWQsIHRoZXJlJ3Mgbm8NCj5uZWVk
IGZvciB0aGUgdTY0IGNhc3RzIGhlcmUuIFRoZSBjb21waWxlciB3aWxsIGltcGxpY2l0bHkgY2Fz
dCB0byB0aGUNCj5yZXR1cm4gdHlwZSwgYW5kIGFzIHUzMiBhbmQgdTY0IGFyZSBib3RoIGFyaXRo
bWV0aWMgdHlwZXMsIHdlIGRvbid0IG5lZWQNCj5hbiBleHBsaWNpdCBjYXN0IGhlcmUuDQoNClRo
YW5rcyBmb3IgeW91ciByZXZpZXcuDQpJJ20gZ29pbmcgdG8gY2hhbmdlIGl0IGluIHRoZSBuZXcg
dmVyc2lvbi4gIA0KDQoNCi0tLS0t08q8/tStvP4tLS0tLQ0Kt6K8/sjLOiBNYXJrIFJ1dGxhbmQg
W21haWx0bzptYXJrLnJ1dGxhbmRAYXJtLmNvbV0gDQq3osvNyrG85DogMjAxN8TqMTHUwjIzyNUg
MjM6MzINCsrVvP7IyzogTGl1d2VubGlhbmcgKEFiYm90dCBMaXUpDQqzrcvNOiBNYXJjIFp5bmdp
ZXI7IHRpeHlAbGluYXJvLm9yZzsgbWhvY2tvQHN1c2UuY29tOyBncnlnb3JpaS5zdHJhc2hrb0Bs
aW5hcm8ub3JnOyBjYXRhbGluLm1hcmluYXNAYXJtLmNvbTsgbGludXgtbW1Aa3ZhY2sub3JnOyBn
bGlkZXJAZ29vZ2xlLmNvbTsgYWZ6YWwubW9oZC5tYUBnbWFpbC5jb207IG1pbmdvQGtlcm5lbC5v
cmc7IENocmlzdG9mZmVyIERhbGw7IGYuZmFpbmVsbGlAZ21haWwuY29tOyBtYXdpbGNveEBtaWNy
b3NvZnQuY29tOyBsaW51eEBhcm1saW51eC5vcmcudWs7IGthc2FuLWRldkBnb29nbGVncm91cHMu
Y29tOyBEYWlsZWk7IGxpbnV4LWFybS1rZXJuZWxAbGlzdHMuaW5mcmFkZWFkLm9yZzsgYXJ5YWJp
bmluQHZpcnR1b3p6by5jb207IGxhYmJvdHRAcmVkaGF0LmNvbTsgdmxhZGltaXIubXVyemluQGFy
bS5jb207IGtlZXNjb29rQGNocm9taXVtLm9yZzsgYXJuZEBhcm5kYi5kZTsgWmVuZ3dlaWxpbjsg
b3BlbmRtYkBnbWFpbC5jb207IEhlc2hhb2xpYW5nOyB0Z2x4QGxpbnV0cm9uaXguZGU7IGR2eXVr
b3ZAZ29vZ2xlLmNvbTsgYXJkLmJpZXNoZXV2ZWxAbGluYXJvLm9yZzsgbGludXgta2VybmVsQHZn
ZXIua2VybmVsLm9yZzsgSmlhemhlbmdodWE7IGFrcG1AbGludXgtZm91bmRhdGlvbi5vcmc7IHJv
YmluLm11cnBoeUBhcm0uY29tOyB0aGdhcm5pZUBnb29nbGUuY29tOyBraXJpbGwuc2h1dGVtb3ZA
bGludXguaW50ZWwuY29tDQrW98ziOiBSZTogW1BBVENIIDAxLzExXSBJbml0aWFsaXplIHRoZSBt
YXBwaW5nIG9mIEtBU2FuIHNoYWRvdyBtZW1vcnkNCg0KT24gV2VkLCBOb3YgMjIsIDIwMTcgYXQg
MTI6NTY6NDRQTSArMDAwMCwgTGl1d2VubGlhbmcgKEFiYm90dCBMaXUpIHdyb3RlOg0KPiArc3Rh
dGljIGlubGluZSB1NjQgZ2V0X3R0YnIwKHZvaWQpDQo+ICt7DQo+ICsgaWYgKElTX0VOQUJMRUQo
Q09ORklHX0FSTV9MUEFFKSkNCj4gKyAgICAgICAgIHJldHVybiByZWFkX3N5c3JlZyhUVEJSMF82
NCk7DQo+ICsgZWxzZQ0KPiArICAgICAgICAgcmV0dXJuICh1NjQpcmVhZF9zeXNyZWcoVFRCUjBf
MzIpOw0KPiArfQ0KDQo+ICtzdGF0aWMgaW5saW5lIHU2NCBnZXRfdHRicjEodm9pZCkNCj4gK3sN
Cj4gKyBpZiAoSVNfRU5BQkxFRChDT05GSUdfQVJNX0xQQUUpKQ0KPiArICAgICAgICAgcmV0dXJu
IHJlYWRfc3lzcmVnKFRUQlIxXzY0KTsNCj4gKyBlbHNlDQo+ICsgICAgICAgICByZXR1cm4gKHU2
NClyZWFkX3N5c3JlZyhUVEJSMV8zMik7DQo+ICt9DQoNCkluIGFkZGl0aW9uIHRvIHRoZSB3aGl0
ZXNwYWNlIGRhbWFnZSB0aGF0IG5lZWQgdG8gYmUgZml4ZWQsIHRoZXJlJ3Mgbm8NCm5lZWQgZm9y
IHRoZSB1NjQgY2FzdHMgaGVyZS4gVGhlIGNvbXBpbGVyIHdpbGwgaW1wbGljaXRseSBjYXN0IHRv
IHRoZQ0KcmV0dXJuIHR5cGUsIGFuZCBhcyB1MzIgYW5kIHU2NCBhcmUgYm90aCBhcml0aG1ldGlj
IHR5cGVzLCB3ZSBkb24ndCBuZWVkDQphbiBleHBsaWNpdCBjYXN0IGhlcmUuDQoNClRoYW5rcywN
Ck1hcmsuDQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
