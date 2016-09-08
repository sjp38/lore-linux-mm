Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC7236B0266
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 09:49:41 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id f39so45315700vki.3
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 06:49:41 -0700 (PDT)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-bn3nam01on0101.outbound.protection.outlook.com. [104.47.33.101])
        by mx.google.com with ESMTPS id n79si28727118qkn.201.2016.09.08.06.49.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 08 Sep 2016 06:49:41 -0700 (PDT)
From: "Kani, Toshimitsu" <toshi.kani@hpe.com>
Subject: Re: [PATCH v4 RESEND 0/2] Align mmap address for DAX pmd mappings
Date: Thu, 8 Sep 2016 13:49:40 +0000
Message-ID: <1473342519.2092.42.camel@hpe.com>
References: <1472497881-9323-1-git-send-email-toshi.kani@hpe.com>
	 <20160829204842.GA27286@node.shutemov.name>
	 <1472506310.1532.47.camel@hpe.com> <1472508000.1532.59.camel@hpe.com>
	 <20160908105707.GA17331@node>
In-Reply-To: <20160908105707.GA17331@node>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <FA10C1A0FF88C44F97659DC33A368661@NAMPRD84.PROD.OUTLOOK.COM>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "kirill@shutemov.name" <kirill@shutemov.name>
Cc: "hughd@google.com" <hughd@google.com>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, "mawilcox@microsoft.com" <mawilcox@microsoft.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "tytso@mit.edu" <tytso@mit.edu>, "david@fromorbit.com" <david@fromorbit.com>, "jack@suse.cz" <jack@suse.cz>

T24gVGh1LCAyMDE2LTA5LTA4IGF0IDEzOjU3ICswMzAwLCBLaXJpbGwgQS4gU2h1dGVtb3Ygd3Jv
dGU6DQo+IE9uIE1vbiwgQXVnIDI5LCAyMDE2IGF0IDEwOjAwOjQzUE0gKzAwMDAsIEthbmksIFRv
c2hpbWl0c3Ugd3JvdGU6DQo+ID4gDQo+ID4gT24gTW9uLCAyMDE2LTA4LTI5IGF0IDE1OjMxIC0w
NjAwLCBLYW5pLCBUb3NoaW1pdHN1IHdyb3RlOg0KPiA+ID4gDQo+ID4gPiBPbiBNb24sIDIwMTYt
MDgtMjkgYXQgMjM6NDggKzAzMDAsIEtpcmlsbCBBLiBTaHV0ZW1vdiB3cm90ZToNCj4gPiA+ID4g
DQrCoDoNCj4gPiBMb29raW5nIGZ1cnRoZXIsIHRoZXNlIHNobWVtX2h1Z2UgaGFuZGxpbmdzIG9u
bHkgY2hlY2sgcHJlLQ0KPiA+IGNvbmRpdGlvbnMuIMKgU28sIHdlIHNob3VsZCANCj4gPiBiZcKg
YWJsZcKgdG/CoG1ha2XCoHNobWVtX2dldF91bm1hcHBlZF9hcmVhKCkgYXMgYSB3cmFwcGVyLCB3
aGljaA0KPiA+IGNoZWNrcyBzdWNoIHNobWVtLXNwZWNpZmljIGNvbml0aW9ucywgYW5kDQo+ID4g
dGhlbsKgY2FsbMKgX190aHBfZ2V0X3VubWFwcGVkX2FyZWEoKSBmb3IgdGhlIGFjdHVhbCB3b3Jr
LiDCoEFsbCBEQVgtDQo+ID4gc3BlY2lmaWMgY2hlY2tzIGFyZSBwZXJmb3JtZWQgaW4gdGhwX2dl
dF91bm1hcHBlZF9hcmVhKCkgYXMgd2VsbC4NCj4gPiDCoFdlIGNhbiBtYWtlIMKgX190aHBfZ2V0
X3VubWFwcGVkX2FyZWEoKSBhcyBhIGNvbW1vbiBmdW5jdGlvbi4NCj4gPiANCj4gPiBJJ2QgcHJl
ZmVyIHRvIG1ha2Ugc3VjaCBjaGFuZ2UgYXMgYSBzZXBhcmF0ZSBpdGVtLA0KPiANCj4gRG8geW91
IGhhdmUgcGxhbiB0byBzdWJtaXQgc3VjaCBjaGFuZ2U/DQoNClllcywgSSB3aWxsIHN1Ym1pdCB0
aGUgY2hhbmdlIG9uY2UgSSBmaW5pc2ggdGVzdGluZy4NCg0KVGhhbmtzLA0KLVRvc2hp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
