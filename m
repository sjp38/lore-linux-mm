Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 4A88B6B0070
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 03:16:22 -0400 (EDT)
Date: Wed, 7 Aug 2013 16:16:24 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/4] mm, rmap: do easy-job first in anon_vma_fork
Message-ID: <20130807071624.GA32449@lge.com>
References: <1375778620-31593-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20130806125854.GG1845@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130806125854.GG1845@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>

Hello, Johannes.

On Tue, Aug 06, 2013 at 08:58:54AM -0400, Johannes Weiner wrote:
> >  	if (anon_vma_clone(vma, pvma))
> > -		return -ENOMEM;
> > -
> > -	/* Then add our own anon_vma. */
> > -	anon_vma = anon_vma_alloc();
> > -	if (!anon_vma)
> > -		goto out_error;
> > -	avc = anon_vma_chain_alloc(GFP_KERNEL);
> > -	if (!avc)
> >  		goto out_error_free_anon_vma;
> 
> Which heavy work?  anon_vma_clone() is anon_vma_chain_alloc() in a
> loop.
> 
> Optimizing error paths only makes sense if they are common and you
> actually could save something by reordering.  This matches neither.

Yes, you are right. I drop this one.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
