From: "Petr Vandrovec" <VANDROVE@vc.cvut.cz>
Date: Tue, 8 Jul 2003 14:37:14 +0200
MIME-Version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Subject: Re: 2.5.74-mm2 + nvidia (and others)
Message-ID: <6A3BC5C5B2D@vcnet.vc.cvut.cz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christian Axelsson <smiler@lanil.mine.nu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On  8 Jul 03 at 13:35, Christian Axelsson wrote:
> On Tue, 2003-07-08 at 13:23, Flameeyes wrote:
> > On Tue, 2003-07-08 at 13:01, Petr Vandrovec wrote:
> > > vmware-any-any-update35.tar.gz should work on 2.5.74-mm2 too.
> > > But it is not tested, I have enough troubles with 2.5.74 without mm patches...
> > vmnet doesn't compile:
> > 
> > make: Entering directory `/tmp/vmware-config1/vmnet-only'
> > In file included from userif.c:51:
> > pgtbl.h: In function `PgtblVa2PageLocked':
> > pgtbl.h:82: warning: implicit declaration of function `pmd_offset'
> > pgtbl.h:82: warning: assignment makes pointer from integer without a
> > cast
> > make: Leaving directory `/tmp/vmware-config1/vmnet-only'
> 
> I get exactly the same errors. BTW I got these on vanilla 2.5.74 aswell.

Either copy compat_pgtable.h from vmmon to vmnet, or grab
vmware-any-any-update36. I forgot to update vmnet's copy of this file.
                                                Petr Vandrovec
                                                

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
