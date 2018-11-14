Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1CEBA6B0273
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 17:58:00 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id e14so454449wru.19
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 14:58:00 -0800 (PST)
Received: from NAM02-SN1-obe.outbound.protection.outlook.com (mail-eopbgr770071.outbound.protection.outlook.com. [40.107.77.71])
        by mx.google.com with ESMTPS id x81-v6si15477160wmd.139.2018.11.14.14.57.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 14 Nov 2018 14:57:58 -0800 (PST)
From: Nadav Amit <namit@vmware.com>
Subject: Re: [PATCH RFC 0/6] mm/kdump: allow to exclude pages that are
 logically offline
Date: Wed, 14 Nov 2018 22:57:51 +0000
Message-ID: <8932E1F4-A5A9-4462-9800-CAC1EF85AC5D@vmware.com>
References: <20181114211704.6381-1-david@redhat.com>
In-Reply-To: <20181114211704.6381-1-david@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8127D4BDFD768A4B9EE74019E7FFB6E1@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>, linux-mm <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, xen-devel <xen-devel@lists.xenproject.org>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Baoquan He <bhe@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Christian Hansen <chansen3@cisco.com>, Dave Young <dyoung@redhat.com>, David Rientjes <rientjes@google.com>, Haiyang Zhang <haiyangz@microsoft.com>, Jonathan Corbet <corbet@lwn.net>, Juergen Gross <jgross@suse.com>, Kairui Song <kasong@redhat.com>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Len Brown <len.brown@intel.com>, Matthew Wilcox <willy@infradead.org>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Miles Chen <miles.chen@mediatek.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Omar Sandoval <osandov@fb.com>, Pavel Machek <pavel@ucw.cz>, Pavel Tatashin <pasha.tatashin@oracle.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Stefano Stabellini <sstabellini@kernel.org>, Stephen Hemminger <sthemmin@microsoft.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Vitaly Kuznetsov <vkuznets@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Julien Freche <jfreche@vmware.com>

From: David Hildenbrand
Sent: November 14, 2018 at 9:16:58 PM GMT
> Subject: [PATCH RFC 0/6] mm/kdump: allow to exclude pages that are logica=
lly offline
>=20
>=20
> Right now, pages inflated as part of a balloon driver will be dumped
> by dump tools like makedumpfile. While XEN is able to check in the
> crash kernel whether a certain pfn is actuall backed by memory in the
> hypervisor (see xen_oldmem_pfn_is_ram) and optimize this case, dumps of
> virtio-balloon and hv-balloon inflated memory will essentially result in
> zero pages getting allocated by the hypervisor and the dump getting
> filled with this data.

Is there any reason that VMware balloon driver is not mentioned?
