Date: Tue, 15 Apr 2008 17:09:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Smarter retry of costly-order allocations
Message-Id: <20080415170902.4ec7aae5.akpm@linux-foundation.org>
In-Reply-To: <20080416000010.GF15840@us.ibm.com>
References: <20080411233500.GA19078@us.ibm.com>
	<20080411233553.GB19078@us.ibm.com>
	<20080415000745.9af1b269.akpm@linux-foundation.org>
	<20080415172614.GE15840@us.ibm.com>
	<20080415121834.0aa406c4.akpm@linux-foundation.org>
	<20080416000010.GF15840@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: mel@csn.ul.ie, clameter@sgi.com, apw@shadowen.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 15 Apr 2008 17:00:10 -0700
Nishanth Aravamudan <nacc@us.ibm.com> wrote:

> On 15.04.2008 [12:18:34 -0700], Andrew Morton wrote:
> > On Tue, 15 Apr 2008 10:26:14 -0700
> > Nishanth Aravamudan <nacc@us.ibm.com> wrote:
> > 
> > > > So... would like to see some firmer-looking testing results, please.
> > > 
> > > Do Mel's e-mails cover this sufficiently?
> > 
> > I guess so.
> > 
> > Could you please pull together a new set of changelogs sometime?
> 
> Will do it tomorrow, for sure.
> 
> > The big-picture change here is that we now use GFP_REPEAT for hugepages,
> > which makes the allocations work better.  But I assume that you hit some
> > problem with that which led you to reduce the amount of effort which
> > GFP_REPEAT will expend for larger pages, yes?
> > 
> > If so, a description of that problem would be appropriate as well.
> 
> Will add that, as well.
> 
> Would you like me to repost the patch with the new changelog and just
> ask you therein to drop and replace? Patches 1/3 and 3/3 should be
> unchanged.
> 

Sure, whatever, I'll work it out ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
