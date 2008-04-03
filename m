From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [RFC 10/22] m68k: Use generic show_mem()
Date: Thu, 3 Apr 2008 15:39:16 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0804031538150.11898@anakin>
References: <12071688283927-git-send-email-hannes@saeurebad.de>
 <1207168941186-git-send-email-hannes@saeurebad.de> <Pine.LNX.4.64.0804030939320.9848@anakin>
 <87myobp02g.fsf@saeurebad.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758016AbYDCNji@vger.kernel.org>
In-Reply-To: <87myobp02g.fsf@saeurebad.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Johannes Weiner <hannes@saeurebad.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sourceforge.net, takata@linux-m32r.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org

On Thu, 3 Apr 2008, Johannes Weiner wrote:
> Geert Uytterhoeven <geert@linux-m68k.org> writes:
> > The new version no longer prints
> >
> >> -	printk("Free swap:       %6ldkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
> >
> 
> show_mem()
>  show_free_areas()
>   show_swap_cache_info()
>    printk("Free swap  = %lukB\n", nr_swap_pages << (PAGE_SHIFT - 10));
> 
> > and
> >
> >> -	printk("%d free pages\n",free);
> >
> > on m68k.
> 
> show_free_areas() prints global_page_state(NR_FREE_PAGES).  Isn't this
> the same?

Thanks, good to know...

So I suggest to add an additional (first) step to the consolidation: remove all
duplicates.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
