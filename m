Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l98GVPoZ028504
	for <linux-mm@kvack.org>; Mon, 8 Oct 2007 12:31:25 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l98Hdxoq376480
	for <linux-mm@kvack.org>; Mon, 8 Oct 2007 11:39:59 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l98HdxTH008316
	for <linux-mm@kvack.org>; Mon, 8 Oct 2007 11:39:59 -0600
Date: Mon, 8 Oct 2007 10:39:58 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 2/2] hugetlb: fix pool allocation with empty nodes
Message-ID: <20071008173958.GB14670@us.ibm.com>
References: <20071003224538.GB29663@us.ibm.com> <20071003224904.GC29663@us.ibm.com> <Pine.LNX.4.64.0710032054390.4560@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0710032054390.4560@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: wli@holomorphy.com, anton@samba.org, agl@us.ibm.com, lee.schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 03.10.2007 [20:55:00 -0700], Christoph Lameter wrote:
> Acked-by: Christoph Lameter <clameter@sgi.com>
> 
> I guess this should be included in 2.6.24?

Realistically, I think 1/2 would be sufficient for now. Since Adam's
patches have gone in, 2/2 needs to be reworked to account for the new
users of node_online_map.

*But*, Lee found issues with my patches and Mel's one-zonelist patches,
potentially. I'm going to investigate that in the next week and repost
the rebased (on top of Adam's patches which will be in the next -mm)
patches soon.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
