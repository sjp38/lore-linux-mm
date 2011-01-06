Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 88A196B0088
	for <linux-mm@kvack.org>; Thu,  6 Jan 2011 05:46:35 -0500 (EST)
Date: Thu, 6 Jan 2011 10:46:12 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: CLOCK-Pro algorithm
Message-ID: <20110106104611.GF29257@csn.ul.ie>
References: <AANLkTikrPWqH1tiG4Hx8eg09+Sn_cJ=EMbBVWrSabCF1@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <AANLkTikrPWqH1tiG4Hx8eg09+Sn_cJ=EMbBVWrSabCF1@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Adrian McMenamin <lkmladrian@gmail.com>
Cc: linux-mm@kvack.org, Adrian McMenamin <adrianmcmenamin@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 30, 2010 at 11:24:00PM +0000, Adrian McMenamin wrote:
> I originally tried to send this to the addresses for Song Jiang, Feng
> Chen and Xiaodong Zhang on the USENIX paper but it bounced from all of
> them. So I hope you will indulge me if I send it to the list in the
> hope it might reach them. Or perhaps someone here could answer the
> questions below.
> 
> Many thanks
> 
> Adrian
> 
> Dear all,
> 
> I am just beginning work on an MSc project on Linux memory management
> and have been reading your paper to the 2005 USENIX Annual Technical
> Conference. I was wondering what the current status of this algorithm
> is as regards the Linux kernel.
> 
> I can find this: http://linux-mm.org/ClockProApproximation and patches
> for testing with the 2.6.12 kernel but am not entirely clear as to
> whether this algorithm was included: certainly all the books I have
> read still talk of the LRU lists that are similar to the 2Q model.
> 

The current reclaim algorithm is a mash of a number of different
algorithms with a number of modifications for catching corner cases and
various optimisations. In terms of an MSc, your best bet is to do a
general literature review of replacement algorithms and then do your
best to write a short paper describing the Linux page replacement
algorithm identifying which replacement algorithms it takes lessons
from.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
