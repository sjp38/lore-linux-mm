Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B25AD6B004D
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 10:33:42 -0400 (EDT)
Subject: Re: [PATCH 0/2] Some fixes to debug_kmap_atomic()
References: <ye84opj9zgs.fsf@camel23.daimi.au.dk>
	<20091029090741.GC22963@elte.hu>
From: Soeren Sandmann <sandmann@daimi.au.dk>
Date: 29 Oct 2009 15:33:39 +0100
In-Reply-To: <20091029090741.GC22963@elte.hu>
Message-ID: <ye83a522rss.fsf@camel27.daimi.au.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Ingo Molnar <mingo@elte.hu> writes:

> hm, have you seen this patch from Peter on lkml:
> 
>   [RFC][PATCH] kmap_atomic_push
> 
> which eliminates debug_kmap_atomic().

I hadn't; that would work as well, though fixing the infinite stream
of warning is maybe embarrassing enough that it should be in 2.6.32?


Soren

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
