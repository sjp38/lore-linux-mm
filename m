Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 234536B0044
	for <linux-mm@kvack.org>; Sun,  5 Aug 2012 22:15:35 -0400 (EDT)
Message-ID: <501F20BC.2030107@redhat.com>
Date: Sun, 05 Aug 2012 21:41:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 6/9] rbtree: low level optimizations in rb_erase()
References: <1343946858-8170-1-git-send-email-walken@google.com> <1343946858-8170-7-git-send-email-walken@google.com>
In-Reply-To: <1343946858-8170-7-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On 08/02/2012 06:34 PM, Michel Lespinasse wrote:
> Various minor optimizations in rb_erase():
> - Avoid multiple loading of node->__rb_parent_color when computing parent
>    and color information (possibly not in close sequence, as there might
>    be further branches in the algorithm)
> - In the 1-child subcase of case 1, copy the __rb_parent_color field from
>    the erased node to the child instead of recomputing it from the desired
>    parent and color
> - When searching for the erased node's successor, differentiate between
>    cases 2 and 3 based on whether any left links were followed. This avoids
>    a condition later down.
> - In case 3, keep a pointer to the erased node's right child so we don't
>    have to refetch it later to adjust its parent.
> - In the no-childs subcase of cases 2 and 3, place the rebalance assigment
>    last so that the compiler can remove the following if(rebalance) test.
>
> Also, added some comments to illustrate cases 2 and 3.
>
> Signed-off-by: Michel Lespinasse<walken@google.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
