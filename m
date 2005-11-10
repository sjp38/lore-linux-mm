Message-Id: <200511102334.jAANY1g21612@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: [PATCH] dequeue a huge page near to this node
Date: Thu, 10 Nov 2005 15:34:01 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <Pine.LNX.4.62.0511101521180.16770@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Christoph Lameter' <clameter@engr.sgi.com>, Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote on Thursday, November 10, 2005 3:27 PM
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


Looks great!

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
