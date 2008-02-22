Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1M8gQd1002301
	for <linux-mm@kvack.org>; Fri, 22 Feb 2008 03:42:26 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1M8gQYW1080546
	for <linux-mm@kvack.org>; Fri, 22 Feb 2008 03:42:26 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1M8gPKg030279
	for <linux-mm@kvack.org>; Fri, 22 Feb 2008 03:42:25 -0500
Subject: Re: [LTP] [PATCH 1/8] Scaling msgmni to the amount of lowmem
From: Subrata Modak <subrata@linux.vnet.ibm.com>
Reply-To: subrata@linux.vnet.ibm.com
In-Reply-To: <47BE6AD0.6070309@bull.net>
References: <20080211141646.948191000@bull.net>
	 <20080211141813.354484000@bull.net>
	 <20080215215916.8566d337.akpm@linux-foundation.org>
	 <47B94D8C.8040605@bull.net>  <47B9835A.3060507@bull.net>
	 <1203411055.4612.5.camel@subratamodak.linux.ibm.com>
	 <47BB0EDC.5000002@bull.net>
	 <1203459418.7408.39.camel@localhost.localdomain>
	 <47BD705A.9020309@bull.net> <47BD7648.5010309@bull.net>
	 <1203601178.4604.18.camel@subratamodak.linux.ibm.com>
	 <47BE6AD0.6070309@bull.net>
Content-Type: text/plain
Date: Fri, 22 Feb 2008 14:11:26 +0530
Message-Id: <1203669686.4567.0.camel@subratamodak.linux.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nadia Derbey <Nadia.Derbey@bull.net>
Cc: Matt Helsley <matthltc@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, ltp-list@lists.sourceforge.net, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cmm@us.ibm.com, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Fri, 2008-02-22 at 07:25 +0100, Nadia Derbey wrote:
> Subrata Modak wrote:
> >>Nadia Derbey wrote:
> >>
> >>>Matt Helsley wrote:
> >>>
> >>>
> >>>>On Tue, 2008-02-19 at 18:16 +0100, Nadia Derbey wrote:
> >>>>
> >>>><snip>
> >>>>
> >>>>>+#define MAX_MSGQUEUES  16      /* MSGMNI as defined in linux/msg.h */
> >>>>>+
> >>>>
> >>>>
> >>>>
> >>>>It's not quite the maximum anymore, is it? More like the minumum
> >>>>maximum ;). A better name might better document what the test is
> >>>>actually trying to do.
> >>>>
> >>>>One question I have is whether the unpatched test is still valuable.
> >>>>Based on my limited knowledge of the test I suspect it's still a correct
> >>>>test of message queues. If so, perhaps renaming the old test (so it's
> >>>>not confused with a performance regression) and adding your patched
> >>>>version is best?
> >>>>
> >>>
> >>>So, here's the new patch based on Matt's points.
> >>>
> >>>Subrata, it has to be applied on top of the original ltp-full-20080131. 
> >>>Please tell me if you'd prefer one based on the merged version you've 
> >>>got (i.e. with my Tuesday patch applied).
> > 
> > 
> > Nadia, I would prefer Patch on the top of the already merged version (on
> > top of latest CVS snapshot as of today). Anyways, thanks for all these
> > effort :-)
> > 
> > --Subrata
> > 
> 
> In attachment, you'll find a patch to apply on top of the patches I sent 
> you on Tuesday.

Nadia,

Thanks a ton for that. The same has been merged.

Regards--
Subrata

> 
> Regards,
> Nadia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
