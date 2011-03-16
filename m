Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 973F58D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 09:04:13 -0400 (EDT)
Message-ID: <4D80B514.3030409@redhat.com>
Date: Wed, 16 Mar 2011 09:03:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH]x86: flush tlb if PGD entry is changed in i386 PAE mode
References: <1300246649.2337.95.camel@sli10-conroe>
In-Reply-To: <1300246649.2337.95.camel@sli10-conroe>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, y-goto@jp.fujitsu.com, "Mallick, Asit K" <asit.k.mallick@intel.com>, stable <stable@kernel.org>

On 03/15/2011 11:37 PM, Shaohua Li wrote:
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

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
