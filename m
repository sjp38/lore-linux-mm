Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 034856B01F0
	for <linux-mm@kvack.org>; Fri, 23 Apr 2010 00:55:21 -0400 (EDT)
Received: by iwn40 with SMTP id 40so830564iwn.1
        for <linux-mm@kvack.org>; Thu, 22 Apr 2010 21:55:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1004221009150.32107@router.home>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
	 <20100421153421.GM30306@csn.ul.ie>
	 <alpine.DEB.2.00.1004211038020.4959@router.home>
	 <20100422092819.GR30306@csn.ul.ie>
	 <20100422184621.0aaaeb5f.kamezawa.hiroyu@jp.fujitsu.com>
	 <x2l28c262361004220313q76752366l929a8959cd6d6862@mail.gmail.com>
	 <20100422193106.9ffad4ec.kamezawa.hiroyu@jp.fujitsu.com>
	 <20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com>
	 <1271946226.2100.211.camel@barrios-desktop>
	 <alpine.DEB.2.00.1004221009150.32107@router.home>
Date: Fri, 23 Apr 2010 13:55:19 +0900
Message-ID: <x2i28c262361004222155w354632eq636186639ac445b7@mail.gmail.com>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of PageSwapCache
	pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Christoph.

On Fri, Apr 23, 2010 at 12:14 AM, Christoph Lameter <cl@linux.com> wrote:
> On Thu, 22 Apr 2010, Minchan Kim wrote:
>
>> For further optimization, we can hold vma->adjust_lock if vma_address
>> returns -EFAULT. But I hope we redesigns it without new locking.
>> But I don't have good idea, now. :(
>
> You could make it atomic through the use of RCU.
>
> Create a new vma entry with the changed parameters and then atomically
> switch to the new vma.
> Problem is that you have some list_heads in there.

That's a good idea if we can do _simply_.
That's because there are many confusion anon_vma and vma handling nowadays.
(http://thread.gmane.org/gmane.linux.kernel/969907)
So I hope we solve the problem without rather complicated rcu locking
if it isn't critical path.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
