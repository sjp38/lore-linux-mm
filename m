Subject: Re: 2.6.0-test1-mm1
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <20030716102141.69d9c3cb.akpm@osdl.org>
References: <20030715225608.0d3bff77.akpm@osdl.org>
	 <20030716061642.GA4032@triplehelix.org>
	 <20030715232233.7d187f0e.akpm@osdl.org>
	 <1058368072.1636.2.camel@spc9.esa.lanl.gov>
	 <20030716102141.69d9c3cb.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1058381279.1632.31.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Date: 16 Jul 2003 12:47:59 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2003-07-16 at 11:21, Andrew Morton wrote:
> Steven Cole <elenstev@mesatop.com> wrote:
> >
> > drivers/eisa/eisa-bus.c:26: warning: padding struct size to alignment boundary
> > make[2]: *** [drivers/eisa/eisa-bus.o] Error 1
> > make[1]: *** [drivers/eisa] Error 2
> > make: *** [drivers] Error 2
> > make: *** Waiting for unfinished jobs....
> >   CC      fs/ext3/balloc.o
> > 
> > Reverting wpadded.patch allowed -mm1 to build with CONFIG_EISA.
> 
> Yes, some smarty added -Werror to drivers/eisa/Makefile.

About 12 weeks ago by the looks of it. 

[steven@spc9 linux-2.6.0-test1-mm1]$ find . -name Makefile | xargs grep "Werror"
./arch/sparc64/kernel/Makefile:EXTRA_CFLAGS := -Werror
./arch/sparc64/lib/Makefile:EXTRA_CFLAGS := -Werror
./arch/sparc64/prom/Makefile:EXTRA_CFLAGS := -Werror
./arch/sparc64/mm/Makefile:EXTRA_CFLAGS := -Werror
./arch/alpha/lib/Makefile:EXTRA_CFLAGS := -Werror
./arch/alpha/kernel/Makefile:EXTRA_CFLAGS       := -Werror -Wno-sign-compare
./arch/alpha/mm/Makefile:EXTRA_CFLAGS := -Werror
./arch/alpha/oprofile/Makefile:EXTRA_CFLAGS := -Werror -Wno-sign-compare
./drivers/eisa/Makefile:EXTRA_CFLAGS    := -Werror
./drivers/scsi/aic7xxx/Makefile:EXTRA_CFLAGS += -Idrivers/scsi -Werror
./drivers/input/joystick/iforce/Makefile:EXTRA_CFLAGS = -Werror-implicit-function-declaration
./fs/smbfs/Makefile:#EXTRA_CFLAGS += -Werror

The antepenultimate item in that list got my attention, so I built
-test1-mm1 on my SCSI machine which, BTW, has gcc 2.96 as shipped with
Red Hat 7.3.  I got this:

make[3]: *** [drivers/scsi/aic7xxx/aic7xxx_core.o] Error 1
make[2]: *** [drivers/scsi/aic7xxx] Error 2
make[1]: *** [drivers/scsi] Error 2
make: *** [drivers] Error 2
make: *** Waiting for unfinished jobs....

Reverting wpadded.patch allowed it to build OK.  So, this problem
doesn't appear to be limited to gcc 3.x.

Steven


elens
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
