Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 9ABF76B005D
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 19:27:49 -0400 (EDT)
Date: Tue, 19 Jun 2012 16:27:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm 4/7] mm: make page colouring code generic
Message-Id: <20120619162747.fa31c86a.akpm@linux-foundation.org>
In-Reply-To: <1340057126-31143-5-git-send-email-riel@redhat.com>
References: <1340057126-31143-1-git-send-email-riel@redhat.com>
	<1340057126-31143-5-git-send-email-riel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, aarcange@redhat.com, peterz@infradead.org, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On Mon, 18 Jun 2012 18:05:23 -0400
Rik van Riel <riel@redhat.com> wrote:

> From: Rik van Riel <riel@surriel.com>
> 
> Fix the x86-64 page colouring code to take pgoff into account.

Could we please have a full description of what's wrong with the
current code?

> Use the x86 and MIPS page colouring code as the basis for a generic
> page colouring function.
> 
> Teach the generic arch_get_unmapped_area(_topdown) code to call the
> page colouring code.
> 
> Make sure that ALIGN_DOWN always aligns down, and ends up at the
> right page colour.

Some performance tests on the result would be interesting.  iirc, we've
often had trouble demonstrating much or any benefit from coloring.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
