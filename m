Date: Mon, 14 Apr 2003 04:03:26 -0700
Subject: Re: 2.5.67-mm3
Message-ID: <20030414110326.GA19003@gnuppy.monkey.org>
References: <20030414015313.4f6333ad.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030414015313.4f6333ad.akpm@digeo.com>
From: Bill Huey (Hui) <billh@gnuppy.monkey.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Bill Huey (Hui)" <billh@gnuppy.monkey.org>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 14, 2003 at 01:53:13AM -0700, Andrew Morton wrote:
> A bunch of new fixes, and a framebuffer update.  This should work a bit
> better than -mm2.

make -f scripts/Makefile.build obj=arch/i386/boot arch/i386/boot/bzImage
  ld -m elf_i386  -Ttext 0x0 -s --oformat binary -e begtext
  arch/i386/boot/setup.o -o arch/i386/boot/setup 
  arch/i386/boot/setup.o(.text+0x9a4): In function `video':
  /tmp/ccyhvWWu.s:2925: undefined reference to `store_edid'
  make[1]: *** [arch/i386/boot/setup] Error 1
  make: *** [bzImage] Error 2

---------------------------------------

Not sure what's triggering this here.

bill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
