Date: Fri, 16 May 2003 18:55:39 +0100
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: 2.5.69-mm6
Message-ID: <20030516175539.GA16626@suse.de>
References: <20030516015407.2768b570.akpm@digeo.com> <20030516172834.GA9774@foo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030516172834.GA9774@foo>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Henriksson <andreas@fjortis.info>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 16, 2003 at 07:28:34PM +0200, Andreas Henriksson wrote:

 > I had to remove "static" from the agp_init-function in
 > drivers/char/agp/backend.c to get the kernel to link (when building
 > Intel 810 Framebuffer into the kernel).

wrong fix. nuke the agp_init() call from i810fb
note, it still won't actually work. i810fb still fails to init
the agpgart for some reason.
 
 > I also got unresolved symbols for two modules.
 > arch/i386/kernel/suspend.ko: enable_sep_cpu, default_ldt, init_tss
 > arch/i386/kernel/apm.ko: save_processor_state, restore_processor_state

Mikael's patch for these has been posted several times already in the
last few days.

		Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
