Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8UNTdMA012646
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 19:29:39 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8UNTd5T190080
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 19:29:39 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8UNTc86019420
	for <linux-mm@kvack.org>; Tue, 30 Sep 2008 19:29:39 -0400
Date: Tue, 30 Sep 2008 16:29:32 -0700
From: Gary Hade <garyhade@us.ibm.com>
Subject: Re: [PATCH] mm: show node to memory section relationship with
	symlinks in sysfs
Message-ID: <20080930232932.GB7123@us.ibm.com>
References: <20080929200509.GC21255@us.ibm.com> <20080930163324.44A7.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080930163324.44A7.E1E9C6FF@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Gary Hade <garyhade@us.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Nish Aravamudan <nish.aravamudan@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 30, 2008 at 05:06:08PM +0900, Yasunori Goto wrote:
> 
> > +#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
> > +int register_mem_sect_under_node(struct memory_block *mem_blk)
>         :
> 
> I think this patch is convenience even when memory hotplug is disabled.
> CONFIG_SPARSEMEM seems better than CONFIG_MEMORY_HOTPLUG_SPARSE.

Yes, this would be nice but unfortunately the presence of the
memory section directories that are referenced by the symlinks
also depend on CONFIG_MEMORY_HOTPLUG_SPARSE being enabled.  Removal
of the memory hotplug dependency for the code in drivers/base/memory.c
will require more than a simple CONFIG_MEMORY_HOTPLUG_SPARSE to
CONFIG_SPARSEMEM dependency change.  I am still looking at this.

Thanks for the review and testing.

Gary

-- 
Gary Hade
System x Enablement
IBM Linux Technology Center
503-578-4503  IBM T/L: 775-4503
garyhade@us.ibm.com
http://www.ibm.com/linux/ltc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
