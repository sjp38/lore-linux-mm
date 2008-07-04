Date: Fri, 4 Jul 2008 11:12:24 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: How to alloc highmem page below 4GB on i386?
Message-ID: <20080704111224.68266afc@infradead.org>
In-Reply-To: <20080704195800.4ef6e00a@mjolnir.drzeus.cx>
References: <20080630200323.2a5992cd@mjolnir.drzeus.cx>
	<20080704195800.4ef6e00a@mjolnir.drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pierre Ossman <drzeus-list@drzeus.cx>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jul 2008 19:58:00 +0200
Pierre Ossman <drzeus-list@drzeus.cx> wrote:

> On Mon, 30 Jun 2008 20:03:23 +0200
> Pierre Ossman <drzeus-list@drzeus.cx> wrote:
> 
> > Simple question. How do I allocate a page from highmem, that's still
> > within 32 bits? x86_64 has the DMA32 zone, but i386 has just
> > HIGHMEM. As most devices can't DMA above 32 bit, I have 3 GB of
> > memory that's not getting decent usage (or results in needless
> > bouncing). What to do?
> > 
> > I tried just enabling CONFIG_DMA32 for i386, but there is some guard
> > against too many memory zones. I'm assuming this is there for a good
> > reason?
> > 
> 
> Anyone?
> 

well... the assumption sort of is that all high-perf devices are 64 bit
capable. For the rest... well you get what you get. There's IOMMU's in
modern systems from Intel (and soon AMD) that help you avoid the bounce
if you really care. 

The second assumption sort of is that you don't have 'too much' above
4Gb; once you're over 16Gb or so people assume you will run the 64 bit
kernel instead...
(you're hard pressed to find any system nowadays that can support > 4Gb
but cannot support 64 bit... a few years ago that was different but 64
bit has been with us for many years now)


-- 
If you want to reach me at my work email, use arjan@linux.intel.com
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
