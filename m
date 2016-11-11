Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 347776B0274
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 20:26:51 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id m76so4113670ybm.5
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 17:26:51 -0800 (PST)
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (mail-by2nam01on0092.outbound.protection.outlook.com. [104.47.34.92])
        by mx.google.com with ESMTPS id 107si1079951oti.250.2016.11.10.17.26.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 10 Nov 2016 17:26:50 -0800 (PST)
From: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Subject: Re: [RFC PATCH v3 02/20] x86: Set the write-protect cache mode for
 full PAT support
Date: Fri, 11 Nov 2016 01:26:48 +0000
Message-ID: <1478827480.20881.142.camel@hpe.com>
References: <20161110003426.3280.2999.stgit@tlendack-t1.amdoffice.net>
	 <20161110003448.3280.27573.stgit@tlendack-t1.amdoffice.net>
	 <20161110131400.bmeoojsrin2zi2w2@pd.tnic>
In-Reply-To: <20161110131400.bmeoojsrin2zi2w2@pd.tnic>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <5A008A45AA7B1344A2346C26C53E4AD3@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "thomas.lendacky@amd.com" <thomas.lendacky@amd.com>, "bp@alien8.de" <bp@alien8.de>
Cc: "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "dvyukov@google.com" <dvyukov@google.com>, "corbet@lwn.net" <corbet@lwn.net>, "arnd@arndb.de" <arnd@arndb.de>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "aryabinin@virtuozzo.com" <aryabinin@virtuozzo.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>, "kasan-dev@googlegroups.com" <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>, "riel@redhat.com" <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "mingo@redhat.com" <mingo@redhat.com>, "joro@8bytes.org" <joro@8bytes.org>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, "pbonzini@redhat.com" <pbonzini@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "luto@kernel.org" <luto@kernel.org>, "glider@google.com" <glider@google.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "rkrcmar@redhat.com" <rkrcmar@redhat.com>

T24gVGh1LCAyMDE2LTExLTEwIGF0IDE0OjE0ICswMTAwLCBCb3Jpc2xhdiBQZXRrb3Ygd3JvdGU6
DQo+ICsgVG9zaGkuDQo+IA0KPiBPbiBXZWQsIE5vdiAwOSwgMjAxNiBhdCAwNjozNDo0OFBNIC0w
NjAwLCBUb20gTGVuZGFja3kgd3JvdGU6DQo+ID4gDQo+ID4gRm9yIHByb2Nlc3NvcnMgdGhhdCBz
dXBwb3J0IFBBVCwgc2V0IHRoZSB3cml0ZS1wcm90ZWN0IGNhY2hlIG1vZGUNCj4gPiAoX1BBR0Vf
Q0FDSEVfTU9ERV9XUCkgZW50cnkgdG8gdGhlIGFjdHVhbCB3cml0ZS1wcm90ZWN0IHZhbHVlDQo+
ID4gKHgwNSkuDQoNClVzaW5nIHNsb3QgNiBtYXkgYmUgbW9yZSBjYXV0aW91cyAoZm9yIHRoZSBz
YW1lIHJlYXNvbiBzbG90IDcgd2FzIHVzZWQNCmZvciBXVCksIGJ1dCBJIGRvIG5vdCBoYXZlIGEg
c3Ryb25nIG9waW5pb24gZm9yIGl0Lg0KDQpzZXRfcGFnZV9tZW10eXBlKCkgY2Fubm90IHRyYWNr
IHRoZSB1c2Ugb2YgV1AgdHlwZSBzaW5jZSB0aGVyZSBpcyBubw0KZXh0cmEtYml0IGF2YWlsYWJs
ZSBmb3IgV1AsIGJ1dCBXUCBpcyBvbmx5IHN1cHBvcnRlZCBieQ0KZWFybHlfbWVtcmVtYXBfeHgo
KSBpbnRlcmZhY2VzIGluIHRoaXMgc2VyaWVzLiDCoFNvLCBJIHRoaW5rIHdlIHNob3VsZA0KanVz
dCBkb2N1bWVudCB0aGF0IFdQIGlzIG9ubHkgaW50ZW5kZWQgZm9yIHRlbXBvcmFyeSBtYXBwaW5n
cyBhdCBib290LQ0KdGltZSB1bnRpbCB0aGlzIGlzc3VlIGlzIHJlc29sdmVkLiDCoEFsc28sIHdl
IG5lZWQgdG8gbWFrZSBzdXJlIHRoYXQNCnRoaXMgZWFybHlfbWVtcmVtYXAgZm9yIFdQIGlzIG9u
bHkgY2FsbGVkIGFmdGVyIHBhdF9pbml0KCkgaXMgZG9uZS4NCg0KQSBuaXQgLSBwbGVhc2UgYWRk
IFdQIHRvIHRoZSBmdW5jdGlvbiBoZWFkZXIgY29tbWVudCBiZWxvdy4NCiJUaGlzIGZ1bmN0aW9u
IGluaXRpYWxpemVzIFBBVCBNU1IgYW5kIFBBVCB0YWJsZSB3aXRoIGFuIE9TLWRlZmluZWQNCnZh
bHVlIHRvIGVuYWJsZSBhZGRpdGlvbmFsIGNhY2hlIGF0dHJpYnV0ZXMsIFdDIGFuZCBXVC4iDQoN
ClRoYW5rcywNCi1Ub3NoaQ==

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
