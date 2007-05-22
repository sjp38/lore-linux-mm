Date: Tue, 22 May 2007 16:52:28 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/8] Sparsemem Virtual Memmap V4
In-Reply-To: <exportbomb.1179873917@pinky>
Message-ID: <Pine.LNX.4.64.0705221651030.17489@schroedinger.engr.sgi.com>
References: <exportbomb.1179873917@pinky>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 22 May 2007, Andy Whitcroft wrote:

> It is worth noting that the ia64 support exposes an essentially
> private Kconfig option to allow selection of the two implementations.
> Once the 16Mb support is complete it should become the one and only
> implementation and that this option would no longer be exposed.

Right. You can omit 16MB support for the next round. We agreed with the 
other IA64 people that 16MB is too large and want to shoot for 4MB.
The 16k support should be sufficient for this patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
