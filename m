Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 529326B0069
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 16:07:58 -0500 (EST)
Received: by ggnq1 with SMTP id q1so5630779ggn.14
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 13:07:54 -0800 (PST)
Date: Tue, 15 Nov 2011 13:07:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
In-Reply-To: <20111115132513.GF27150@suse.de>
Message-ID: <alpine.DEB.2.00.1111151303230.23579@chino.kir.corp.google.com>
References: <20111110100616.GD3083@suse.de> <20111110142202.GE3083@suse.de> <CAEwNFnCRCxrru5rBk7FpypqeL8nD=SY5W3-TaA7Ap5o4CgDSbg@mail.gmail.com> <20111110161331.GG3083@suse.de> <20111110151211.523fa185.akpm@linux-foundation.org>
 <alpine.DEB.2.00.1111101536330.2194@chino.kir.corp.google.com> <20111111101414.GJ3083@suse.de> <20111114154408.10de1bc7.akpm@linux-foundation.org> <20111115132513.GF27150@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 15 Nov 2011, Mel Gorman wrote:

> Fine control is limited. If it is really needed, I would not oppose
> a patch that allows the use of sync compaction via a new setting in
> /sys/kernel/mm/transparent_hugepage/defrag. However, I think it is
> a slippery slope to expose implementation details like this and I'm
> not currently planning to implement such a patch.
> 

This doesn't expose any implementation detail, the "defrag" tunable is 
supposed to limit defragmentation efforts in the VM if the hugepages 
aren't immediately available and simply fallback to using small pages.  
Given that definition, it would make sense to allow for synchronous 
defragmentation (i.e. sync_compaction) on the second iteration of the page 
allocator slowpath if set.  So where's the disconnect between this 
proposed behavior and the definition of the tunable in 
Documentation/vm/transhuge.txt?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
