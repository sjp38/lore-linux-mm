Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 0E97B6B004A
	for <linux-mm@kvack.org>; Fri,  6 Apr 2012 17:14:46 -0400 (EDT)
Message-ID: <4F7F5CC1.3080107@redhat.com>
Date: Fri, 06 Apr 2012 17:14:41 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix page-faults detection in swap-token logic
References: <20110827083201.21854.56111.stgit@zurg> <20110829160637.bfc86e63.akpm@linux-foundation.org>
In-Reply-To: <20110829160637.bfc86e63.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/29/2011 07:06 PM, Andrew Morton wrote:
> On Sat, 27 Aug 2011 12:32:01 +0300
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> After commit v2.6.36-5896-gd065bd8 "mm: retry page fault when blocking on disk transfer"
>> we usually wait in page-faults without mmap_sem held, so all swap-token logic was broken,
>> because it based on using rwsem_is_locked(&mm->mmap_sem) as sign of in progress page-faults.
>
> If I'm interpreting this correctly, the thrash-handling logic has been
> effectively disabled for a year and nobody noticed.
>
>> This patch adds to mm_struct atomic counter of in progress page-faults for mm with swap-token.
>
> We desperately need to delete some code from mm/.  This seems like a
> great candidate.  Someone prove me wrong?

You are absolutely right.  The swap token code broke without
anyone noticing, and there is no good way to integrate it with
cgroups naturalization...

I'll send a patch to remove the swap token code.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
