content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: 2.5.69-mm5
Date: Wed, 14 May 2003 10:33:43 -0400
Message-ID: <CDD2FA891602624BB024E1662BC678ED843F91@mbi-00.mbi.ufl.edu>
From: "Jon K. Akers" <jka@mbi.ufl.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I like to at least build the new stuff that comes out with Andrew's
patches, and building the new gadget code that came out in -mm4 I got
this when building as a module:

make -f scripts/Makefile.build obj=drivers/serial
make -f scripts/Makefile.build obj=drivers/usb/gadget
  gcc -Wp,-MD,drivers/usb/gadget/.net2280.o.d -D__KERNEL__ -Iinclude
-Wall -Wstrict-prototypes -Wno-trigraphs -O2 -fno-strict-aliasing
-fno-common -pipe -mpreferred-stack-boundary=2 -march=i686
-Iinclude/asm-i386/mach-default -fomit-frame-pointer -nostdinc
-iwithprefix include -DMODULE   -DKBUILD_BASENAME=net2280
-DKBUILD_MODNAME=net2280 -c -o drivers/usb/gadget/net2280.o
drivers/usb/gadget/net2280.c
drivers/usb/gadget/net2280.c:2623: pci_ids causes a section type
conflict
make[2]: *** [drivers/usb/gadget/net2280.o] Error 1
make[1]: *** [drivers/usb/gadget] Error 2
make: *** [drivers] Error 2

I was not able to test this particular part of the code with -mm4, as I
use a single processor system and could not get to the module building
process then.

I have also tested this by compiling it into the kernel, with the same
results:

  gcc -Wp,-MD,drivers/usb/gadget/.net2280.o.d -D__KERNEL__ -Iinclude
-Wall -Wstrict-prototypes -Wno-trigraphs -O2 -fno-strict-aliasing
-fno-common -pipe -mpreferred-stack-boundary=2 -march=i686
-Iinclude/asm-i386/mach-default -fomit-frame-pointer -nostdinc
-iwithprefix include    -DKBUILD_BASENAME=net2280
-DKBUILD_MODNAME=net2280 -c -o drivers/usb/gadget/net2280.o
drivers/usb/gadget/net2280.c
drivers/usb/gadget/net2280.c:2623: pci_ids causes a section type
conflict
make[2]: *** [drivers/usb/gadget/net2280.o] Error 1
make[1]: *** [drivers/usb/gadget] Error 2
make: *** [drivers] Error 2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
