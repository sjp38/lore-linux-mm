Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A8CBA6B0330
	for <linux-mm@kvack.org>; Wed, 16 May 2018 10:05:51 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id f5-v6so324507pgq.19
        for <linux-mm@kvack.org>; Wed, 16 May 2018 07:05:51 -0700 (PDT)
Received: from g9t5008.houston.hpe.com (g9t5008.houston.hpe.com. [15.241.48.72])
        by mx.google.com with ESMTPS id 1-v6si2617943pla.565.2018.05.16.07.05.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 May 2018 07:05:49 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH v2 1/3] x86/mm: disable ioremap free page handling on
 x86-PAE
Date: Wed, 16 May 2018 14:05:45 +0000
Message-ID: <1526479474.2693.607.camel@hpe.com>
References: <20180515213931.23885-2-toshi.kani@hpe.com>
	 <201805161819.uT7J37yy%fengguang.wu@intel.com>
In-Reply-To: <201805161819.uT7J37yy%fengguang.wu@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <FCB761AEC2EE8D4AB6F7AA19CE1EB99E@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "lkp@intel.com" <lkp@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "joro@8bytes.org" <joro@8bytes.org>, "x86@kernel.org" <x86@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "kbuild-all@01.org" <kbuild-all@01.org>, "Hocko, Michal" <MHocko@suse.com>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

T24gV2VkLCAyMDE4LTA1LTE2IGF0IDE5OjAwICswODAwLCBrYnVpbGQgdGVzdCByb2JvdCB3cm90
ZToNCj4gSGkgVG9zaGksDQo+IA0KPiBUaGFuayB5b3UgZm9yIHRoZSBwYXRjaCEgWWV0IHNvbWV0
aGluZyB0byBpbXByb3ZlOg0KPiANCj4gW2F1dG8gYnVpbGQgdGVzdCBFUlJPUiBvbiBhcm02NC9m
b3ItbmV4dC9jb3JlXQ0KPiBbYWxzbyBidWlsZCB0ZXN0IEVSUk9SIG9uIHY0LjE3LXJjNSBuZXh0
LTIwMTgwNTE1XQ0KPiBbY2Fubm90IGFwcGx5IHRvIHRpcC94ODYvY29yZV0NCj4gW2lmIHlvdXIg
cGF0Y2ggaXMgYXBwbGllZCB0byB0aGUgd3JvbmcgZ2l0IHRyZWUsIHBsZWFzZSBkcm9wIHVzIGEg
bm90ZSB0byBoZWxwIGltcHJvdmUgdGhlIHN5c3RlbV0NCj4gDQo+IHVybDogICAgaHR0cHM6Ly9n
aXRodWIuY29tLzBkYXktY2kvbGludXgvY29tbWl0cy9Ub3NoaS1LYW5pL2ZpeC1mcmVlLXBtZC1w
dGUtcGFnZS1oYW5kbGluZ3Mtb24teDg2LzIwMTgwNTE2LTE4MzMxNw0KPiBiYXNlOiAgIGh0dHBz
Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9saW51eC9rZXJuZWwvZ2l0L2FybTY0L2xpbnV4Lmdp
dCBmb3ItbmV4dC9jb3JlDQo+IGNvbmZpZzogaTM4Ni1yYW5kY29uZmlnLXgwMTMtMjAxODE5IChh
dHRhY2hlZCBhcyAuY29uZmlnKQ0KPiBjb21waWxlcjogZ2NjLTcgKERlYmlhbiA3LjMuMC0xNikg
Ny4zLjANCj4gcmVwcm9kdWNlOg0KPiAgICAgICAgICMgc2F2ZSB0aGUgYXR0YWNoZWQgLmNvbmZp
ZyB0byBsaW51eCBidWlsZCB0cmVlDQo+ICAgICAgICAgbWFrZSBBUkNIPWkzODYgDQo+IA0KPiBO
b3RlOiB0aGUgbGludXgtcmV2aWV3L1Rvc2hpLUthbmkvZml4LWZyZWUtcG1kLXB0ZS1wYWdlLWhh
bmRsaW5ncy1vbi14ODYvMjAxODA1MTYtMTgzMzE3IEhFQUQgOTM5NDQ0MjJmY2VmOWJmYWRmMjJl
MzQ1YzFkN2EzNDcyM2NjMzIwMyBidWlsZHMgZmluZS4NCj4gICAgICAgSXQgb25seSBodXJ0cyBi
aXNlY3RpYmlsaXR5Lg0KPiANCj4gQWxsIGVycm9ycyAobmV3IG9uZXMgcHJlZml4ZWQgYnkgPj4p
Og0KPiANCj4gPiA+IGFyY2gveDg2L21tL3BndGFibGUuYzo3NTc6NTogZXJyb3I6IGNvbmZsaWN0
aW5nIHR5cGVzIGZvciAncHVkX2ZyZWVfcG1kX3BhZ2UnDQo+IA0KPiAgICAgaW50IHB1ZF9mcmVl
X3BtZF9wYWdlKHB1ZF90ICpwdWQsIHVuc2lnbmVkIGxvbmcgYWRkcikNCj4gICAgICAgICBefn5+
fn5+fn5+fn5+fn5+fg0KDQpUaGFua3MgZm9yIGNhdGNoaW5nIHRoaXMhICBQYXRjaCByZW9yZGVy
aW5nIGNhdXNlZCB0aGlzLiAgV2lsbCBmaXguDQotVG9zaGkNCg==
