Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iBN2K3FJ339094
	for <linux-mm@kvack.org>; Wed, 22 Dec 2004 21:20:03 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBN2K2sJ282966
	for <linux-mm@kvack.org>; Wed, 22 Dec 2004 19:20:02 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iBN2K2Z6016934
	for <linux-mm@kvack.org>; Wed, 22 Dec 2004 19:20:02 -0700
Date: Wed, 22 Dec 2004 20:19:01 -0600
From: "Jose R. Santos" <jrsantos@austin.ibm.com>
Subject: Re: [PATCH 0/3] NUMA boot hash allocation interleaving
Message-ID: <20041223021901.GA27746@rx8.austin.ibm.com>
References: <Pine.SGI.4.61.0412141720420.22462@kzerza.americas.sgi.com> <50260000.1103061628@flay> <20041215045855.GH27225@wotan.suse.de> <20041215144730.GC24000@krispykreme.ozlabs.ibm.com> <20041216050248.GG32718@wotan.suse.de> <20041216051323.GI24000@krispykreme.ozlabs.ibm.com> <20041216141814.GA10292@rx8.austin.ibm.com> <20041220165629.GA21231@rx8.austin.ibm.com> <20041221114605.GB21710@krispykreme.ozlabs.ibm.com> <Pine.SGI.4.61.0412211019150.48124@kzerza.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.SGI.4.61.0412211019150.48124@kzerza.americas.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brent Casavant <bcasavan@sgi.com>
Cc: Anton Blanchard <anton@samba.org>, "Jose R. Santos" <jrsantos@austin.ibm.com>, Andi Kleen <ak@suse.de>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Brent Casavant <bcasavan@sgi.com> [041221]:
> I didn't realize this was ppc64 testing.  What was the exact setup
> for the testing?  The patch as posted (and I hope clearly explained)
> only turns on the behavior by default when both CONFIG_NUMA and
> CONFIG_IA64 were active.  It could be activated on non-IA64 by setting
> hashdist=1 on the boot line, or by modifying the patch.

I wasn't aware of the little detail.  I re-tested with hashdist=1 and
this time it shows a slowdown of about 3%-4% on a 4-Way Power5 system 
(2 NUMA nodes) with 64GB.  Don't see a big problem if the things is off
by default on non IA64 systems though.

> I would hate to find out that the testing didn't actually enable the
> new behavior.

Serves me right for not reading the entire thread. :)

-JRS
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
