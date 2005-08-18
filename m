Date: Wed, 17 Aug 2005 17:38:18 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH/RFT 4/5] CLOCK-Pro page replacement
Message-Id: <20050817173818.098462b5.akpm@osdl.org>
In-Reply-To: <20050810.133125.08323684.davem@davemloft.net>
References: <20050810200216.644997000@jumble.boston.redhat.com>
	<20050810200943.809832000@jumble.boston.redhat.com>
	<20050810.133125.08323684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

"David S. Miller" <davem@davemloft.net> wrote:
>
> > +DEFINE_PER_CPU(unsigned long, evicted_pages);
> 
> DEFINE_PER_CPU() needs an explicit initializer to work
> around some bugs in gcc-2.95, wherein on some platforms
> if you let it end up as a BSS candidate it won't end up
> in the per-cpu section properly.
> 
> I'm actually happy you made this mistake as it forced me
> to audit the whole current 2.6.x tree and there are few
> missing cases in there which I'll fix up and send to Linus.

I'm prety sure we fixed that somehow.  But I forget how.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
