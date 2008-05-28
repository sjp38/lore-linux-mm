Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4SEZSfD021097
	for <linux-mm@kvack.org>; Wed, 28 May 2008 10:35:28 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4SEZSe6152606
	for <linux-mm@kvack.org>; Wed, 28 May 2008 10:35:28 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4SEZR7n011209
	for <linux-mm@kvack.org>; Wed, 28 May 2008 10:35:27 -0400
Subject: Re: [patch 12/23] hugetlb: support boot allocate different sizes
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080528140106.GJ2630@wotan.suse.de>
References: <20080525142317.965503000@nick.local0.net>
	 <20080525143453.424711000@nick.local0.net>
	 <1211923735.12036.41.camel@localhost.localdomain>
	 <20080528105759.GG2630@wotan.suse.de> <20080528140106.GJ2630@wotan.suse.de>
Content-Type: text/plain
Date: Wed, 28 May 2008 09:35:28 -0500
Message-Id: <1211985328.12036.61.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-05-28 at 16:01 +0200, Nick Piggin wrote:
> On Wed, May 28, 2008 at 12:57:59PM +0200, Nick Piggin wrote:
> > On Tue, May 27, 2008 at 04:28:55PM -0500, Adam Litke wrote:
> > > Seems nice, but what exactly is this patch for?  From reading the code
> > > it would seem that this allows more than one >MAX_ORDER hstates to exist
> > > and removes assumptions about their positioning withing the hstates
> > > array?  A small patch leader would definitely clear up my confusion.
> > 
> > Yes it allows I guess hugetlb_init_one_hstate to be called multiple
> > times on an hstate, and also some logic dealing with giant page setup.
> > 
> > Though hmm, possibly it can be made a little cleaner by separating
> > hstate init from the actual page allocation a little more. I'll have
> > a look but it is kind of tricky... otherwise I can try a changelog.
> 
> This is how I've made the patch:

Thanks.  That's a lot clearer to me.

Acked-by: Adam Litke <agl@us.ibm.com>

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
