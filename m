Message-ID: <462E9382.90701@shadowen.org>
Date: Wed, 25 Apr 2007 00:32:18 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: 2.6.21-rc7-mm1 on test.kernel.org
References: <20070424130601.4ab89d54.akpm@linux-foundation.org>	<1177453661.1281.1.camel@dyn9047017100.beaverton.ibm.com> <20070424155151.644e88b7.akpm@linux-foundation.org>
In-Reply-To: <20070424155151.644e88b7.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Badari Pulavarty <pbadari@gmail.com>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Andy, I'm looking at the power4 build:
> 
> http://test.kernel.org/abat/84751/debug/test.log.0
> 
> which has
> 
>   LD      init/built-in.o
>   LD      .tmp_vmlinux1
> init/built-in.o(.init.text+0x32e4): In function `.rd_load_image':
> : undefined reference to `.__kmalloc_size_too_large'
> fs/built-in.o(.text+0xa60f0): In function `.ext3_fill_super':
> : undefined reference to `.__kmalloc_size_too_large'
> fs/built-in.o(.text+0xbe934): In function `.ext2_fill_super':
> : undefined reference to `.__kmalloc_size_too_large'
> fs/built-in.o(.text+0xf3370): In function `.nfs4_proc_lookup':
> 
> something has gone stupid with kmalloc there, and I cannot reproduce it
> with my compiler and with your (very old) .config at
> http://ftp.kernel.org/pub/linux/kernel/people/mbligh/config/abat/power4
> 
> So I'm a bit stumped.  Does autotest just do `yes "" | make oldconfig' or
> what?  When I do that, I get SLUB, but no compile errors.

Yes, exactly that.

> 
> And do you know what compiler version is being used there?

gcc version 3.4.4 20050314 (prerelease) (Debian 3.4.3-13sarge1)

I am bisecting for the bad page bug right now, will let you know where
it points.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
