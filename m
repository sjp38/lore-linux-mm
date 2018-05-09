Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 90F346B052F
	for <linux-mm@kvack.org>; Wed,  9 May 2018 11:47:54 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f35-v6so3930835plb.10
        for <linux-mm@kvack.org>; Wed, 09 May 2018 08:47:54 -0700 (PDT)
Received: from g2t2352.austin.hpe.com (g2t2352.austin.hpe.com. [15.233.44.25])
        by mx.google.com with ESMTPS id p15-v6si7018969pgf.287.2018.05.09.08.47.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 08:47:53 -0700 (PDT)
From: "Kani, Toshi" <toshi.kani@hpe.com>
Subject: Re: [PATCH 3/3] x86/mm: disable ioremap free page handling on x86-PAE
Date: Wed, 9 May 2018 15:47:19 +0000
Message-ID: <1525880775.2693.558.camel@hpe.com>
References: <20180430175925.2657-1-toshi.kani@hpe.com>
	 <20180430175925.2657-4-toshi.kani@hpe.com>
In-Reply-To: <20180430175925.2657-4-toshi.kani@hpe.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <C8A4E1ED8C323440AC59F286858F2AF9@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tglx@linutronix.de" <tglx@linutronix.de>, "hpa@zytor.com" <hpa@zytor.com>, "joro@8bytes.org" <joro@8bytes.org>, "Hocko, Michal" <MHocko@suse.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@redhat.com" <mingo@redhat.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "cpandya@codeaurora.org" <cpandya@codeaurora.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

T24gTW9uLCAyMDE4LTA0LTMwIGF0IDExOjU5IC0wNjAwLCBUb3NoaSBLYW5pIHdyb3RlOg0KPiBp
b3JlbWFwKCkgc3VwcG9ydHMgcG1kIG1hcHBpbmdzIG9uIHg4Ni1QQUUuICBIb3dldmVyLCBrZXJu
ZWwncyBwbWQNCj4gdGFibGVzIGFyZSBub3Qgc2hhcmVkIGFtb25nIHByb2Nlc3NlcyBvbiB4ODYt
UEFFLiAgVGhlcmVmb3JlLCBhbnkNCj4gdXBkYXRlIHRvIHN5bmMnZCBwbWQgZW50cmllcyBuZWVk
IHJlLXN5bmNpbmcuICBGcmVlaW5nIGEgcHRlIHBhZ2UNCj4gYWxzbyBsZWFkcyB0byBhIHZtYWxs
b2MgZmF1bHQgYW5kIGhpdHMgdGhlIEJVR19PTiBpbiB2bWFsbG9jX3N5bmNfb25lKCkuDQo+IA0K
PiBEaXNhYmxlIGZyZWUgcGFnZSBoYW5kbGluZyBvbiB4ODYtUEFFLiAgcHVkX2ZyZWVfcG1kX3Bh
Z2UoKSBhbmQNCj4gcG1kX2ZyZWVfcHRlX3BhZ2UoKSBzaW1wbHkgcmV0dXJuIDAgaWYgYSBnaXZl
biBwdWQvcG1kIGVudHJ5IGlzIHByZXNlbnQuDQo+IFRoaXMgYXNzdXJlcyB0aGF0IGlvcmVtYXAo
KSBkb2VzIG5vdCB1cGRhdGUgc3luYydkIHBtZCBlbnRyaWVzIGF0IHRoZQ0KPiBjb3N0IG9mIGZh
bGxpbmcgYmFjayB0byBwdGUgbWFwcGluZ3MuDQo+IA0KPiBGaXhlczogMjhlZTkwZmU2MDQ4ICgi
eDg2L21tOiBpbXBsZW1lbnQgZnJlZSBwbWQvcHRlIHBhZ2UgaW50ZXJmYWNlcyIpDQo+IFJlcG9y
dGVkLWJ5OiBKb2VyZyBSb2VkZWwgPGpvcm9AOGJ5dGVzLm9yZz4NCg0KSGkgSm9lcmcsDQoNCkRv
ZXMgaXQgc29sdmUgeW91ciBwcm9ibGVtPyAgTGV0IG1lIGtub3cgaWYgeW91IGhhdmUgYW55IGlz
c3VlIHdpdGggdGhlDQpzZXJpZXMuIA0KDQpUaGFua3MsDQotVG9zaGkNCg==
