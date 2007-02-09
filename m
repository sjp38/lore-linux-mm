Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l19H1IoN358878
	for <linux-mm@kvack.org>; Fri, 9 Feb 2007 17:01:18 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l19H1Inh1851530
	for <linux-mm@kvack.org>; Fri, 9 Feb 2007 17:01:18 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l19H1F22012558
	for <linux-mm@kvack.org>; Fri, 9 Feb 2007 17:01:18 GMT
Date: Fri, 9 Feb 2007 18:00:05 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH 00/34] __initdata cleanup
Message-ID: <20070209170005.GA8500@osiris.ibm.com>
References: <200702091711.34441.alon.barlev@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200702091711.34441.alon.barlev@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alon Bar-Lev <alon.barlev@gmail.com>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, bwalle@suse.de, rmk+lkml@arm.linux.org.uk, spyro@f2s.com, davej@codemonkey.org.uk, hpa@zytor.com, Riley@williams.name, tony.luck@intel.com, geert@linux-m68k.org, zippel@linux-m68k.org, ralf@linux-mips.org, matthew@wil.cx, grundler@parisc-linux.org, kyle@parisc-linux.org, paulus@samba.org, schwidefsky@de.ibm.com, lethal@linux-sh.org, davem@davemloft.net, uclinux-v850@lsi.nec.co.jp, ak@muc.de, vojtech@suse.cz, chris@zankel.net, len.brown@intel.com, lenb@kernel.org, herbert@gondor.apana.org.au, viro@zeniv.linux.org.uk, bzolnier@gmail.com, dmitry.torokhov@gmail.com, dtor@mail.ru, jgarzik@pobox.com, linux-mm@kvack.org, dwmw2@infradead.org, patrick@tykepenguin.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org, philb@gnu.org, tim@cyberelk.net, andrea@suse.de, ambx1@neo.rr.com, James.Bottomley@steeleye.com, linux-serial@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 09, 2007 at 05:11:32PM +0200, Alon Bar-Lev wrote:
>  
> Follow-up Russell King comment at http://lkml.org/lkml/2007/1/22/267
>
> All __initdata variables should be initialized so they won't end up
> in BSS.
>  
> There is no dependency between patches or even hunks.
>  
> Some architecture patches are untested, this is documented as "UNTESTED"
>  
> Against 2.6.20-rc6-mm3.

To quote parts of that:

Anyway, here's what the GCC manual has to say about use of
__attribute__((section)) on variables:

`section ("SECTION-NAME")'
     Use the `section' attribute with an _initialized_ definition of a
     _global_ variable, as shown in the example.  GCC issues a warning
     and otherwise ignores the `section' attribute in uninitialized
     variable declarations.

     You may only use the `section' attribute with a fully initialized
     global definition because of the way linkers work.  The linker
     requires each object be defined once, with the exception that
     uninitialized variables tentatively go in the `common' (or `bss')
     section and can be multiply "defined".  You can force a variable
     to be initialized with the `-fno-common' flag or the `nocommon'
     attribute.

And the top-level Makefile has:

CFLAGS          := -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs \
                   -fno-strict-aliasing -fno-common

Note the -fno-common.

And indeed all the __initdata annotated local and global variables on
s390 are in the init.data section. So I'm wondering what this patch
series is about. Or I must have missed something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
