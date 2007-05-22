Date: Mon, 21 May 2007 18:13:03 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] increase struct page size?!
In-Reply-To: <20070522010823.GC27743@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705211812440.24359@schroedinger.engr.sgi.com>
References: <20070518040854.GA15654@wotan.suse.de>
 <Pine.LNX.4.64.0705181112250.11881@schroedinger.engr.sgi.com>
 <20070519012530.GB15569@wotan.suse.de> <20070519181501.GC19966@holomorphy.com>
 <20070520052229.GA9372@wotan.suse.de> <20070520084647.GF19966@holomorphy.com>
 <20070520092552.GA7318@wotan.suse.de> <20070521080813.GQ31925@holomorphy.com>
 <20070521092742.GA19642@wotan.suse.de> <20070521224316.GC11166@waste.org>
 <20070522010823.GC27743@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Matt Mackall <mpm@selenic.com>, William Lee Irwin III <wli@holomorphy.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 May 2007, Nick Piggin wrote:

> That would be unpopular with pagecache, because that uses pretty well
> all fields.

SLUB also uses all fields....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
