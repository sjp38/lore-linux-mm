Date: Wed, 22 Aug 2007 14:09:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG] 2.6.23-rc3-mm1 kernel BUG at mm/page_alloc.c:2876!
In-Reply-To: <20070822134800.ce5a5a69.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708221404360.16416@schroedinger.engr.sgi.com>
References: <46CC9A7A.2030404@linux.vnet.ibm.com>
 <20070822134800.ce5a5a69.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007, Andrew Morton wrote:

> On Thu, 23 Aug 2007 01:50:10 +0530
> Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
> 
> > Hi Andrew,
> > 
> > I see call trace followed by the kernel bug with the 2.6.23-rc3-mm1
> > kernel and have attached the boot log and config file.

> > =======================================================
> > SLUB: Genslabs=12, HWalign=128, Order=0-1, MinObjects=4, CPUs=4, Nodes=16

16 nodes and 4 cpus? Can I see the zones map that is displayed on 
boot? How are the cpus mapped to the nodes?

kmalloc_node walks the zonelists from the node that was specified.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
