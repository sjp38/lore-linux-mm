Subject: Re: 2.6.0-test1-mm1
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <20030715232233.7d187f0e.akpm@osdl.org>
References: <20030715225608.0d3bff77.akpm@osdl.org>
	 <20030716061642.GA4032@triplehelix.org>
	 <20030715232233.7d187f0e.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1058368072.1636.2.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Date: 16 Jul 2003 09:07:53 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2003-07-16 at 00:22, Andrew Morton wrote:
> Joshua Kwan <joshk@triplehelix.org> wrote:
> >
> > There are a mountain of warnings when compiling, and I've traced it to
> >  asm-i386/irq.h, i THINK... for example:
> > 
> >  In file included from include/asm/thread_info.h:13,
> >                   from include/linux/thread_info.h:21,
> >                   from include/linux/spinlock.h:12,
> >                   from include/linux/irq.h:17,
> >                   from arch/i386/kernel/cpu/mcheck/winchip.c:8:
> >  include/asm/processor.h:66: warning: padding struct size to alignment boundary
> >  include/asm/processor.h:339: warning: padding struct to align `info'
> >  include/asm/processor.h:401: warning: padding struct to align `i387'
> 
> Oh, all right, I forgot to set aside the requisite eighteen hours to build
> the kernel with gcc-3.x.  Sorry bout that.
> 
> Just ignore them, or revert wpadded.patch.

Here's an oddment.  Using a .config which had CONFIG_EISA=y, and plain
2.6.0-test1-mm1 and gcc 3.2.2, I got this:

drivers/eisa/eisa-bus.c:26: warning: padding struct size to alignment boundary
make[2]: *** [drivers/eisa/eisa-bus.o] Error 1
make[1]: *** [drivers/eisa] Error 2
make: *** [drivers] Error 2
make: *** Waiting for unfinished jobs....
  CC      fs/ext3/balloc.o

Reverting wpadded.patch allowed -mm1 to build with CONFIG_EISA.

Using my normal .config without CONFIG_EISA, -mm1 built fine with and without
the wpadded.patch.  Just a lot more noise with.

Now testing 2.6.0-test1-mm1 on my main desktop, dual P3 SMP/IDE/256MB.

Steven



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
