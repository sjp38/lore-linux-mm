Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iBKGvIDP475712
	for <linux-mm@kvack.org>; Mon, 20 Dec 2004 11:57:18 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBKGvI2L410588
	for <linux-mm@kvack.org>; Mon, 20 Dec 2004 09:57:18 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iBKGvHPc020425
	for <linux-mm@kvack.org>; Mon, 20 Dec 2004 09:57:17 -0700
Date: Mon, 20 Dec 2004 10:56:29 -0600
From: "Jose R. Santos" <jrsantos@austin.ibm.com>
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-ID: <20041220165629.GA21231@rx8.austin.ibm.com>
References: <Pine.SGI.4.61.0412141720420.22462@kzerza.americas.sgi.com> <50260000.1103061628@flay> <20041215045855.GH27225@wotan.suse.de> <20041215144730.GC24000@krispykreme.ozlabs.ibm.com> <20041216050248.GG32718@wotan.suse.de> <20041216051323.GI24000@krispykreme.ozlabs.ibm.com> <20041216141814.GA10292@rx8.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041216141814.GA10292@rx8.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Jose R. Santos" <jrsantos@austin.ibm.com>
Cc: Anton Blanchard <anton@samba.org>, Andi Kleen <ak@suse.de>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, Brent Casavant <bcasavan@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jose R. Santos <jrsantos@austin.ibm.com> [041216]:
> I can do the SpecSFS runs but each runs takes several hours to complete
> and I would need to do two runs (baseline and patched).  I may have it 
> ready by today or tommorow.

The difference between the two runs was with in noise of the benchmark on
my small setup.  I wont be able to get a larger NUMA system until next year,
so I'll retest when that happens.  In the mean time, I don't see a reason
either to stall this patch, but that may change on I get numbers on a
larger system.

-JRS
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
