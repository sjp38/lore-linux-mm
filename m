Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 52E736B0007
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 08:09:37 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y68so5607148pfy.20
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 05:09:37 -0800 (PST)
Received: from huawei.com (szxga03-in.huawei.com. [45.249.212.189])
        by mx.google.com with ESMTPS id d5-v6si6743861plm.759.2018.02.26.05.09.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 05:09:36 -0800 (PST)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: =?gb2312?B?tPC4tDogW1BBVENIIDAxLzExXSBJbml0aWFsaXplIHRoZSBtYXBwaW5nIG9m?=
 =?gb2312?Q?_KASan_shadow_memory?=
Date: Mon, 26 Feb 2018 13:09:26 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C0072FE7@dggemm510-mbs.china.huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-2-liuwenliang@huawei.com>
 <31b16c9d-48c7-bc0a-51d1-cc6cf892329b@gmail.com>
 <20171019120137.GT20805@n2100.armlinux.org.uk>
In-Reply-To: <20171019120137.GT20805@n2100.armlinux.org.uk>
Content-Language: zh-CN
Content-Type: text/plain; charset="gb2312"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>, Dmitry Osipenko <digetx@gmail.com>
Cc: "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

T24gT2N0IDE5LCAyMDE3IGF0IDE5OjA5LCBSdXNzZWxsIEtpbmcgLSBBUk0gTGludXggW21haWx0
bzpsaW51eEBhcm1saW51eC5vcmcudWtdIHdyb3RlOg0KPk9uIFRodSwgT2N0IDEyLCAyMDE3IGF0
IDAyOjQyOjQ5QU0gKzAzMDAsIERtaXRyeSBPc2lwZW5rbyB3cm90ZToNCj4+IE9uIDExLjEwLjIw
MTcgMTE6MjIsIEFiYm90dCBMaXUgd3JvdGU6DQo+PiA+ICt2b2lkIF9faW5pdCBrYXNhbl9tYXBf
ZWFybHlfc2hhZG93KHBnZF90ICpwZ2RwKQ0KPj4gPiArew0KPj4gPiArCWludCBpOw0KPj4gPiAr
CXVuc2lnbmVkIGxvbmcgc3RhcnQgPSBLQVNBTl9TSEFET1dfU1RBUlQ7DQo+PiA+ICsJdW5zaWdu
ZWQgbG9uZyBlbmQgPSBLQVNBTl9TSEFET1dfRU5EOw0KPj4gPiArCXVuc2lnbmVkIGxvbmcgYWRk
cjsNCj4+ID4gKwl1bnNpZ25lZCBsb25nIG5leHQ7DQo+PiA+ICsJcGdkX3QgKnBnZDsNCj4+ID4g
Kw0KPj4gPiArCWZvciAoaSA9IDA7IGkgPCBQVFJTX1BFUl9QVEU7IGkrKykNCj4+ID4gKwkJc2V0
X3B0ZV9hdCgmaW5pdF9tbSwgS0FTQU5fU0hBRE9XX1NUQVJUICsgaSpQQUdFX1NJWkUsDQo+PiA+
ICsJCQkma2FzYW5femVyb19wdGVbaV0sIHBmbl9wdGUoDQo+PiA+ICsJCQkJdmlydF90b19wZm4o
a2FzYW5femVyb19wYWdlKSwNCj4+ID4gKwkJCQlfX3BncHJvdChfTF9QVEVfREVGQVVMVCB8IExf
UFRFX0RJUlRZIHwgTF9QVEVfWE4pKSk7DQo+PiANCj4+IFNob3VsZG4ndCBhbGwgX19wZ3Byb3Qn
cyBjb250YWluIExfUFRFX01UX1dSSVRFVEhST1VHSCA/DQo+DQo+T25lIG9mIHRoZSBhcmNoaXRl
Y3R1cmUgcmVzdHJpY3Rpb25zIGlzIHRoYXQgdGhlIGNhY2hlIGF0dHJpYnV0ZXMgb2YNCj5hbGwg
YWxpYXNlcyBzaG91bGQgbWF0Y2ggKGJ1dCB0aGVyZSBpcyBhIHNwZWNpZmljIHdvcmthcm91bmQg
dGhhdA0KPnBlcm1pdHMgdGhpcywgcHJvdmlkZWQgdGhhdCB0aGUgZGlzLXNpbWlsYXIgbWFwcGlu
Z3MgYXJlbid0IGFjY2Vzc2VkDQo+d2l0aG91dCBjZXJ0YWluIGludGVydmVuaW5nIGluc3RydWN0
aW9ucy4pDQo+DQo+V2h5IHNob3VsZCBpdCBiZSBMX1BURV9NVF9XUklURVRIUk9VR0gsIGFuZCBu
b3QgdGhlIHNhbWUgY2FjaGUNCj5hdHRyaWJ1dGVzIGFzIHRoZSBsb3dtZW0gbWFwcGluZz8NCj4N
Cg0KSGVyZSBpcyBtYXBwaW5nIHRoZSBrYXNhbiBzaGFkb3cgd2hpY2ggaXMgdXNlZCBhdCB0aGUg
ZWFybHkgc3RhZ2Ugb2Yga2VybmVsIHN0YXJ0KGZyb20gc3RhcnQNCm9mIHN0YXJ0X2tlcm5lbCB0
byBwYWdpbmdfaW5pdCkuIEF0IHRoaXMgc3RhZ2Ugd2Ugb25seSByZWFkIHRoZSBrYXNhbiBzaGFk
b3dzLCBuZXZlciB3cml0ZSB0aGUNCmthc2FuIHNoYWRvd3Mgd2hpY2ggaXMgaW5pdGlhbGl6ZWQg
dG8gYmUgemVyby4gDQoNCldlIHdpbGwgbWFwIHRoZSBrYXNhbiBzaGFkb3dzIGFnYWluIHdpdGgg
ZmxhZ3MgUEFHRV9LRVJORUw6DQpwdGVfdCAqIF9fbWVtaW5pdCBrYXNhbl9wdGVfcG9wdWxhdGUo
cG1kX3QgKnBtZCwgdW5zaWduZWQgbG9uZyBhZGRyLCBpbnQgbm9kZSkNCnsNCglwdGVfdCAqcHRl
ID0gcHRlX29mZnNldF9rZXJuZWwocG1kLCBhZGRyKTsNCglpZiAocHRlX25vbmUoKnB0ZSkpIHsN
CgkJcHRlX3QgZW50cnk7DQoJCXZvaWQgKnAgPSBrYXNhbl9hbGxvY19ibG9jayhQQUdFX1NJWkUs
IG5vZGUpOw0KIAkJaWYgKCFwKQ0KCQkJcmV0dXJuIE5VTEw7DQoJCWVudHJ5ID0gcGZuX3B0ZSh2
aXJ0X3RvX3BmbihwKSwgX19wZ3Byb3QocGdwcm90X3ZhbChQQUdFX0tFUk5FTCkpKTsNCgkJCXNl
dF9wdGVfYXQoJmluaXRfbW0sIGFkZHIsIHB0ZSwgZW50cnkpOw0KCX0NCglyZXR1cm4gcHRlOw0K
fQ0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
