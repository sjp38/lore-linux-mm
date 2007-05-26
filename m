Date: Sat, 26 May 2007 08:44:35 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 3/8] mm: merge nopfn into fault
In-Reply-To: <20070526080320.GD32402@wotan.suse.de>
Message-ID: <alpine.LFD.0.98.0705260844080.26602@woody.linux-foundation.org>
References: <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org>
 <1179963619.32247.991.camel@localhost.localdomain> <20070524014223.GA22998@wotan.suse.de>
 <alpine.LFD.0.98.0705231857090.3890@woody.linux-foundation.org>
 <1179976659.32247.1026.camel@localhost.localdomain>
 <1179977184.32247.1032.camel@localhost.localdomain>
 <alpine.LFD.0.98.0705232028510.3890@woody.linux-foundation.org>
 <20070525111818.GA3881@wotan.suse.de> <alpine.LFD.0.98.0705250924320.26602@woody.linux-foundation.org>
 <20070526073426.GC32402@wotan.suse.de>
 <20070526080320.GD32402@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>


On Sat, 26 May 2007, Nick Piggin wrote:
> 
> Here is something of an untested mockup (incremental since the last
> incremental one). It does look quite a bit cleaner, and let's us
> finally get rid of that stupid __handle_mm_fault thing.

Yeah, I think I approve of this one.

Thanks,

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
