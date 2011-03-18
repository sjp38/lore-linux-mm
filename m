Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 006228D0039
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 22:19:11 -0400 (EDT)
Subject: Re: [PATCH]x86: flush tlb if PGD entry is changed in i386 PAE mode
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <4D80B514.3030409@redhat.com>
References: <1300246649.2337.95.camel@sli10-conroe>
	 <4D80B514.3030409@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 18 Mar 2011 10:19:08 +0800
Message-ID: <1300414748.2337.137.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, "Mallick, Asit K" <asit.k.mallick@intel.com>

On Wed, 2011-03-16 at 21:03 +0800, Rik van Riel wrote:
> On 03/15/2011 11:37 PM, Shaohua Li wrote:
> > According to intel CPU manual, every time PGD entry is changed in i386 PAE mode,
> > we need do a full TLB flush. Current code follows this and there is comment
> > for this too in the code. But current code misses the multi-threaded case. A
> > changed page table might be used by several CPUs, every such CPU should flush
> > TLB.
> > Usually this isn't a problem, because we prepopulate all PGD entries at process
> > fork. But when the process does munmap and follows new mmap, this issue will be
> > triggered. When it happens, some CPUs will keep doing page fault.
> >
> > See: http://marc.info/?l=linux-kernel&m=129915020508238&w=2
> >
> > Reported-by: Yasunori Goto<y-goto@jp.fujitsu.com>
> > Signed-off-by: Shaohua Li<shaohua.li@intel.com>
> > Tested-by: Yasunori Goto<y-goto@jp.fujitsu.com>
> 
> Reviewed-by: Rik van Riel <riel@redhat.com>
Ingo & akpm,
can you pick this one?

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
