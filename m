Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 6EAE46B004D
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 22:20:15 -0400 (EDT)
Date: Fri, 16 Oct 2009 10:20:11 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RESEND][PATCH V1] mm/vsmcan: check shrink_active_list()
	sc->isolate_pages() return value.
Message-ID: <20091016022011.GA22706@localhost>
References: <20090903140602.e0169ffc.akpm@linux-foundation.org> <alpine.DEB.2.00.0909031458160.5762@kernelhack.brc.ubc.ca> <20090903154704.da62dd76.akpm@linux-foundation.org> <alpine.DEB.2.00.0909041431370.32680@kernelhack.brc.ubc.ca> <20090904165305.c19429ce.akpm@linux-foundation.org> <20090908132100.GA17446@csn.ul.ie> <alpine.DEB.2.00.0909081516550.3524@kernelhack.brc.ubc.ca> <20090909082759.7144aaa5.minchan.kim@barrios-desktop> <alpine.DEB.2.00.0910151507260.2882@kernalhack.brc.ubc.ca> <20091016111041.6ffc59c9.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091016111041.6ffc59c9.minchan.kim@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Vincent Li <root@brc.ubc.ca>, Vincent Li <macli@brc.ubc.ca>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "riel@redhat.com" <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 16, 2009 at 10:10:41AM +0800, Minchan Kim wrote:
> Hi, Vicent. 
> First of all, Thanks for your effort. :)
 
That's pretty serious efforts ;)

> But as your data said, on usual case, nr_taken_zero count is much less 
> than non_zero. so we could lost benefit in normal case due to compare
> insturction although it's trivial. 
> 
> I have no objection in this patch since overhead is not so big.
> But I am not sure what other guys think about it. 
> 
> How about adding unlikely following as ?
> 
> +
> +       if (unlikely(nr_taken == 0))
> +               goto done;

I would prefer to just remove it - to make the code simple :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
