Date: Thu, 20 Apr 2006 13:03:15 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 2/5] mm: deprecate vmalloc_to_pfn
Message-Id: <20060420130315.1911ab42.akpm@osdl.org>
In-Reply-To: <20060420173616.GE21660@wotan.suse.de>
References: <20060228202202.14172.60409.sendpatchset@linux.site>
	<20060228202223.14172.21110.sendpatchset@linux.site>
	<20060420172240.GD21659@infradead.org>
	<20060420173616.GE21660@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Nick Piggin <npiggin@suse.de> wrote:
>
> On Thu, Apr 20, 2006 at 06:22:40PM +0100, Christoph Hellwig wrote:
> > On Thu, Apr 20, 2006 at 07:06:30PM +0200, Nick Piggin wrote:
> > > Deprecate vmalloc_to_pfn.
> > 
> > I don't think there's any point to even keep it.  There's a trivial replcement.
> 
> It is exported, is the only thing. I tend to stick my head in the sand
> with these matters, and try to go with whatever I think will help Andrew
> merge it.
> 
> If nobody cares, I'd just as soon remove it completely.

It's been in there for a long time.  Theoretically we should mark it
deprecated, kill it in six months or so.

But vmalloc_to_page() is EXPORT_SYMBOLed, so fixing up downstream breakage
will be so trivial it's hardly worth bothering.  So let's zap vmalloc_to_pfn()
in 2.6.18.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
