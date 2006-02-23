Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k1NHegs1028747
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 12:40:43 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k1NHcHrN218404
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 10:38:17 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k1NHegE2007828
	for <linux-mm@kvack.org>; Thu, 23 Feb 2006 10:40:42 -0700
Date: Thu, 23 Feb 2006 09:40:24 -0800
From: Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: [PATCH 4/7] ppc64 - Specify amount of kernel memory at boot time
Message-ID: <20060223174024.GB5699@w-mikek2.ibm.com>
References: <20060217141552.7621.74444.sendpatchset@skynet.csn.ul.ie> <20060217141712.7621.49906.sendpatchset@skynet.csn.ul.ie> <1140196618.21383.112.camel@localhost.localdomain> <Pine.LNX.4.64.0602211445160.4335@skynet.skynet.ie> <1140543359.8693.32.camel@localhost.localdomain> <Pine.LNX.4.64.0602221625100.2801@skynet.skynet.ie> <1140712969.8697.33.camel@localhost.localdomain> <Pine.LNX.4.64.0602231646530.24093@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0602231646530.24093@skynet.skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Dave Hansen <haveblue@us.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Thu, Feb 23, 2006 at 05:19:19PM +0000, Mel Gorman wrote:
> On Thu, 23 Feb 2006, Dave Hansen wrote:
> 
> >On Wed, 2006-02-22 at 16:43 +0000, Mel Gorman wrote:
> >>Is this a bit clearer? It's built and boot tested on one ppc64 machine. I
> >>am having trouble finding a ppc64 machine that *has* memory holes to be
> >>100% sure it's ok.
> >
> >Yeah, it looks that way.  If you need a machine, see Mike Kravetz.  I
> >think he was working on a way to automate creating memory holes.
> >
> 
> Will do. If there is an automatic way of creating holes, I'll write it 
> into the current "compare two running kernels" testing script.

I don't realy have an automatic way to create holes.  Just turns out that
the system I was working with was good at creating them itself.

I've sliced and diced (made lots of partitioning changes) the system
recently and am still working on getting everything working right.
When I get everything working again, I'll give the patch set a try.

-- 
Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
