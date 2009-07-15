Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 97AA36B004F
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 09:17:42 -0400 (EDT)
Date: Wed, 15 Jul 2009 10:56:30 -0300
From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 3/3] net-dccp: Suppress warning about large allocations
	from DCCP
Message-ID: <20090715135630.GC19645@ghostprotocols.net>
References: <1247656992-19846-1-git-send-email-mel@csn.ul.ie> <1247656992-19846-4-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1247656992-19846-4-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Heinz Diehl <htd@fancy-poultry.org>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

Em Wed, Jul 15, 2009 at 12:23:12PM +0100, Mel Gorman escreveu:
> The DCCP protocol tries to allocate some large hash tables during
> initialisation using the largest size possible.  This can be larger than
> what the page allocator can provide so it prints a warning. However, the
> caller is able to handle the situation so this patch suppresses the warning.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Thanks again,

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
