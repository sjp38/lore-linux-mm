Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k44G83kL013194
	for <linux-mm@kvack.org>; Thu, 4 May 2006 12:08:03 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k44G83Rc216630
	for <linux-mm@kvack.org>; Thu, 4 May 2006 10:08:03 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k44G82vE009002
	for <linux-mm@kvack.org>; Thu, 4 May 2006 10:08:03 -0600
Subject: Re: assert/crash in __rmqueue() when enabling CONFIG_NUMA
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060504154652.GA4530@localhost>
References: <20060419112130.GA22648@elte.hu> <p73aca07whs.fsf@bragg.suse.de>
	 <20060502070618.GA10749@elte.hu> <200605020905.29400.ak@suse.de>
	 <44576688.6050607@mbligh.org> <44576BF5.8070903@yahoo.com.au>
	 <20060504013239.GG19859@localhost>
	 <1146756066.22503.17.camel@localhost.localdomain>
	 <20060504154652.GA4530@localhost>
Content-Type: text/plain
Date: Thu, 04 May 2006 09:07:09 -0700
Message-Id: <1146758829.22503.21.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bob Picco <bob.picco@hp.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-05-04 at 11:46 -0400, Bob Picco wrote:
> Dave Hansen wrote:	[Thu May 04 2006, 11:21:06AM EDT]
> > I haven't thought through it completely, but these two lines worry me:
> > 
> > > + start = pgdat->node_start_pfn & ~((1 << (MAX_ORDER - 1)) - 1);
> > > + end = start + pgdat->node_spanned_pages;
> > 
> > Should the "end" be based off of the original "start", or the aligned
> > "start"?
> Yes. I failed to quilt refresh before sending. You mean end should be
> end = pgdat->node_start_pfn + pgdat->node_spanned_pages before rounding
> up.

Yep.  Looks good.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
