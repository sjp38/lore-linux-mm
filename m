Date: Tue, 24 Apr 2007 15:51:51 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.21-rc7-mm1 on test.kernel.org
Message-Id: <20070424155151.644e88b7.akpm@linux-foundation.org>
In-Reply-To: <1177453661.1281.1.camel@dyn9047017100.beaverton.ibm.com>
References: <20070424130601.4ab89d54.akpm@linux-foundation.org>
	<1177453661.1281.1.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Andy, I'm looking at the power4 build:

http://test.kernel.org/abat/84751/debug/test.log.0

which has

  LD      init/built-in.o
  LD      .tmp_vmlinux1
init/built-in.o(.init.text+0x32e4): In function `.rd_load_image':
: undefined reference to `.__kmalloc_size_too_large'
fs/built-in.o(.text+0xa60f0): In function `.ext3_fill_super':
: undefined reference to `.__kmalloc_size_too_large'
fs/built-in.o(.text+0xbe934): In function `.ext2_fill_super':
: undefined reference to `.__kmalloc_size_too_large'
fs/built-in.o(.text+0xf3370): In function `.nfs4_proc_lookup':

something has gone stupid with kmalloc there, and I cannot reproduce it
with my compiler and with your (very old) .config at
http://ftp.kernel.org/pub/linux/kernel/people/mbligh/config/abat/power4

So I'm a bit stumped.  Does autotest just do `yes "" | make oldconfig' or
what?  When I do that, I get SLUB, but no compile errors.

And do you know what compiler version is being used there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
