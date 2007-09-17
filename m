Subject: Re: 2.6.22.6: kernel BUG at fs/locks.c:171
From: Soeren Sonnenburg <kernel@nn7.de>
In-Reply-To: <200709161815.39633.nickpiggin@yahoo.com.au>
References: <1189675222.5352.10.camel@localhost>
	 <1189849627.4270.12.camel@localhost> <1189851735.4270.19.camel@localhost>
	 <200709161815.39633.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Mon, 17 Sep 2007 15:43:39 +0200
Message-Id: <1190036619.4757.8.camel@localhost>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2007-09-16 at 18:15 +1000, Nick Piggin wrote:
> On Saturday 15 September 2007 20:22, Soeren Sonnenburg wrote:
> > On Sat, 2007-09-15 at 09:47 +0000, Soeren Sonnenburg wrote:
> 
> > > Memtest did not find anything after 16 passes so I finally stopped
> it
> > > applied your patch and used
> > >
> > > CONFIG_DEBUG_SLAB=y
> > > CONFIG_DEBUG_SLAB_LEAK=y
> > >
> > > and booted into the new kernel.
> > >
> > > A few hours later the machine hung (due to nmi watchdog rebooted),
> so I
[...]
> > > swap_dup: Bad swap file entry 28c8af9d
> 
> Hmm, this is another telltale symptom of either bad hardware
> or a memory scribbling bug.

Since this morning, the machine is running with the dvb driver for that
certain card unloaded...

Anyway you convinced me that it is the bad saa7134_dvb drivers (driving
the asus p7131) fault. As the driver seems huge, I wonder whether there
are a) other config debug options that could aid in debugging b) what
the names of certain io functions are that may cause this...

Thanks a lot!
Soeren
-- 
Sometimes, there's a moment as you're waking, when you become aware of
the real world around you, but you're still dreaming.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
