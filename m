Date: Tue, 20 Jan 2004 23:27:00 +0100
From: Adrian Bunk <bunk@fs.tum.de>
Subject: Re: 2.6.1-mm5 (compile stats)
Message-ID: <20040120222700.GJ12027@fs.tum.de>
References: <20040120000535.7fb8e683.akpm@osdl.org> <1074614919.31724.0.camel@cherrypit.pdx.osdl.net> <20040120215705.GG12027@fs.tum.de> <1074636910.16765.14.camel@cherrytest.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1074636910.16765.14.camel@cherrytest.pdx.osdl.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Cherry <cherry@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 20, 2004 at 02:15:10PM -0800, John Cherry wrote:
>...
> > Regarding allnoconfig:
> > allnoconfig is a completely pathological case. It says "n" to support 
> > for ISA, MCA and PCI, and neither networking nor any block devices.
> > Besides, it says "n" to ELF, a.out and other binary formats.
> > Demanding that allnoconfig should compile (although the resulting kernel 
> > is completely useless) sounds a bit like demanding that no change in the 
> > kernel is allowed to cause regressions in the dbench results...
> > It is useful to omit a common option like e.g. PCI and check whether the 
> > kernel still compiles, but allnoconfig removes nearly everything and 
> > compiles such a small part of the kernel, that it's hardly useful.
> 
> I realize that allnoconfig is pathological, but it has caught several
> config errors.  One would never try to boot from such a config.  Builds
> based on allnoconfig have one purpose and that purpose is to validate
> that defines are not used in cases where they are NOT defined in the
> configuration.  Developers will quite often code a feature or
> architecture with the config parameters always ON.  When the config
> option is turned OFF, I will find compile errors, undefined variables,
> and the like. This is actually quite a valuable screen.

The problem is that allnoconfig turns _everything_ off.

Cases like e.g. CONFIG_PROC_FS=n are interesting, but allnoconfig 
doesn't really test them since allnoconfig also says "n" to all drivers.

> If developers feel that this has outlived its usefulness, I'll remove it
> from the compile regressions.  However, all I have received at this
> point have been requests to put an allnoconfig build into the
> regressions.

I'd like to hear from the people requesting it why they consider it 
useful.

In my personal experience, compiling allyesconfig but with CONFIG_SMP=n 
(which enables BROKEN_ON_SMP drivers), and compiling with gcc 2.95 are 
more interesing (and more realistic) configurations than allnoconfig 
that find many compile errors.

> John

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
