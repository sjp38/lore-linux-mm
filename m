Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id B82406B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 20:42:38 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id u5-v6so17559334iol.11
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 17:42:38 -0800 (PST)
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-eopbgr740073.outbound.protection.outlook.com. [40.107.74.73])
        by mx.google.com with ESMTPS id 124-v6si14920506itp.17.2018.11.14.17.42.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Nov 2018 17:42:37 -0800 (PST)
From: Julien Freche <jfreche@vmware.com>
Subject: Re: [PATCH RFC 0/6] mm/kdump: allow to exclude pages that are
 logically offline
Date: Thu, 15 Nov 2018 01:42:30 +0000
Message-ID: <B6456717-0A6F-4957-A7F2-11599701226A@vmware.com>
References: <20181114211704.6381-1-david@redhat.com>
 <8932E1F4-A5A9-4462-9800-CAC1EF85AC5D@vmware.com>
 <63c5f4b6-828a-764e-f64d-e603dc4b104e@redhat.com>
 <63214D36-14FD-4080-8E35-CF2A392D6507@vmware.com>
In-Reply-To: <63214D36-14FD-4080-8E35-CF2A392D6507@vmware.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <E20FFFB53594D84E87A1E97CF4FFF55A@namprd05.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <namit@vmware.com>, David Hildenbrand <david@redhat.com>, linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, xen-devel <xen-devel@lists.xenproject.org>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Baoquan He <bhe@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Christian Hansen <chansen3@cisco.com>, Dave Young <dyoung@redhat.com>, David Rientjes <rientjes@google.com>, Haiyang Zhang <haiyangz@microsoft.com>, Jonathan Corbet <corbet@lwn.net>, Juergen Gross <jgross@suse.com>, Kairui Song <kasong@redhat.com>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Len Brown <len.brown@intel.com>, Matthew Wilcox <willy@infradead.org>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Miles Chen <miles.chen@mediatek.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Omar Sandoval <osandov@fb.com>, Pavel Machek <pavel@ucw.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Stefano Stabellini <sstabellini@kernel.org>, Stephen Hemminger <sthemmin@microsoft.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Vitaly Kuznetsov <vkuznets@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

Pk9uIDExLzE0LzE4LCAzOjQxIFBNLCAiTmFkYXYgQW1pdCIgPG5hbWl0QHZtd2FyZS5jb20+IHdy
b3RlOg0KPj5Gcm9tOiBEYXZpZCBIaWxkZW5icmFuZA0KPj5TZW50OiBOb3ZlbWJlciAxNCwgMjAx
OCBhdCAxMTowNTozOCBQTSBHTVQNCj4+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggUkZDIDAvNl0gbW0v
a2R1bXA6IGFsbG93IHRvIGV4Y2x1ZGUgcGFnZXMgdGhhdCBhcmUgbG9naWNhbGx5IG9mZmxpbmUN
Cj4+IA0KPj4gDQo+PiBDYW4geW91IHNoYXJlIGlmIHNvbWV0aGluZyBsaWtlIHRoaXMgaXMgYWxz
byBkZXNpcmVkIGZvciB2bXdhcmUncw0KPj4gaW1wbGVtZW50YXRpb24/IChJIHRhZ2dlZCB0aGlz
IGFzIFJGQyB0byBnZXQgc29tZSBtb3JlIGZlZWRiYWNrKQ0KPj4gDQo+PiBJdCBzaG91bGQgaW4g
dGhlb3J5IGJlIGFzIHNpbXBsZSBhcyBhZGRpbmcgYSBoYW5kZnVsIG9mDQo+PiBfU2V0UGFnZU9m
ZmxpbmUoKS9fQ2xlYXJQYWdlT2ZmbGluZSgpIGF0IHRoZSByaWdodCBzcG90cy4NCj4gICAgDQo+
IFRoYW5rcywgSSB3YXMganVzdCBzdXNwZWN0aW5nIGl0IGlzIHBlcnNvbmFsIDstKQ0KPg0KPiBJ
IHdvdWxkIG9idmlvdXNseSBwcmVmZXIgdGhhdCB5b3VyIGNoYW5nZXMgd291bGQgYmUgZG9uZSBv
biB0b3Agb2YgdGhvc2UNCj4gdGhhdCB3ZXJlIHNraXBwZWQuIFRoaXMgcGF0Y2gtc2V0IHNvdW5k
cyB2ZXJ5IHJlYXNvbmFibGUgdG8gbWUsIGJ1dCBJIHByZWZlcg0KPiB0aGF0IEp1bGllbiAoY2Pi
gJlkKSB3b3VsZCBhbHNvIGdpdmUgaGlzIG9waW5pb24uDQogICAgDQpJIHRoaW5rIHRoaXMgaXMg
ZGVzaXJhYmxlIGZvciBWTXdhcmUncyBpbXBsZW1lbnRhdGlvbiBhbHNvLiBZb3UgYXJlIHJpZ2h0
LA0KZHVtcGluZyBkYXRhIHRoYXQgaXMgbm90IHJlbGV2YW50IGlzIGEgd2FzdGUgOi0pIA0KSSBo
YXZlbid0IGhlYXJkIG9mIGFueSBwYW5pYy9pc3N1ZSBkdWUgdG8gdGhpcyBidXQgdGhhdCdzIHN0
aWxsIGEgZ29vZCBvcHRpbWl6YXRpb24uDQoNCk5hZGF2IG9yIEkgY291bGQgaGVscCB0byB0ZXN0
IHRoYXQgb24gRVNYIGlmIHJlcXVpcmVkLg0KDQpSZWdhcmRzLA0KDQotLSANCkp1bGllbiBGcmVj
aGUNCg0K
