Date: Wed, 7 May 2008 07:37:56 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC no patch yet] bootmem2: Another try
In-Reply-To: <87ve1qcn6n.fsf@saeurebad.de>
Message-ID: <alpine.LFD.1.10.0805070737100.32269@woody.linux-foundation.org>
References: <20080505095938.326928514@symbol.fehenstaub.lan> <87ve1qcn6n.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


On Wed, 7 May 2008, Johannes Weiner wrote:
> 
> Bootmem2 is block-oriented where a block represents a contiguous range
> of physical memory.  Every block has a bitmap that keeps track of the
> pages on it.

Yes, that one sounds fairly sane.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
