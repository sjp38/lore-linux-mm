Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2D4316B0038
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 00:39:16 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a9so806647pgf.12
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 21:39:16 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0050.outbound.protection.outlook.com. [104.47.37.50])
        by mx.google.com with ESMTPS id z2si8254603pfe.157.2018.01.18.21.39.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 18 Jan 2018 21:39:14 -0800 (PST)
From: "He, Roger" <Hongbo.He@amd.com>
Subject: RE: [RFC] Per file OOM badness
Date: Fri, 19 Jan 2018 05:39:11 +0000
Message-ID: <DM5PR1201MB012142B041369BF6911C5818FDEF0@DM5PR1201MB0121.namprd12.prod.outlook.com>
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
In-Reply-To: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Grodzovsky, Andrey" <Andrey.Grodzovsky@amd.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>
Cc: "Koenig, Christian" <Christian.Koenig@amd.com>

QmFzaWNhbGx5IHRoZSBpZGVhIGlzIHJpZ2h0IHRvIG1lLg0KDQoxLiBCdXQgd2UgbmVlZCBzbWFs
bGVyIGdyYW51bGFyaXR5IHRvIGNvbnRyb2wgdGhlIGNvbnRyaWJ1dGlvbiB0byBPT00gYmFkbmVz
cy4NCiAgICAgQmVjYXVzZSB3aGVuIHRoZSBUVE0gYnVmZmVyIHJlc2lkZXMgaW4gVlJBTSByYXRo
ZXIgdGhhbiBldmljdCB0byBzeXN0ZW0gbWVtb3J5LCB3ZSBzaG91bGQgbm90IHRha2UgdGhpcyBh
Y2NvdW50IGludG8gYmFkbmVzcy4NCiAgICAgQnV0IEkgdGhpbmsgaXQgaXMgbm90IGVhc3kgdG8g
aW1wbGVtZW50Lg0KDQoyLiBJZiB0aGUgVFRNIGJ1ZmZlcihHVFQgaGVyZSkgaXMgbWFwcGVkIHRv
IHVzZXIgZm9yIENQVSBhY2Nlc3MsIG5vdCBxdWl0ZSBzdXJlIHRoZSBidWZmZXIgc2l6ZSBpcyBh
bHJlYWR5IHRha2VuIGludG8gYWNjb3VudCBmb3Iga2VybmVsLg0KICAgICBJZiB5ZXMsIGF0IGxh
c3QgdGhlIHNpemUgd2lsbCBiZSBjb3VudGVkIGFnYWluIGJ5IHlvdXIgcGF0Y2hlcy4NCg0KU28s
IEkgYW0gdGhpbmtpbmcgaWYgd2UgY2FuIGNvdW50ZWQgdGhlIFRUTSBidWZmZXIgc2l6ZSBpbnRv
OiANCnN0cnVjdCBtbV9yc3Nfc3RhdCB7DQoJYXRvbWljX2xvbmdfdCBjb3VudFtOUl9NTV9DT1VO
VEVSU107DQp9Ow0KV2hpY2ggaXMgZG9uZSBieSBrZXJuZWwgYmFzZWQgb24gQ1BVIFZNIChwYWdl
IHRhYmxlKS4NCg0KU29tZXRoaW5nIGxpa2UgdGhhdDoNCldoZW4gR1RUIGFsbG9jYXRlIHN1Y2Vl
c3M6DQphZGRfbW1fY291bnRlcih2bWEtPnZtX21tLCBNTV9BTk9OUEFHRVMsIGJ1ZmZlcl9zaXpl
KTsNCg0KV2hlbiBHVFQgc3dhcHBlZCBvdXQ6DQpkZWNfbW1fY291bnRlciBmcm9tIE1NX0FOT05Q
QUdFUyBmcmlzdCwgdGhlbiANCmFkZF9tbV9jb3VudGVyKHZtYS0+dm1fbW0sIE1NX1NXQVBFTlRT
LCBidWZmZXJfc2l6ZSk7ICAvLyBvciBNTV9TSE1FTVBBR0VTIG9yIGFkZCBuZXcgaXRlbS4NCg0K
VXBkYXRlIHRoZSBjb3JyZXNwb25kaW5nIGl0ZW0gaW4gbW1fcnNzX3N0YXQgYWx3YXlzLg0KSWYg
dGhhdCwgd2UgY2FuIGNvbnRyb2wgdGhlIHN0YXR1cyB1cGRhdGUgYWNjdXJhdGVseS4gDQpXaGF0
IGRvIHlvdSB0aGluayBhYm91dCB0aGF0Pw0KQW5kIGlzIHRoZXJlIGFueSBzaWRlLWVmZmVjdCBm
b3IgdGhpcyBhcHByb2FjaD8NCg0KDQpUaGFua3MNClJvZ2VyKEhvbmdiby5IZSkNCg0KLS0tLS1P
cmlnaW5hbCBNZXNzYWdlLS0tLS0NCkZyb206IGRyaS1kZXZlbCBbbWFpbHRvOmRyaS1kZXZlbC1i
b3VuY2VzQGxpc3RzLmZyZWVkZXNrdG9wLm9yZ10gT24gQmVoYWxmIE9mIEFuZHJleSBHcm9kem92
c2t5DQpTZW50OiBGcmlkYXksIEphbnVhcnkgMTksIDIwMTggMTI6NDggQU0NClRvOiBsaW51eC1r
ZXJuZWxAdmdlci5rZXJuZWwub3JnOyBsaW51eC1tbUBrdmFjay5vcmc7IGRyaS1kZXZlbEBsaXN0
cy5mcmVlZGVza3RvcC5vcmc7IGFtZC1nZnhAbGlzdHMuZnJlZWRlc2t0b3Aub3JnDQpDYzogS29l
bmlnLCBDaHJpc3RpYW4gPENocmlzdGlhbi5Lb2VuaWdAYW1kLmNvbT4NClN1YmplY3Q6IFtSRkNd
IFBlciBmaWxlIE9PTSBiYWRuZXNzDQoNCkhpLCB0aGlzIHNlcmllcyBpcyBhIHJldmlzZWQgdmVy
c2lvbiBvZiBhbiBSRkMgc2VudCBieSBDaHJpc3RpYW4gS8O2bmlnIGEgZmV3IHllYXJzIGFnby4g
VGhlIG9yaWdpbmFsIFJGQyBjYW4gYmUgZm91bmQgYXQgaHR0cHM6Ly9saXN0cy5mcmVlZGVza3Rv
cC5vcmcvYXJjaGl2ZXMvZHJpLWRldmVsLzIwMTUtU2VwdGVtYmVyLzA4OTc3OC5odG1sDQoNClRo
aXMgaXMgdGhlIHNhbWUgaWRlYSBhbmQgSSd2ZSBqdXN0IGFkcmVzc2VkIGhpcyBjb25jZXJuIGZy
b20gdGhlIG9yaWdpbmFsIFJGQyBhbmQgc3dpdGNoZWQgdG8gYSBjYWxsYmFjayBpbnRvIGZpbGVf
b3BzIGluc3RlYWQgb2YgYSBuZXcgbWVtYmVyIGluIHN0cnVjdCBmaWxlLg0KDQpUaGFua3MsDQpB
bmRyZXkNCg0KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18N
CmRyaS1kZXZlbCBtYWlsaW5nIGxpc3QNCmRyaS1kZXZlbEBsaXN0cy5mcmVlZGVza3RvcC5vcmcN
Cmh0dHBzOi8vbGlzdHMuZnJlZWRlc2t0b3Aub3JnL21haWxtYW4vbGlzdGluZm8vZHJpLWRldmVs
DQo=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
