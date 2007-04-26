From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] change global zonelist order on NUMA v2
Date: Thu, 26 Apr 2007 17:51:37 +0200
References: <20070426183417.058f6f9e.kamezawa.hiroyu@jp.fujitsu.com> <200704261147.44413.ak@suse.de> <Pine.LNX.4.64.0704260845160.1382@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0704260845160.1382@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200704261751.37656.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, AKPM <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thursday 26 April 2007 17:46:35 Christoph Lameter wrote:

> 
> It is not a good idea if node 0 has both DMA and NORMAL memory and normal 
> memory is a small fraction of node memory. In that case lots of 
> allocations get redirected to node 1.

Good point yes. On x86-64 you might even have ZONE_DMA on node 0/1 and NORMAL
only on 3. I guess this needs to be detected somehow.

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
