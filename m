Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0935E6B4FE2
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 11:54:38 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id g12-v6so4169584plo.1
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 08:54:37 -0700 (PDT)
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (mail-eopbgr730110.outbound.protection.outlook.com. [40.107.73.110])
        by mx.google.com with ESMTPS id v17-v6si7032163pgk.178.2018.08.30.08.54.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 30 Aug 2018 08:54:37 -0700 (PDT)
From: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Subject: Re: [PATCH RFCv2 0/6] mm: online/offline_pages called w.o.
 mem_hotplug_lock
Date: Thu, 30 Aug 2018 15:54:30 +0000
Message-ID: <b9eb96e7-3846-1aaa-d257-895ca142b1ef@microsoft.com>
References: <20180821104418.12710-1-david@redhat.com>
 <37ea507e-b16d-ae8d-4da8-128b621869f2@redhat.com>
In-Reply-To: <37ea507e-b16d-ae8d-4da8-128b621869f2@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="utf-8"
Content-ID: <C3DB3B11124F444D8932C0F350E2E1D9@namprd21.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Haiyang Zhang <haiyangz@microsoft.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, John Allen <jallen@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Juergen Gross <jgross@suse.com>, Kate Stewart <kstewart@linuxfoundation.org>, KY Srinivasan <kys@microsoft.com>, Len Brown <lenb@kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Mathieu Malaterre <malat@debian.org>, Michael Ellerman <mpe@ellerman.id.au>, Michael Neuling <mikey@neuling.org>, Michal Hocko <mhocko@suse.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Oscar Salvador <osalvador@suse.de>, Paul Mackerras <paulus@samba.org>, Philippe Ombredanne <pombredanne@nexb.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Rashmica Gupta <rashmica.g@gmail.com>, Stephen Hemminger <sthemmin@microsoft.com>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>

DQoNCk9uIDgvMzAvMTggODozMSBBTSwgRGF2aWQgSGlsZGVuYnJhbmQgd3JvdGU6DQo+IE9uIDIx
LjA4LjIwMTggMTI6NDQsIERhdmlkIEhpbGRlbmJyYW5kIHdyb3RlOg0KPj4gVGhpcyBpcyB0aGUg
c2FtZSBhcHByb2FjaCBhcyBpbiB0aGUgZmlyc3QgUkZDLCBidXQgdGhpcyB0aW1lIHdpdGhvdXQN
Cj4+IGV4cG9ydGluZyBkZXZpY2VfaG90cGx1Z19sb2NrIChyZXF1ZXN0ZWQgYnkgR3JlZykgYW5k
IHdpdGggc29tZSBtb3JlDQo+PiBkZXRhaWxzIGFuZCBkb2N1bWVudGF0aW9uIHJlZ2FyZGluZyBs
b2NraW5nLiBUZXN0ZWQgb25seSBvbiB4ODYgc28gZmFyLg0KPj4NCj4gDQo+IEknbGwgYmUgb24g
dmFjYXRpb24gZm9yIHR3byB3ZWVrcyBzdGFydGluZyBvbiBTYXR1cmRheS4gSWYgdGhlcmUgYXJl
IG5vDQo+IGNvbW1lbnRzIEknbGwgc2VuZCB0aGlzIGFzICFSRkMgb25jZSBJIHJldHVybi4NCj4N
CkkgYW0gc3R1ZHlpbmcgdGhpcyBzZXJpZXMsIHdpbGwgc2VuZCBteSBjb21tZW50cyBsYXRlciB0
b2RheS4NCg0KUGF2ZWw=
