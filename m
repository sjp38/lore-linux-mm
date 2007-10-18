Date: Thu, 18 Oct 2007 00:00:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Patch](memory hotplug) Make kmem_cache_node for SLUB on memory
 online to avoid panic(take 3)
Message-Id: <20071018000004.cf4727e7.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0710172321550.11401@schroedinger.engr.sgi.com>
References: <20071018122345.514F.Y-GOTO@jp.fujitsu.com>
	<20071017204651.aefcece7.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0710172321550.11401@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Oct 2007 23:25:58 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> > So that's slub.  Does slab already have this functionality or are you
> > not bothering to maintain slab in this area?
> 
> Slab brings up a per node structure when the corresponding cpu is brought 
> up. That was sufficient as long as we did not have any memoryless nodes. 
> Now we may have to fix some things over there as well.

Is there amy point?  Our time would be better spent in making
slab.c go away.  How close are we to being able to do that anwyay?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
