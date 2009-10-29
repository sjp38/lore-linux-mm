Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AF3EF6B0073
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 05:07:48 -0400 (EDT)
Date: Thu, 29 Oct 2009 10:07:41 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/2] Some fixes to debug_kmap_atomic()
Message-ID: <20091029090741.GC22963@elte.hu>
References: <ye84opj9zgs.fsf@camel23.daimi.au.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ye84opj9zgs.fsf@camel23.daimi.au.dk>
Sender: owner-linux-mm@kvack.org
To: Soeren Sandmann <sandmann@daimi.au.dk>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>


* Soeren Sandmann <sandmann@daimi.au.dk> wrote:

> Hi, 
> 
> Here are two patches that fix an issue with debug_kmap_atomic(). 

hm, have you seen this patch from Peter on lkml:

  [RFC][PATCH] kmap_atomic_push

which eliminates debug_kmap_atomic().

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
