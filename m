Date: Tue, 21 Aug 2007 11:25:35 +0100
Subject: Re: [PATCH 6/6] Do not use FASTCALL for __alloc_pages_nodemask()
Message-ID: <20070821102535.GF29794@skynet.ie>
References: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie> <20070817201848.14792.58117.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0708171406520.9635@schroedinger.engr.sgi.com> <200708181451.47219.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200708181451.47219.ak@suse.de>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (18/08/07 14:51), Andi Kleen didst pronounce:
> On Friday 17 August 2007 23:07:33 Christoph Lameter wrote:
> > On Fri, 17 Aug 2007, Mel Gorman wrote:
> > 
> > > Opinions as to why FASTCALL breaks on one machine are welcome.
> > 
> > Could we get rid of FASTCALL? AFAIK the compiler should automatically 
> > choose the right calling convention?
> 
> It was a nop for some time because register parameters are always enabled
> on i386 and AFAIK no other architectures ever used it. Some out of tree
> trees some to disable register parameters though, but that's not 
> really a concern.
> 

You're right. It now makes even less sense why it was a PPC64 machine that
exhibited the problem. It should have made no difference at all.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
