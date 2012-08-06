Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id B6FA56B0044
	for <linux-mm@kvack.org>; Sun,  5 Aug 2012 22:13:00 -0400 (EDT)
Message-ID: <501F2812.70303@redhat.com>
Date: Sun, 05 Aug 2012 22:12:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 8/9] rbtree: faster augmented rbtree manipulation
References: <1343946858-8170-1-git-send-email-walken@google.com> <1343946858-8170-9-git-send-email-walken@google.com>
In-Reply-To: <1343946858-8170-9-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On 08/02/2012 06:34 PM, Michel Lespinasse wrote:
> Introduce new augmented rbtree APIs that allow minimal recalculation of
> augmented node information.
>
> A new callback is added to the rbtree insertion and erase rebalancing
> functions, to be called on each tree rotations. Such rotations preserve
> the subtree's root augmented value, but require recalculation of the one
> child that was previously located at the subtree root.
>
> In the insertion case, the handcoded search phase must be updated to
> maintain the augmented information on insertion, and then the rbtree
> coloring/rebalancing algorithms keep it up to date.
>
> In the erase case, things are more complicated since it is library
> code that manipulates the rbtree in order to remove internal nodes.
> This requires a couple additional callbacks to copy a subtree's
> augmented value when a new root is stitched in, and to recompute
> augmented values down the ancestry path when a node is removed from
> the tree.
>
> In order to preserve maximum speed for the non-augmented case,
> we provide two versions of each tree manipulation function.
> rb_insert_augmented() is the augmented equivalent of rb_insert_color(),
> and rb_erase_augmented() is the augmented equivalent of rb_erase().
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
