Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j95HNuUg032017
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 13:23:56 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95HPVfK543012
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 11:25:31 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j95HPU7r008562
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 11:25:30 -0600
Subject: Re: [PATCH 5/7] Fragmentation Avoidance V16: 005_fallback
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0510051817560.16421@skynet>
References: <20051005144546.11796.1154.sendpatchset@skynet.csn.ul.ie>
	 <20051005144612.11796.35309.sendpatchset@skynet.csn.ul.ie>
	 <1128531235.26009.35.camel@localhost>
	 <Pine.LNX.4.58.0510051817560.16421@skynet>
Content-Type: text/plain
Date: Wed, 05 Oct 2005 10:25:22 -0700
Message-Id: <1128533122.26009.46.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, jschopp@austin.ibm.com, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-05 at 18:20 +0100, Mel Gorman wrote:
> Changed to
> 
> for (i = 0; (alloctype = fallback_list[i]) != -1; i++) {
> 
> where i is declared a the start of the function. It's essentially the same
> as how we move through the zones fallback list so should seem familiar. Is
> that better?

Yep, at least I understand what it's doing :)

One thing you might consider is not doing the assignment in the for()
body:

	for (i = 0; fallback_list[i] != -1; i++) {
		alloctype = fallback_list[i];
		...

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
