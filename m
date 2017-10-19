Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCF636B0260
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 03:04:27 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id u23so6017375pgo.4
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 00:04:27 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [45.249.212.188])
        by mx.google.com with ESMTPS id i2si590526pgp.4.2017.10.19.00.04.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 00:04:26 -0700 (PDT)
From: "Liuwenliang (Lamb)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
Date: Thu, 19 Oct 2017 06:52:54 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C005CCBC@dggemm510-mbx.china.huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
 <20171011082227.20546-2-liuwenliang@huawei.com>
 <31b16c9d-48c7-bc0a-51d1-cc6cf892329b@gmail.com>
In-Reply-To: <31b16c9d-48c7-bc0a-51d1-cc6cf892329b@gmail.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Osipenko <digetx@gmail.com>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "marc.zyngier@arm.com" <marc.zyngier@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>
Cc: "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

T24gMjAxNy4xMC4xMiA3OjQzQU0gIERtaXRyeSBPc2lwZW5rbyBbbWFpbHRvOmRpZ2V0eEBnbWFp
bC5jb21dIHdyb3RlOg0KPlNob3VsZG4ndCBhbGwgX19wZ3Byb3QncyBjb250YWluIExfUFRFX01U
X1dSSVRFVEhST1VHSCA/DQo+DQo+Wy4uLl0NCj4NCj4tLQ0KPkRtaXRyeQ0KDQpUaGFua3MgZm9y
IHlvdXIgcmV2aWV3LiBJJ20gc29ycnkgdGhhdCBteSByZXBsYXkgaXMgc28gbGF0ZS4NCg0KSSBk
b24ndCB0aGluayBMX1BURV9NVF9XUklURVRIUk9VR0ggaXMgbmVlZCBmb3IgYWxsIGFybSBzb2Mu
IFNvIEkgdGhpbmsga2FzYW4ncw0KbWFwcGluZyBjYW4gdXNlIFBBR0VfS0VSTkVMIHdoaWNoIGNh
biBiZSBpbml0aWFsaXplZCBmb3IgZGlmZmVyZW50IGFybSBzb2MgYW5kIA0KX19wZ3Byb3QocGdw
cm90X3ZhbChQQUdFX0tFUk5FTCkgfCBMX1BURV9SRE9OTFkpKS4NCg0KSSBkb24ndCB0aGluayB0
aGUgbWFwcGluZyB0YWJsZSBmbGFncyBpbiBrYXNhbl9lYXJseV9pbml0IG5lZWQgYmUgY2hhbmdl
ZCBiZWNhdXNlIG9mIHRoZSBmb2xsb3cgcmVhc29uOg0KMSkgUEFHRV9LRVJORUwgY2FuJ3QgYmUg
dXNlZCBpbiBlYXJseV9rYXNhbl9pbml0IGJlY2F1c2UgdGhlIHBncHJvdF9rZXJuZWwgd2hpY2gg
aXMgdXNlZCB0byBkZWZpbmUgDQogIFBBR0VfS0VSTkVMIGRvZXNuJ3QgYmUgaW5pdGlhbGl6ZWQu
IA0KDQoyKSBhbGwgb2YgdGhlIGthc2FuIHNoYWRvdydzIG1hcHBpbmcgdGFibGUgaXMgZ29pbmcg
dG8gYmUgY3JlYXRlZCBhZ2FpbiBpbiBrYXNhbl9pbml0IGZ1bmN0aW9uLg0KDQoNCkFsbCB3aGF0
IEkgc2F5IGlzOiBJIHRoaW5rIG9ubHkgdGhlIG1hcHBpbmcgdGFibGUgZmxhZ3MgaW4ga2FzYW5f
aW5pdCBmdW5jdGlvbiBuZWVkIHRvIGJlIGNoYW5nZWQgaW50byBQQUdFX0tFUk5FTCANCm9yICBf
X3BncHJvdChwZ3Byb3RfdmFsKFBBR0VfS0VSTkVMKSB8IExfUFRFX1JET05MWSkpLiANCg0KSGVy
ZSBpcyB0aGUgY29kZSwgSSBoYXMgYWxyZWFkeSB0ZXN0ZWQ6DQotLS0gYS9hcmNoL2FybS9tbS9r
YXNhbl9pbml0LmMNCisrKyBiL2FyY2gvYXJtL21tL2thc2FuX2luaXQuYw0KQEAgLTEyNCw3ICsx
MjQsNyBAQCBwdGVfdCAqIF9fbWVtaW5pdCBrYXNhbl9wdGVfcG9wdWxhdGUocG1kX3QgKnBtZCwg
dW5zaWduZWQgbG9uZyBhZGRyLCBpbnQgbm9kZSkNCiAgICAgICAgICAgICAgICB2b2lkICpwID0g
a2FzYW5fYWxsb2NfYmxvY2soUEFHRV9TSVpFLCBub2RlKTsNCiAgICAgICAgICAgICAgICBpZiAo
IXApDQogICAgICAgICAgICAgICAgICAgICAgICByZXR1cm4gTlVMTDsNCi0gICAgICAgICAgIGVu
dHJ5ID0gcGZuX3B0ZSh2aXJ0X3RvX3BmbihwKSwgX19wZ3Byb3QoX0xfUFRFX0RFRkFVTFQgfCBM
X1BURV9ESVJUWSB8IExfUFRFX1hOKSk7DQorICAgICAgICAgZW50cnkgPSBwZm5fcHRlKHZpcnRf
dG9fcGZuKHApLCBfX3BncHJvdChwZ3Byb3RfdmFsKFBBR0VfS0VSTkVMKSkpOw0KICAgICAgICAg
ICAgICAgIHNldF9wdGVfYXQoJmluaXRfbW0sIGFkZHIsIHB0ZSwgZW50cnkpOw0KICAgICAgICB9
DQogICAgICAgIHJldHVybiBwdGU7DQpAQCAtMjUzLDcgKzI1NCw3IEBAIHZvaWQgX19pbml0IGth
c2FuX2luaXQodm9pZCkNCiAgICAgICAgICAgICAgICAgc2V0X3B0ZV9hdCgmaW5pdF9tbSwgS0FT
QU5fU0hBRE9XX1NUQVJUICsgaSpQQUdFX1NJWkUsDQogICAgICAgICAgICAgICAgICAgICAgICAg
Jmthc2FuX3plcm9fcHRlW2ldLCBwZm5fcHRlKA0KICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgdmlydF90b19wZm4oa2FzYW5femVyb19wYWdlKSwNCi0gICAgICAgICAgICAgICAgICAg
ICAgICAgICAgICAgIF9fcGdwcm90KF9MX1BURV9ERUZBVUxUIHwgTF9QVEVfRElSVFkgfCBMX1BU
RV9YTiB8IExfUFRFX1JET05MWSkpKTsNCisgICAgICAgICAgICAgICAgICAgICAgICAgX19wZ3By
b3QocGdwcm90X3ZhbChQQUdFX0tFUk5FTCkgfCBMX1BURV9SRE9OTFkpKSk7DQogICAgICAgIG1l
bXNldChrYXNhbl96ZXJvX3BhZ2UsIDAsIFBBR0VfU0laRSk7DQogICAgICAgIGNwdV9zZXRfdHRi
cjAob3JpZ190dGJyMCk7DQogICAgICAgIGZsdXNoX2NhY2hlX2FsbCgpOw0KDQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
