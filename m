Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA2FnbGs019514
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 10:49:37 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jA2Foe1K531942
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 08:50:40 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jA2FnZmk029323
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 08:49:36 -0700
Subject: Re: [PATCH] 2.6.14 patch for supporting madvise(MADV_FREE)
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20051102014321.GG24051@opteron.random>
References: <1130366995.23729.38.camel@localhost.localdomain>
	 <20051028034616.GA14511@ccure.user-mode-linux.org>
	 <43624F82.6080003@us.ibm.com>
	 <20051028184235.GC8514@ccure.user-mode-linux.org>
	 <1130544201.23729.167.camel@localhost.localdomain>
	 <20051029025119.GA14998@ccure.user-mode-linux.org>
	 <1130788176.24503.19.camel@localhost.localdomain>
	 <20051101000509.GA11847@ccure.user-mode-linux.org>
	 <1130894101.24503.64.camel@localhost.localdomain>
	 <20051102014321.GG24051@opteron.random>
Content-Type: text/plain
Date: Wed, 02 Nov 2005 07:49:12 -0800
Message-Id: <1130946552.24503.66.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: lkml <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>, Blaisorblade <blaisorblade@yahoo.it>, Jeff Dike <jdike@addtoit.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-11-02 at 02:43 +0100, Andrea Arcangeli wrote:
> On Tue, Nov 01, 2005 at 05:15:01PM -0800, Badari Pulavarty wrote:
> > Here is the patch to support madvise(MADV_FREE) - which frees 
> > up the given range of pages and truncates the underlying backing 
> > store. This basically provides "punch hole into file" functionality.
> > Currently it supports ONLY shmfs/tmpfs - where we have short term 
> > need. Other filesystems return -ENOSYS.
> 
> MADV_FREE as a name isn't right if we return -ENOSYS for anonymoys
> memory.
> 
> MADV_FREE in other OS works _only_ on anonymous memory and returns
> -EINVAL if used on filebacked vmas. Infact we probably should rename our
> MADV_DONTNEED to MADV_FREE.
> 
> http://docs.sun.com/app/docs/doc/816-5168/6mbb3hrde?a=view
> 
> 	"This value cannot be used on mappings that have underlying file objects."
> 
> Our MADV_DONTNEED exactly matches the MADV_FREE semantics, and it seems
> the MADV_DONTNEED of other OS isn't destructive like ours. Except our
> MADV_DONTNEED also works on filebacked mappings but it's destructive
> only on anonymous memory.
> 
> 
> I thought Andrew suggested MADV_REMOVE for the new feature.

Yep. My bad. Andrew did suggest MADV_REMOVE. Let me rename and
generate patch once again !! Thanks for pointing out.

> 
> This feature didn't exist in other OS yet AFIK, so a new MADV_name for
> it makes sense. I'm not completely against extending MADV_FREE but then we
> shouldn't return -ENOSYS on anonymous memory and we should do the same
> thing MADV_DONTNEED does on anonymous memory. Probably a new name is
> safer to avoid confusion (think an application running MADV_FREE and
> expecting -EINVAL when used on filebacked mappings).
> 
> Thanks!
> 

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
