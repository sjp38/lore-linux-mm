Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id D8BD46B0003
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 11:07:33 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v2-v6so3357829wrr.10
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 08:07:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r13-v6sor1187076wmc.59.2018.07.27.08.07.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 27 Jul 2018 08:07:32 -0700 (PDT)
Date: Fri, 27 Jul 2018 17:07:30 +0200
From: Oscar Salvador <osalvador@techadventures.net>
Subject: Re: [PATCH v2 2/3] mm: calculate deferred pages after skipping
 mirrored memory
Message-ID: <20180727150730.GA14428@techadventures.net>
References: <20180726193509.3326-1-pasha.tatashin@oracle.com>
 <20180726193509.3326-3-pasha.tatashin@oracle.com>
 <20180727115645.GA13637@techadventures.net>
 <CAGM2reZnrwy1Y8MFRgyDLG8VZ6Hf+v-PAmZvUG4H65zunmjWZw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reZnrwy1Y8MFRgyDLG8VZ6Hf+v-PAmZvUG4H65zunmjWZw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, dan.j.williams@intel.com, jack@suse.cz, jglisse@redhat.com, Souptick Joarder <jrdr.linux@gmail.com>, bhe@redhat.com, gregkh@linuxfoundation.org, Vlastimil Babka <vbabka@suse.cz>, Wei Yang <richard.weiyang@gmail.com>, dave.hansen@intel.com, rientjes@google.com, mingo@kernel.org, abdhalee@linux.vnet.ibm.com, mpe@ellerman.id.au

On Fri, Jul 27, 2018 at 10:53:24AM -0400, Pavel Tatashin wrote:
>                          unsigned long *nr_initialised)
> > > +static bool __meminit
> > > +defer_init(int nid, unsigned long pfn, unsigned long end_pfn)
> >
> > Hi Pavel,
> >
> > maybe I do not understand properly the __init/__meminit macros, but should not
> > "defer_init" be __init instead of __meminit?
> > I think that functions marked as __meminit are not freed up, right?
> 
> Not exactly. As I understand: __meminit is the same as __init when
> CONFIG_MEMORY_HOTPLUG=n. But, when memory hotplug is configured,
> __meminit is not freed, because code that adds memory is shared
> between boot and hotplug. In this case defer_init() is called only
> during boot, and could be __init, but it is called from
> memmap_init_zone() which is __meminit and thus section mismatch would
> happen.

Oh yes, I did not think about memmap_init_zone(), you are right.
Then, nothing to argue about ;-).

Thanks
-- 
Oscar Salvador
SUSE L3
