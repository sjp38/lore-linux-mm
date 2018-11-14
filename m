Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id E86F66B000D
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 18:41:26 -0500 (EST)
Received: by mail-yb1-f197.google.com with SMTP id f17-v6so11728323yba.15
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 15:41:26 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-eopbgr760082.outbound.protection.outlook.com. [40.107.76.82])
        by mx.google.com with ESMTPS id r9-v6si2455962ybj.458.2018.11.14.15.41.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Nov 2018 15:41:25 -0800 (PST)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH RFC 0/6] mm/kdump: allow to exclude pages that are
 logically offline
Date: Wed, 14 Nov 2018 23:41:16 +0000
Message-ID: <63214D36-14FD-4080-8E35-CF2A392D6507@vmware.com>
References: <20181114211704.6381-1-david@redhat.com>
 <8932E1F4-A5A9-4462-9800-CAC1EF85AC5D@vmware.com>
 <63c5f4b6-828a-764e-f64d-e603dc4b104e@redhat.com>
In-Reply-To: <63c5f4b6-828a-764e-f64d-e603dc4b104e@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <45598D8ED7B9944FBB381B5CF426DFE4@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, linux-mm <linux-mm@kvack.org>, Julien Freche <jfreche@vmware.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, xen-devel <xen-devel@lists.xenproject.org>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Baoquan He <bhe@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Christian Hansen <chansen3@cisco.com>, Dave Young <dyoung@redhat.com>, David Rientjes <rientjes@google.com>, Haiyang Zhang <haiyangz@microsoft.com>, Jonathan Corbet <corbet@lwn.net>, Juergen Gross <jgross@suse.com>, Kairui Song <kasong@redhat.com>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Len Brown <len.brown@intel.com>, Matthew Wilcox <willy@infradead.org>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Miles Chen <miles.chen@mediatek.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Omar Sandoval <osandov@fb.com>, Pavel Machek <pavel@ucw.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Stefano Stabellini <sstabellini@kernel.org>, Stephen Hemminger <sthemmin@microsoft.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Vitaly Kuznetsov <vkuznets@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

