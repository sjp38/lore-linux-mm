Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6RKxcAj008991
	for <linux-mm@kvack.org>; Fri, 27 Jul 2007 16:59:38 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6RKxckh192848
	for <linux-mm@kvack.org>; Fri, 27 Jul 2007 14:59:38 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6RKxc6u006550
	for <linux-mm@kvack.org>; Fri, 27 Jul 2007 14:59:38 -0600
Date: Fri, 27 Jul 2007 13:59:37 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 00/14] NUMA: Memoryless node support V4
Message-ID: <20070727205937.GU18510@us.ibm.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070727194316.18614.36380.sendpatchset@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, ak@suse.de, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 27.07.2007 [15:43:16 -0400], Lee Schermerhorn wrote:
> Changes V3->V4:
> - Refresh against 23-rc1-mm1
> - teach cpusets about memoryless nodes.
> 
> Changes V2->V3:
> - Refresh patches (sigh)
> - Add comments suggested by Kamezawa Hiroyuki
> - Add signoff by Jes Sorensen
> 
> Changes V1->V2:
> - Add a generic layer that allows the definition of additional node bitmaps

Are you carrying this stack anywhere publicly? Like in a git tree or
even just big patch format?

Thanks,
Nish, who will rebase on top of this set

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
