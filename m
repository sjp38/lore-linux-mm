Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iBGEItDr521692
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 09:18:55 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBGEIsVt131592
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 07:18:54 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iBGEIsXC029686
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 07:18:54 -0700
Date: Thu, 16 Dec 2004 08:18:14 -0600
From: "Jose R. Santos" <jrsantos@austin.ibm.com>
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-ID: <20041216141814.GA10292@rx8.austin.ibm.com>
References: <Pine.SGI.4.61.0412141720420.22462@kzerza.americas.sgi.com> <50260000.1103061628@flay> <20041215045855.GH27225@wotan.suse.de> <20041215144730.GC24000@krispykreme.ozlabs.ibm.com> <20041216050248.GG32718@wotan.suse.de> <20041216051323.GI24000@krispykreme.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041216051323.GI24000@krispykreme.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Blanchard <anton@samba.org>
Cc: Andi Kleen <ak@suse.de>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, Brent Casavant <bcasavan@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org, jrsantos@austin.ibm.com
List-ID: <linux-mm.kvack.org>

Anton Blanchard <anton@samba.org> [041215]:
>  
> > I asked Brent to run some benchmarks originally and I believe he has 
> > already run all that he could easily set up. If you want more testing
> > you'll need to test yourself I think. 
> 
> We will be testing it.

By "We" you mean "Me" right? :)

I can do the SpecSFS runs but each runs takes several hours to complete
and I would need to do two runs (baseline and patched).  I may have it 
ready by today or tommorow.

-JRS
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
