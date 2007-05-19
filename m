Date: Fri, 18 May 2007 19:03:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] increase struct page size?! (now sparsemem vmemmap)
In-Reply-To: <20070519012530.GB15569@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0705181901130.14521@schroedinger.engr.sgi.com>
References: <20070518040854.GA15654@wotan.suse.de>
 <Pine.LNX.4.64.0705181112250.11881@schroedinger.engr.sgi.com>
 <20070519012530.GB15569@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: apw@shadowen.org
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Sat, 19 May 2007, Nick Piggin wrote:

> Hugh points out that we should make _count and _mapcount atomic_long_t's,
> which would probably be a better use of the space once your vmemmap goes
> in.

Well Andy was going to merge it:

http://marc.info/?l=linux-kernel&m=117620162415620&w=2

Andy when are we going to get the vmemmap patches into sparsemem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
