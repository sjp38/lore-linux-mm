Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 218D86B00CC
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 17:04:07 -0400 (EDT)
Received: from spaceape24.eur.corp.google.com (spaceape24.eur.corp.google.com [172.28.16.76])
	by smtp-out.google.com with ESMTP id n3RL47FZ000345
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 22:04:07 +0100
Received: from wa-out-1112.google.com (wafm16.prod.google.com [10.114.189.16])
	by spaceape24.eur.corp.google.com with ESMTP id n3RL45Lp018523
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 14:04:05 -0700
Received: by wa-out-1112.google.com with SMTP id m16so64991waf.6
        for <linux-mm@kvack.org>; Mon, 27 Apr 2009 14:04:04 -0700 (PDT)
Date: Mon, 27 Apr 2009 14:04:03 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] Replace the watermark-related union in struct zone with
 a watermark[] array
In-Reply-To: <20090427205400.GA23510@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.0904271400450.11972@chino.kir.corp.google.com>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-19-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.0904221251350.14558@chino.kir.corp.google.com> <20090427170054.GE912@csn.ul.ie> <alpine.DEB.2.00.0904271340320.11972@chino.kir.corp.google.com>
 <20090427205400.GA23510@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Apr 2009, Mel Gorman wrote:

> > I thought the suggestion was for something like
> > 
> > 	#define zone_wmark_min(z)	(z->pages_mark[WMARK_MIN])
> > 	...
> 
> Was it the only suggestion? I thought just replacing the union with an
> array would be an option as well.
> 
> The #define approach also requires setter versions like
> 
> static inline set_zone_wmark_min(struct zone *z, unsigned long val)
> {
> 	z->pages_mark[WMARK_MIN] = val;
> }
> 
> and you need one of those for each watermark if you are to avoid weirdness like
> 
> zone_wmark_min(z) = val;
> 
> which looks all wrong.

Agreed, but we only set watermarks in a couple of different locations and 
they really have no reason to change otherwise, so I don't think it's 
necessary to care too much about how the setter looks.

Adding individual get/set functions for each watermark seems like 
overkill.

I personally had no problem with the union struct aliasing the array, I 
think ->pages_min, ->pages_low, etc. are already very familiar.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
