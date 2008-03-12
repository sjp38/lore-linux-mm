Date: Tue, 11 Mar 2008 21:35:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 0/7] [rfc] VM_MIXEDMAP, pte_special, xip work
Message-Id: <20080311213525.a5994894.akpm@linux-foundation.org>
In-Reply-To: <20080311104653.995564000@nick.local0.net>
References: <20080311104653.995564000@nick.local0.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@nick.local0.net
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jared Hulbert <jaredeh@gmail.com>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 11 Mar 2008 21:46:53 +1100 npiggin@nick.local0.net wrote:

> -- 
> 
> (doh, please ignore the previous "x/6" patches, they're old. The
> new ones are these x/7 set)
> 
> Hi,
> 
> I'm sorry for neglecting these patches for a few weeks :(
> 
> I'd like to still get them into -mm and aim for the next merge window --
> they've been gradually getting a pretty reasonable amount of review and
> testing. I think the implementation of the pte_special path in vm_normal_page
> and vm_insert_mixed was the only point left unresolved since last time.
> 
> I've included the dual kaddr/pfn API that we worked out with Jared, but
> he hasn't yet tested my patch rollup... so this is an RFC only. If we all
> agree on it, then I'll rebase to -mm and submit.
> 

umm, could we have some executive summary about what this is all supposed
to achieve?  I can see what each patch does, but what's the overall result?



[1/7] says:

> VM_MIXEDMAP achieves this by refcounting all pfn_valid pages, and not
> refcounting !pfn_valid pages (which is not an option for VM_PFNMAP, because
> it needs to avoid refcounting pfn_valid pages eg. for /dev/mem mappings).

I have this vague feeling that pfn_valid() isn't reliable - it can
sometimes lie, and that making it truthful was considered too expensive.

But maybe I'm thinking of something else?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
