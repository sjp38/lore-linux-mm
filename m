Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id i9QIGqLv012986
	for <linux-mm@kvack.org>; Tue, 26 Oct 2004 14:16:53 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i9QIGqJm431456
	for <linux-mm@kvack.org>; Tue, 26 Oct 2004 12:16:52 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id i9QIGqhj010533
	for <linux-mm@kvack.org>; Tue, 26 Oct 2004 12:16:52 -0600
Subject: Re: 050 bootmem use NODE_DATA
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <E1CJYYn-0000Zk-4w@ladymac.shadowen.org>
References: <E1CJYYn-0000Zk-4w@ladymac.shadowen.org>
Content-Type: text/plain
Message-Id: <1098814606.4861.10.camel@localhost>
Mime-Version: 1.0
Date: Tue, 26 Oct 2004 11:16:46 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2004-10-18 at 07:32, Andy Whitcroft wrote:
> Convert the default non-node based bootmem routines to use
> NODE_DATA(0).  This is semantically and functionally identical in
> any non-node configuration as NODE_DATA(x) is defined as below.
> 
> #define NODE_DATA(nid)          (&contig_page_data)
> 
> For the node cases (CONFIG_NUMA and CONFIG_DISCONTIG_MEM) we can
> use these non-node forms where all boot memory is defined on node 0.

Andy, this patch looks like good stuff, even outside of the context of
nonlinear.  Care to forward it on?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