RnJvbTogRGF2aWQgSGlsZGVuYnJhbmQNClNlbnQ6IE5vdmVtYmVyIDE0LCAyMDE4IGF0IDExOjA1
OjM4IFBNIEdNVA0KPiBTdWJqZWN0OiBSZTogW1BBVENIIFJGQyAwLzZdIG1tL2tkdW1wOiBhbGxv
dyB0byBleGNsdWRlIHBhZ2VzIHRoYXQgYXJlIGxvZ2ljYWxseSBvZmZsaW5lDQo+IA0KPiANCj4g
T24gMTQuMTEuMTggMjM6NTcsIE5hZGF2IEFtaXQgd3JvdGU6DQo+PiBGcm9tOiBEYXZpZCBIaWxk
ZW5icmFuZA0KPj4gU2VudDogTm92ZW1iZXIgMTQsIDIwMTggYXQgOToxNjo1OCBQTSBHTVQNCj4+
PiBTdWJqZWN0OiBbUEFUQ0ggUkZDIDAvNl0gbW0va2R1bXA6IGFsbG93IHRvIGV4Y2x1ZGUgcGFn
ZXMgdGhhdCBhcmUgbG9naWNhbGx5IG9mZmxpbmUNCj4+PiANCj4+PiANCj4+PiBSaWdodCBub3cs
IHBhZ2VzIGluZmxhdGVkIGFzIHBhcnQgb2YgYSBiYWxsb29uIGRyaXZlciB3aWxsIGJlIGR1bXBl
ZA0KPj4+IGJ5IGR1bXAgdG9vbHMgbGlrZSBtYWtlZHVtcGZpbGUuIFdoaWxlIFhFTiBpcyBhYmxl
IHRvIGNoZWNrIGluIHRoZQ0KPj4+IGNyYXNoIGtlcm5lbCB3aGV0aGVyIGEgY2VydGFpbiBwZm4g
aXMgYWN0dWFsbCBiYWNrZWQgYnkgbWVtb3J5IGluIHRoZQ0KPj4+IGh5cGVydmlzb3IgKHNlZSB4
ZW5fb2xkbWVtX3Bmbl9pc19yYW0pIGFuZCBvcHRpbWl6ZSB0aGlzIGNhc2UsIGR1bXBzIG9mDQo+
Pj4gdmlydGlvLWJhbGxvb24gYW5kIGh2LWJhbGxvb24gaW5mbGF0ZWQgbWVtb3J5IHdpbGwgZXNz
ZW50aWFsbHkgcmVzdWx0IGluDQo+Pj4gemVybyBwYWdlcyBnZXR0aW5nIGFsbG9jYXRlZCBieSB0
aGUgaHlwZXJ2aXNvciBhbmQgdGhlIGR1bXAgZ2V0dGluZw0KPj4+IGZpbGxlZCB3aXRoIHRoaXMg
ZGF0YS4NCj4+IA0KPj4gSXMgdGhlcmUgYW55IHJlYXNvbiB0aGF0IFZNd2FyZSBiYWxsb29uIGRy
aXZlciBpcyBub3QgbWVudGlvbmVkPw0KPiANCj4gRGVmaW5pdGVseSAuLi4NCj4gDQo+IC4uLiBu
b3QgOykgLiBJIGhhdmVuJ3QgbG9va2VkIGF0IHZtd2FyZSdzIGJhbGxvb24gZHJpdmVyIHlldCAo
SSBvbmx5IHNhdw0KPiB0aGF0IHRoZXJlIHdhcyBxdWl0ZSBzb21lIGFjdGl2aXR5IHJlY2VudGx5
KS4gSSBndWVzcyBpdCBzaG91bGQgaGF2ZQ0KPiBzaW1pbGFyIHByb2JsZW1zLiAoSSBtZWFuIHJl
YWRpbmcgYW5kIGR1bXBpbmcgZGF0YSBub2JvZHkgY2FyZXMgYWJvdXQgaXMNCj4gY2VydGFpbmx5
IG5vdCBkZXNpcmVkKQ0KPiANCj4gQ2FuIHlvdSBzaGFyZSBpZiBzb21ldGhpbmcgbGlrZSB0aGlz
IGlzIGFsc28gZGVzaXJlZCBmb3Igdm13YXJlJ3MNCj4gaW1wbGVtZW50YXRpb24/IChJIHRhZ2dl
ZCB0aGlzIGFzIFJGQyB0byBnZXQgc29tZSBtb3JlIGZlZWRiYWNrKQ0KPiANCj4gSXQgc2hvdWxk
IGluIHRoZW9yeSBiZSBhcyBzaW1wbGUgYXMgYWRkaW5nIGEgaGFuZGZ1bCBvZg0KPiBfU2V0UGFn
ZU9mZmxpbmUoKS9fQ2xlYXJQYWdlT2ZmbGluZSgpIGF0IHRoZSByaWdodCBzcG90cy4NCg0KVGhh
bmtzLCBJIHdhcyBqdXN0IHN1c3BlY3RpbmcgaXQgaXMgcGVyc29uYWwgOy0pDQoNCkFjdHVhbGx5
LCBzb21lIHBhdGNoZXMgdGhhdCBJIHNlbnQgZm9yIDQuMjAgdG8gdXNlIHRoZSBiYWxsb29uLWNv
bXBhY3Rpb24NCmluZnJhc3RydWN0dXJlIGJ5IHRoZSBWTXdhcmUgYmFsbG9vbiBmZWxsIGJldHdl
ZW4gdGhlIGNyYWNrcywgYW5kIEkgbmVlZA0KdG8gcmVzZW5kIHRoZW0uDQoNCkkgd291bGQgb2J2
aW91c2x5IHByZWZlciB0aGF0IHlvdXIgY2hhbmdlcyB3b3VsZCBiZSBkb25lIG9uIHRvcCBvZiB0
aG9zZQ0KdGhhdCB3ZXJlIHNraXBwZWQuIFRoaXMgcGF0Y2gtc2V0IHNvdW5kcyB2ZXJ5IHJlYXNv
bmFibGUgdG8gbWUsIGJ1dCBJIHByZWZlcg0KdGhhdCBKdWxpZW4gKGNj4oCZZCkgd291bGQgYWxz
byBnaXZlIGhpcyBvcGluaW9uLg0KDQpSZWdhcmRzLA0KTmFkYXY=
