Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D0B246B016D
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 16:49:42 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p9DKneGH012795
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 13:49:40 -0700
Received: from pzk34 (pzk34.prod.google.com [10.243.19.162])
	by hpaq1.eem.corp.google.com with ESMTP id p9DKjHfs016557
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 13:49:38 -0700
Received: by pzk34 with SMTP id 34so4986212pzk.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2011 13:49:38 -0700 (PDT)
Date: Thu, 13 Oct 2011 13:49:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: add a "struct page_frag" type containing a page,
 offset and length
In-Reply-To: <20111013.163708.1319779926961023813.davem@davemloft.net>
Message-ID: <alpine.DEB.2.00.1110131348310.24853@chino.kir.corp.google.com>
References: <1318500176-10728-1-git-send-email-ian.campbell@citrix.com> <alpine.DEB.2.00.1110131327470.24853@chino.kir.corp.google.com> <20111013.163708.1319779926961023813.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>
Cc: ian.campbell@citrix.com, linux-kernel@vger.kernel.org, hch@infradead.org, jaxboe@fusionio.com, linux-mm@kvack.org

On Thu, 13 Oct 2011, David Miller wrote:

> >> A few network drivers currently use skb_frag_struct for this purpose but I have
> >> patches which add additional fields and semantics there which these other uses
> >> do not want.
> >> 
> > 
> > Is this patch a part of a larger series that actually uses 
> > struct page_frag?  Probably a good idea to post them so we know it doesn't 
> > just lie there dormant.
> 
> See:
> 
> http://patchwork.ozlabs.org/patch/118693/
> http://patchwork.ozlabs.org/patch/118694/
> http://patchwork.ozlabs.org/patch/118695/
> http://patchwork.ozlabs.org/patch/118700/
> http://patchwork.ozlabs.org/patch/118696/
> http://patchwork.ozlabs.org/patch/118699/
> 
> This is a replacement for patch #1 in that series.
> 

Ok, let's add Andrew to the thread so this can go through -mm in 
preparation for that series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
