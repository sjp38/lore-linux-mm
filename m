Date: Tue, 22 May 2007 22:15:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 3/8] Generic Virtual Memmap support for SPARSEMEM V4
In-Reply-To: <E1HqdKD-0003dU-5r@hellhawk.shadowen.org>
Message-ID: <Pine.LNX.4.64.0705222214590.5218@schroedinger.engr.sgi.com>
References: <exportbomb.1179873917@pinky> <E1HqdKD-0003dU-5r@hellhawk.shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

I get a couple of warnings:

mm/sparse.c:423: warning: '__kmalloc_section_memmap' defined but not used
mm/sparse.c:453: warning: '__kfree_section_memmap' defined but not used

when building on IA64


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
