From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [RFC 17/22] s390: Use generic show_mem()
Date: Fri, 4 Apr 2008 09:39:18 +0200
Message-ID: <20080404073918.GA6910@osiris.boeblingen.de.ibm.com>
References: <12071688283927-git-send-email-hannes@saeurebad.de> <12071690203023-git-send-email-hannes@saeurebad.de> <20080403075029.GB4125@osiris.boeblingen.de.ibm.com> <87iqyzozyx.fsf@saeurebad.de> <20080403175856.GA4131@osiris.boeblingen.de.ibm.com> <87lk3umuny.fsf@saeurebad.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757983AbYDDHjj@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87lk3umuny.fsf@saeurebad.de>
Sender: linux-kernel-owner@vger.kernel.org
To: Johannes Weiner <hannes@saeurebad.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, davem@davemloft.net, hskinnemoen@atmel.com, cooloney@kernel.org, starvik@axis.com, dhowells@redhat.com, ysato@users.sf.net, takata@linux-m32r.org, geert@linux-m68k.org, ralf@linux-mips.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, jdike@addtoit.com, miles@gnu.org, chris@zankel.net, rmk@arm.linux.org.uk, tony.luck@intel.com
List-Id: linux-mm.kvack.org

> > Btw. your patch regarding the removal of show_free_areas() from
> > s390's arch code will be merged during the next merge window.
> 
> Okay.
> 
> Do you mean the removal of
> 
> 	printk("Free swap:       %6ldkB\n", nr_swap_pages << (PAGE_SHIFT
> 		- 10));
> 
> in show_mem()?  This was my last patch series about.

Yes.

> Can I add your Acked-by for _this_ series?

Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
