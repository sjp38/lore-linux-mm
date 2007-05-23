Date: Tue, 22 May 2007 17:00:05 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/8] Sparsemem Virtual Memmap V4
In-Reply-To: <exportbomb.1179873917@pinky>
Message-ID: <Pine.LNX.4.64.0705221657550.17489@schroedinger.engr.sgi.com>
References: <exportbomb.1179873917@pinky>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 22 May 2007, Andy Whitcroft wrote:

> I do not have performance data on this round of patches yet, but
> measurements on the initial PPC64 implementation showed a small
> but measurable improvement.

Well the performance tests that I did on x86_64 showed a reduction of the 
performance of virt_to_page from 18us to 9us. So I think we are fine.

> This stack is against v2.6.22-rc1-mm1.  It has been compile, boot
> and lightly tested on x86_64, ia64 and PPC64.  Sparc64 as been
> compiled but not booted.

Can we get that into mm soon? There are potentially other arches that also 
may want to run their own vmemmap functions for this and I would like to 
have an easy way to tinker around with a 4M vmemmap size for IA64.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
