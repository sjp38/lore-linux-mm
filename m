Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id jABEKK7Y025414
	for <linux-mm@kvack.org>; Fri, 11 Nov 2005 09:20:20 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jABEKKPu114118
	for <linux-mm@kvack.org>; Fri, 11 Nov 2005 09:20:20 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id jABEKJE4013865
	for <linux-mm@kvack.org>; Fri, 11 Nov 2005 09:20:20 -0500
Subject: Re: [PATCH] dequeue a huge page near to this node
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <Pine.LNX.4.62.0511101521180.16770@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511101521180.16770@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 11 Nov 2005 08:19:25 -0600
Message-Id: <1131718765.13502.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kenneth.w.chen@intel.com, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Thu, 2005-11-10 at 15:27 -0800, Christoph Lameter wrote:
> The following patch changes the dequeueing to select a huge page near
> the node executing instead of always beginning to check for free 
> nodes from node 0. This will result in a placement of the huge pages near
> the executing processor improving performance.
> 
> The existing implementation can place the huge pages far away from 
> the executing processor causing significant degradation of performance.
> The search starting from zero also means that the lower zones quickly 
> run out of memory. Selecting a huge page near the process distributed the 
> huge pages better.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

I'll add my voice to the chorus of aye's.

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
