Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0JJOqte003410
	for <linux-mm@kvack.org>; Thu, 19 Jan 2006 14:24:52 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0JJR2Up176536
	for <linux-mm@kvack.org>; Thu, 19 Jan 2006 12:27:02 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0JJOpX9012114
	for <linux-mm@kvack.org>; Thu, 19 Jan 2006 12:24:51 -0700
Message-ID: <43CFE77B.3090708@austin.ibm.com>
Date: Thu, 19 Jan 2006 13:24:43 -0600
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Reducing fragmentation using zones
References: <20060119190846.16909.14133.sendpatchset@skynet.csn.ul.ie>
In-Reply-To: <20060119190846.16909.14133.sendpatchset@skynet.csn.ul.ie>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

> Benchmark comparison between -mm+NoOOM tree and with the new zones

I know you had also previously posted a very simplified version of your real 
fragmentation avoidance patches.  I was curious if you could repost those with 
the other benchmarks for a 3 way comparison.  The simplified version got rid of 
a lot of the complexity people were complaining about and in my mind still seems 
like preferable direction.

Zone based approaches are runtime inflexible and require boot time tuning by the 
sysadmin.  There are lots of workloads that "reasonable" defaults for a zone 
based approach would cause the system to regress terribly.

-Joel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
