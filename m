Date: Fri, 24 Aug 2007 10:02:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Fix find_next_best_node (Re: [BUG] 2.6.23-rc3-mm1 Kernel
 panic - not syncing: DMA: Memory would be corrupted)
In-Reply-To: <20070824145233.GA26374@skynet.ie>
Message-ID: <Pine.LNX.4.64.0708241000460.20501@schroedinger.engr.sgi.com>
References: <617E1C2C70743745A92448908E030B2A023EB020@scsmsx411.amr.corp.intel.com>
 <20070823142133.9359a1ce.akpm@linux-foundation.org> <20070824153945.3C75.Y-GOTO@jp.fujitsu.com>
 <20070824145233.GA26374@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, "Luck, Tony" <tony.luck@intel.com>, Jeremy Higdon <jeremy@sgi.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 24 Aug 2007, Mel Gorman wrote:

> Andrew, this fixes a real problem and should be considered a fix to
> memoryless-nodes-fixup-uses-of-node_online_map-in-generic-code.patch unless
> Christoph Lameter objects.

Right. Lets make sure to cc Lee on future discussions of the memoryless 
node patchset.

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
