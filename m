Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 772626B000A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 03:08:00 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id 203-v6so446080wmv.1
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 00:08:00 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f8-v6sor4964101wrj.7.2018.10.05.00.07.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Oct 2018 00:07:59 -0700 (PDT)
Date: Fri, 5 Oct 2018 09:07:56 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v3 3/6] mm/memory_hotplug: fix online/offline_pages
 called w.o. mem_hotplug_lock
Message-ID: <20181005070756.GA27754@techadventures.net>
References: <20180927092554.13567-1-david@redhat.com>
 <20180927092554.13567-4-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180927092554.13567-4-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Rashmica Gupta <rashmica.g@gmail.com>, Michael Neuling <mikey@neuling.org>, Balbir Singh <bsingharora@gmail.com>, Kate Stewart <kstewart@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Mathieu Malaterre <malat@debian.org>

On Thu, Sep 27, 2018 at 11:25:51AM +0200, David Hildenbrand wrote:
> Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
> Reviewed-by: Rashmica Gupta <rashmica.g@gmail.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>
-- 
Oscar Salvador
SUSE L3
