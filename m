Subject: Re: 2.5.64-mm2
From: Robert Love <rml@tech9.net>
In-Reply-To: <1047095352.3483.0.camel@localhost.localdomain>
References: <20030307185116.0c53e442.akpm@digeo.com>
	 <1047095352.3483.0.camel@localhost.localdomain>
Content-Type: text/plain
Message-Id: <1047096331.727.14.camel@phantasy.awol.org>
Mime-Version: 1.0
Date: 07 Mar 2003 23:05:31 -0500
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shawn <core@enodev.com>
Cc: Andrew Morton <akpm@digeo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2003-03-07 at 22:49, Shawn wrote:

> make -f scripts/Makefile.build obj=arch/i386/lib
>   GEN     include/linux/compile.h (updated)
>   gcc2953 -Wp,-MD,init/.version.o.d -D__KERNEL__ -Iinclude -Wall
> -Wstrict-prototypes -Wno-trigraphs -O2 -fno-strict-aliasing -fno-common
> -pipe -mpreferred-stack-boundary=2 -march=i686 -malign-functions=4
> -Iinclude/asm-i386/mach-default -fomit-frame-pointer -nostdinc
> -iwithprefix include    -DKBUILD_BASENAME=version
> -DKBUILD_MODNAME=version -c -o init/.tmp_version.o init/version.c
>    ld -m elf_i386  -r -o init/built-in.o init/main.o init/version.o
> init/mounts.o init/initramfs.o
> kernel/built-in.o(__ksymtab+0xd00): undefined reference to `kernel_flag'
> make: *** [.tmp_vmlinux1] Error 1

Did you do a `make distclean' before building?  If not, can you?

And what combination of SMP + PREEMPT are you?  I assume you are
UP+PREEMPT, since that was what we changed.  It should not matter,
though... I think you just need to clean.

Let me know.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
