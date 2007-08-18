From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 6/6] Do not use FASTCALL for __alloc_pages_nodemask()
Date: Sat, 18 Aug 2007 14:51:47 +0200
References: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie> <20070817201848.14792.58117.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0708171406520.9635@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0708171406520.9635@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708181451.47219.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 17 August 2007 23:07:33 Christoph Lameter wrote:
> On Fri, 17 Aug 2007, Mel Gorman wrote:
> 
> > Opinions as to why FASTCALL breaks on one machine are welcome.
> 
> Could we get rid of FASTCALL? AFAIK the compiler should automatically 
> choose the right calling convention?

It was a nop for some time because register parameters are always enabled
on i386 and AFAIK no other architectures ever used it. Some out of tree
trees some to disable register parameters though, but that's not 
really a concern.

-Andi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
