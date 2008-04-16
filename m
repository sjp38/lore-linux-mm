Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3G00C0O007850
	for <linux-mm@kvack.org>; Tue, 15 Apr 2008 20:00:12 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3G00CaV250342
	for <linux-mm@kvack.org>; Tue, 15 Apr 2008 20:00:12 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3G00BfE027215
	for <linux-mm@kvack.org>; Tue, 15 Apr 2008 20:00:12 -0400
Date: Tue, 15 Apr 2008 17:00:10 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] Smarter retry of costly-order allocations
Message-ID: <20080416000010.GF15840@us.ibm.com>
References: <20080411233500.GA19078@us.ibm.com> <20080411233553.GB19078@us.ibm.com> <20080415000745.9af1b269.akpm@linux-foundation.org> <20080415172614.GE15840@us.ibm.com> <20080415121834.0aa406c4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080415121834.0aa406c4.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mel@csn.ul.ie, clameter@sgi.com, apw@shadowen.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 15.04.2008 [12:18:34 -0700], Andrew Morton wrote:
> On Tue, 15 Apr 2008 10:26:14 -0700
> Nishanth Aravamudan <nacc@us.ibm.com> wrote:
> 
> > > So... would like to see some firmer-looking testing results, please.
> > 
> > Do Mel's e-mails cover this sufficiently?
> 
> I guess so.
> 
> Could you please pull together a new set of changelogs sometime?

Will do it tomorrow, for sure.

> The big-picture change here is that we now use GFP_REPEAT for hugepages,
> which makes the allocations work better.  But I assume that you hit some
> problem with that which led you to reduce the amount of effort which
> GFP_REPEAT will expend for larger pages, yes?
> 
> If so, a description of that problem would be appropriate as well.

Will add that, as well.

Would you like me to repost the patch with the new changelog and just
ask you therein to drop and replace? Patches 1/3 and 3/3 should be
unchanged.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
