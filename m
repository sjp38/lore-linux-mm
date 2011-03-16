Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 299318D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 11:55:14 -0400 (EDT)
Date: Wed, 16 Mar 2011 08:51:04 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH]x86: flush tlb if PGD entry is changed in i386
 PAE mode
Message-ID: <20110316155104.GA25008@kroah.com>
References: <1300246649.2337.95.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1300246649.2337.95.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, "Mallick, Asit K" <asit.k.mallick@intel.com>, stable <stable@kernel.org>, y-goto@jp.fujitsu.com, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Mar 16, 2011 at 11:37:29AM +0800, Shaohua Li wrote:
> According to intel CPU manual, every time PGD entry is changed in i386 PAE mode,
> we need do a full TLB flush. Current code follows this and there is comment
> for this too in the code. But current code misses the multi-threaded case. A
> changed page table might be used by several CPUs, every such CPU should flush
> TLB.
> Usually this isn't a problem, because we prepopulate all PGD entries at process
> fork. But when the process does munmap and follows new mmap, this issue will be
> triggered. When it happens, some CPUs will keep doing page fault.
> 
> See: http://marc.info/?l=linux-kernel&m=129915020508238&w=2
> 
> Reported-by: Yasunori Goto<y-goto@jp.fujitsu.com>
> Signed-off-by: Shaohua Li<shaohua.li@intel.com>
> Tested-by: Yasunori Goto<y-goto@jp.fujitsu.com>

This is not how you submit something to the stable kernel tree.  Please
go read Documentation/stable_kernel_rules.txt for how to do it properly.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
