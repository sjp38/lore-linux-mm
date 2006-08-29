Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7TIxwk5028780
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 14:59:58 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7TIxwsw337492
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 12:59:58 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7TIxwcc003643
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 12:59:58 -0600
Subject: Re: [RFC][PATCH 1/7] generic PAGE_SIZE infrastructure (v2)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <874pvw3099.peterc%peterc@gelato.unsw.edu.au>
References: <20060828154413.E05721BD@localhost.localdomain>
	 <Pine.LNX.4.64.0608280954100.27677@schroedinger.engr.sgi.com>
	 <1156785119.5913.25.camel@localhost.localdomain>
	 <874pvw3099.peterc%peterc@gelato.unsw.edu.au>
Content-Type: text/plain
Date: Tue, 29 Aug 2006 11:59:52 -0700
Message-Id: <1156877992.5408.126.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Chubb <peterc@gelato.unsw.edu.au>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-08-29 at 09:32 +1000, Peter Chubb wrote:
> IA64 wants 16k standard, 64k for better performance.  So something
> that says `choose 8k if you can' doesn't really fit.  And it'd be
> *really* nice to test larger pages --- I see ~5% improvement in
> streaming I/O to a  suitable RAID array with 64k as opposed to 16k
> pages.

I've updated the help text a bit.  I'd appreciate if you could take a
look at the latest series, which I'll post shortly.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
