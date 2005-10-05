Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j95GNcDj014337
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 12:23:38 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j95GPqx4538230
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 10:25:53 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j95GP9xL002956
	for <linux-mm@kvack.org>; Wed, 5 Oct 2005 10:25:09 -0600
Subject: Re: [PATCH] i386: nid_zone_sizes_init() update
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <189750000.1128525005@[10.10.2.4]>
References: <20051005083515.4305.16399.sendpatchset@cherry.local>
	 <189750000.1128525005@[10.10.2.4]>
Content-Type: text/plain
Date: Wed, 05 Oct 2005 09:25:02 -0700
Message-Id: <1128529502.26009.20.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2005-10-05 at 08:10 -0700, Martin J. Bligh wrote:
> > Broken out nid_zone_sizes_init() change from i386 NUMA emulation code.
> 
> Mmmm. what's the purpose of this change? Not sure I understand what
> you're trying to acheive here ... looks like you're just removing
> some abstractions? To me, they made the code a bit easier to read.

Thanks for the compliment.  Perhaps we should merge this patch upstream:

http://www.sr71.net/patches/2.6.14/2.6.14-rc2-git8-mhp1/broken-out/B2.1-i386-discontig-consolidation.patch

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
