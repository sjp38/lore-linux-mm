Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id E45126B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 12:30:29 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH -mm 3/6] Fix the x86-64 page colouring code to take pgoff into account and use that code as the basis for a generic page colouring code.
References: <1340029878-7966-1-git-send-email-riel@redhat.com>
	<1340029878-7966-4-git-send-email-riel@redhat.com>
Date: Mon, 18 Jun 2012 09:30:28 -0700
In-Reply-To: <1340029878-7966-4-git-send-email-riel@redhat.com> (Rik van
	Riel's message of "Mon, 18 Jun 2012 10:31:15 -0400")
Message-ID: <m2k3z48twb.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, hnaz@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

Rik van Riel <riel@redhat.com> writes:

> From: Rik van Riel <riel@surriel.com>
>
> Teach the generic arch_get_unmapped_area(_topdown) code to call the
> page colouring code.

What tree is that against? I cannot find x86 page colouring code in next
or mainline.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
