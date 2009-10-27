Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 42F7B6B0073
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:41:37 -0400 (EDT)
Message-ID: <4AE714A8.6010405@redhat.com>
Date: Tue, 27 Oct 2009 11:41:28 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: RFC: Transparent Hugepage support
References: <20091026185130.GC4868@random.random>
In-Reply-To: <20091026185130.GC4868@random.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 10/26/2009 02:51 PM, Andrea Arcangeli wrote:
> Hello,
>
> Lately I've been working to make KVM use hugepages transparently
> without the usual restrictions of hugetlbfs.

I believe your approach is the right one.

It would be interesting to see how much of a performance gain
is seen with real applications, though from hugetlbfs experience
we already know that some applications can see significant
performance gains from using large pages.

As for the code - this patch is a little too big to comment
on all the details individually, but most of the code looks
good.

It would be nice if some of the code duplication with hugetlbfs
could be removed and the patch could be turned into a series of
more reasonably sized patches before a merge.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
