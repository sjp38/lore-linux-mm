Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id D27336B0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 16:38:55 -0500 (EST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH V3] ia64/mm: fix a bad_page bug when crash kernel booting
Date: Tue, 19 Feb 2013 21:38:52 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F1E06A8F1@ORSMSX108.amr.corp.intel.com>
References: <51074786.5030007@huawei.com>
 <1359995565.7515.178.camel@mfleming-mobl1.ger.corp.intel.com>
 <51131248.3080203@huawei.com> <5113450C.1080109@huawei.com>
In-Reply-To: <5113450C.1080109@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: "Fleming, Matt" <matt.fleming@intel.com>, "Yu, Fenghua" <fenghua.yu@intel.com>, Liujiang <jiang.liu@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hanjun Guo <guohanjun@huawei.com>, WuJianguo <wujianguo@huawei.com>

PiBJbiBlZmlfaW5pdCgpIG1lbW9yeSBhbGlnbnMgaW4gSUE2NF9HUkFOVUxFX1NJWkUoMTZNKS4g
SWYgc2V0ICJjcmFzaGtlcm5lbD0xMDI0TS06NjAwTSINCg0KSXMgdGhpcyB3aGVyZSB0aGUgcmVh
bCBwcm9ibGVtIGJlZ2lucz8gIFNob3VsZCB3ZSBpbnNpc3QgdGhhdCB1c2VycyBwcm92aWRlIGNy
YXNoa2VybmVsDQpwYXJhbWV0ZXJzIHJvdW5kZWQgdG8gR1JBTlVMRSBib3VuZGFyaWVzPw0KDQot
VG9ueQ0K

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
