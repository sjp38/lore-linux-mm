Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id AA9236B0044
	for <linux-mm@kvack.org>; Sun,  5 Aug 2012 21:28:01 -0400 (EDT)
Message-ID: <501F1D86.7020409@redhat.com>
Date: Sun, 05 Aug 2012 21:27:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/9] rbtree: handle 1-child recoloring in rb_erase()
 instead of rb_erase_color()
References: <1343946858-8170-1-git-send-email-walken@google.com> <1343946858-8170-6-git-send-email-walken@google.com>
In-Reply-To: <1343946858-8170-6-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

On 08/02/2012 06:34 PM, Michel Lespinasse wrote:
> An interesting observation for rb_erase() is that when a node has
> exactly one child, the node must be black and the child must be red.
> An interesting consequence is that removing such a node can be done by
> simply replacing it with its child and making the child black,
> which we can do efficiently in rb_erase(). __rb_erase_color() then
> only needs to handle the no-childs case and can be modified accordingly.
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
