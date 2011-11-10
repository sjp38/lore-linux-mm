Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 712706B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 10:00:20 -0500 (EST)
Date: Thu, 10 Nov 2011 09:00:16 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm,slub,x86: decouple size of struct page from
 CONFIG_CMPXCHG_LOCAL
In-Reply-To: <1320933860-15588-2-git-send-email-heiko.carstens@de.ibm.com>
Message-ID: <alpine.DEB.2.00.1111100900010.19196@router.home>
References: <1320933860-15588-1-git-send-email-heiko.carstens@de.ibm.com> <1320933860-15588-2-git-send-email-heiko.carstens@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 10 Nov 2011, Heiko Carstens wrote:

> If an architecture supports CMPXCHG_LOCAL this shouldn't result automatically
> in larger struct pages if the SLUB allocator is used. Instead introduce a new
> config option "HAVE_ALIGNED_STRUCT_PAGE" which can be selected if a double
> word aligned struct page is required.
> Also update x86 Kconfig so that it should work as before.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
