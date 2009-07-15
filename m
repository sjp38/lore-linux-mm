Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C50B26B006A
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 15:55:47 -0400 (EDT)
Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id n6FJtnSg024273
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 12:55:50 -0700
Received: from pxi6 (pxi6.prod.google.com [10.243.27.6])
	by zps35.corp.google.com with ESMTP id n6FJtk9C024383
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 12:55:47 -0700
Received: by pxi6 with SMTP id 6so1218025pxi.29
        for <linux-mm@kvack.org>; Wed, 15 Jul 2009 12:55:45 -0700 (PDT)
Date: Wed, 15 Jul 2009 12:55:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] page-allocator: Allow too high-order warning messages
 to be suppressed with __GFP_NOWARN
In-Reply-To: <1247656992-19846-2-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.0907151255290.20452@chino.kir.corp.google.com>
References: <1247656992-19846-1-git-send-email-mel@csn.ul.ie> <1247656992-19846-2-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Heinz Diehl <htd@fancy-poultry.org>, David Miller <davem@davemloft.net>, Arnaldo Carvalho de Melo <acme@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Jul 2009, Mel Gorman wrote:

> The page allocator warns once when an order >= MAX_ORDER is specified.
> This is to catch callers of the allocator that are always falling back
> to their worst-case when it was not expected. However, there are cases
> where the caller is behaving correctly but cannot suppress the warning.
> This patch allows the warning to be suppressed by the callers by
> specifying __GFP_NOWARN.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
