Date: Thu, 10 Nov 2005 16:51:19 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] dequeue a huge page near to this node
Message-ID: <20051111005119.GQ29402@holomorphy.com>
References: <Pine.LNX.4.62.0511101521180.16770@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0511101521180.16770@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kenneth.w.chen@intel.com, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 10, 2005 at 03:27:12PM -0800, Christoph Lameter wrote:
> The following patch changes the dequeueing to select a huge page near
> the node executing instead of always beginning to check for free 
> nodes from node 0. This will result in a placement of the huge pages near
> the executing processor improving performance.
> The existing implementation can place the huge pages far away from 
> the executing processor causing significant degradation of performance.
> The search starting from zero also means that the lower zones quickly 
> run out of memory. Selecting a huge page near the process distributed the 
> huge pages better.
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Long intended to have been corrected. Thanks.

Acked-by: William Irwin <wli@holomorphy.com>


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
