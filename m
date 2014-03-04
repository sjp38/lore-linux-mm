Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id AED646B0037
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 19:39:23 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id ma3so4311021pbc.13
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 16:39:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id sh5si12263427pbc.140.2014.03.03.16.39.22
        for <linux-mm@kvack.org>;
        Mon, 03 Mar 2014 16:39:22 -0800 (PST)
Date: Mon, 3 Mar 2014 16:39:21 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2014-03-03-15-24 uploaded
Message-Id: <20140303163921.48ab37bdfd9b895ee985a776@linux-foundation.org>
In-Reply-To: <20140304113610.a033faa8e5d3afeb38f7ac79@canb.auug.org.au>
References: <20140303232530.2AC4131C2A3@corp2gmr1-1.hot.corp.google.com>
	<20140304113610.a033faa8e5d3afeb38f7ac79@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Josh Triplett <josh@joshtriplett.org>, Geert Uytterhoeven <geert@linux-m68k.org>

On Tue, 4 Mar 2014 11:36:10 +1100 Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi Andrew,
> 
> On Mon, 03 Mar 2014 15:25:29 -0800 akpm@linux-foundation.org wrote:
> >
> > The mm-of-the-moment snapshot 2014-03-03-15-24 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> 
> > * kconfig-make-allnoconfig-disable-options-behind-embedded-and-expert.patch
> 
> I am carrying 5 fix patches for the above patch (they need to go before
> or as part of the above patch).
> 
> ppc_Make_PPC_BOOK3S_64_select_IRQ_WORK.patch
> ia64__select_CONFIG_TTY_for_use_of_tty_write_message_in_unaligned.patch
> s390__select_CONFIG_TTY_for_use_of_tty_in_unconditional_keyboard_driver.patch
> cris__Make_ETRAX_ARCH_V10_select_TTY_for_use_in_debugport.patch
> cris__cpuinfo_op_should_depend_on_CONFIG_PROC_FS.patch
> 
> I can send them to you if you like,

Yes please.

> but I am pretty sure you were cc'd on all of them.

I hoped someone else was collecting them ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
