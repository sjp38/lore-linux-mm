Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5EA786B0038
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 02:19:17 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i123so1807939pgd.2
        for <linux-mm@kvack.org>; Thu, 16 Nov 2017 23:19:17 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id p3si2286688pld.115.2017.11.16.23.19.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Nov 2017 23:19:16 -0800 (PST)
From: "Liuwenliang (Abbott Liu)" <liuwenliang@huawei.com>
Subject: Re: [PATCH 01/11] Initialize the mapping of KASan shadow memory
Date: Fri, 17 Nov 2017 07:18:45 +0000
Message-ID: <B8AC3E80E903784988AB3003E3E97330C0063816@dggemm510-mbs.china.huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
	<20171011082227.20546-2-liuwenliang@huawei.com>
	<227e2c6e-f479-849d-8942-1d5ff4ccd440@arm.com>
	<B8AC3E80E903784988AB3003E3E97330C0063172@dggemm510-mbs.china.huawei.com>
	<8e959f69-a578-793b-6c32-18b5b0cd08c2@arm.com>
	<B8AC3E80E903784988AB3003E3E97330C0063545@dggemm510-mbs.china.huawei.com>
	<87a7znsubp.fsf@on-the-bus.cambridge.arm.com>
	<B8AC3E80E903784988AB3003E3E97330C0063587@dggemm510-mbs.china.huawei.com>
	<bbf43f92-3d0c-940d-b66b-68f92eb9b282@arm.com>
	<B8AC3E80E903784988AB3003E3E97330C00635F3@dggemm510-mbs.china.huawei.com>
	<87po8ir1kg.fsf@on-the-bus.cambridge.arm.com>
	<B8AC3E80E903784988AB3003E3E97330C006371B@dggemm510-mbs.china.huawei.com>
 <87375eqobb.fsf@on-the-bus.cambridge.arm.com>
In-Reply-To: <87375eqobb.fsf@on-the-bus.cambridge.arm.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Zyngier <marc.zyngier@arm.com>
Cc: "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "afzal.mohd.ma@gmail.com" <afzal.mohd.ma@gmail.com>, "f.fainelli@gmail.com" <f.fainelli@gmail.com>, "labbott@redhat.com" <labbott@redhat.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mhocko@suse.com" <mhocko@suse.com>, "cdall@linaro.org" <cdall@linaro.org>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "thgarnie@google.com" <thgarnie@google.com>, "keescook@chromium.org" <keescook@chromium.org>, "arnd@arndb.de" <arnd@arndb.de>, "vladimir.murzin@arm.com" <vladimir.murzin@arm.com>, "tixy@linaro.org" <tixy@linaro.org>, "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>, "robin.murphy@arm.com" <robin.murphy@arm.com>, "mingo@kernel.org" <mingo@kernel.org>, "grygorii.strashko@linaro.org" <grygorii.strashko@linaro.org>, "glider@google.com" <glider@google.com>, "dvyukov@google.com" <dvyukov@google.com>, "opendmb@gmail.com" <opendmb@gmail.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jiazhenghua <jiazhenghua@huawei.com>, Dailei <dylix.dailei@huawei.com>, Zengweilin <zengweilin@huawei.com>, Heshaoliang <heshaoliang@huawei.com>

T24gMTYvMTEvMTcgIDIyOjQxIE1hcmMgWnluZ2llciBbbWFpbHRvOm1hcmMuenluZ2llckBhcm0u
Y29tXSB3cm90ZToNCj5ObywgaXQgZG9lc24ndC4gSXQgY2Fubm90IHdvcmssIGJlY2F1c2UgQ29y
dGV4LUE5IHByZWRhdGVzIHRoZSBpbnZlbnRpb24NCj5vZiB0aGUgNjRiaXQgYWNjZXNzb3IuIEkg
c3VzcGVjdCB0aGF0IHlvdSBhcmUgdGVzdGluZyBzdHVmZiBpbiBRRU1VLA0KPndoaWNoIGlzIGdp
dmluZyB5b3UgYSBTVyBtb2RlbCB0aGF0IGFsd2F5cyBzdXBwb3J0cyBMUEFFLiBJIHN1Z2dlc3Qg
eW91DQo+dGVzdCB0aGlzIGNvZGUgb24gKnJlYWwqIEhXLCBhbmQgbm90IG9ubHkgb24gUUVNVS4N
Cg0KSSBhbSBzb3JyeS4gTXkgdGVzdCBpcyBmYXVsdC4gSSBvbmx5IGRlZmluZWQgVFRCUjAgYXMg
X19BQ0NFU1NfQ1AxNV82NCwNCmJ1dCBJIGRvbid0IHVzZSB0aGUgZGVmaW5pdGlvbiBUVEJSMCBh
cyBfX0FDQ0VTU19DUDE1XzY0LiANCg0KTm93IEkgdXNlIHRoZSBkZWZpbml0aW9uIFRUQlIwIGFz
IF9fQUNDRVNTX0NQMTVfNjQgb24gQ1BVIHN1cHBvcnRpbmcNCkxQQUUodmV4cHJlc3NfYTkpLCBJ
IGZpbmQgaXQgZG9lc24ndCB3b3JrIGFuZCByZXBvcnQgdW5kZWZpbmVkIGluc3RydWN0aW9uIGVy
cm9yDQp3aGVuIGV4ZWN1dGUgIm1ycmMiIGluc3RydWN0aW9uLg0KDQpTbywgeW91IGFyZSByaWdo
dCB0aGF0IDY0Yml0IGFjY2Vzc29yIG9mIFRUQlIwIGNhbm5vdCB3b3JrIG9uIExQQUUuDQoNCg==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
