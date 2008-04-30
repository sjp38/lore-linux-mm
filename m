Date: Wed, 30 Apr 2008 12:16:23 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: 2.6.25-mm1: Failing to probe IDE interface
Message-ID: <20080430111622.GB10831@csn.ul.ie>
References: <20080417160331.b4729f0c.akpm@linux-foundation.org> <20080429154957.GA19148@csn.ul.ie> <20080429165840.GA24125@csn.ul.ie> <200804292337.57874.bzolnier@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <200804292337.57874.bzolnier@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Cc: ink@jurassic.park.msu.ru, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, gregkh@suse.de
List-ID: <linux-mm.kvack.org>

On (29/04/08 23:37), Bartlomiej Zolnierkiewicz didst pronounce:
> > <SNIP>
> > 
> > The third patch that needed reverting was
> > gregkh-pci-pci-clean-up-resource-alignment-management.patch (owners added
> > to cc). The relevant hint in the a diff between a broken and working bootlog was;
> > 
> >  system 00:09: ioport range 0x15e0-0x15ef has been reserved
> > + PCI: bogus alignment of resource 7 [100:1ff] (flags 100) of 0000:00:02.0
> > + PCI: bogus alignment of resource 8 [100:1ff] (flags 100) of 0000:00:02.0
> > + PCI: bogus alignment of resource 9 [4000000:7ffffff] (flags 1200) of 0000:00:02.0
> > + PCI: bogus alignment of resource 10 [4000000:7ffffff] (flags 200) of 0000:00:02.0
> > + PCI: bogus alignment of resource 7 [100:1ff] (flags 100) of 0000:00:02.1
> > + PCI: bogus alignment of resource 8 [100:1ff] (flags 100) of 0000:00:02.1
> > + PCI: bogus alignment of resource 9 [4000000:7ffffff] (flags 1200) of 0000:00:02.1
> > + PCI: bogus alignment of resource 10 [4000000:7ffffff] (flags 200) of 0000:00:02.1
> > 
> > With the resource alignment patch and the two IDE patches reverted, the
> > laptop is able to boot.
> 
> Thanks for tracking it down.
> 
> Hmm, it seems that the above patch was merged a week ago:
> 
> commit bda0c0afa7a694bb1459fd023515aca681e4d79a
> Merge: 904e0ab... af40b48...
> Author: Linus Torvalds <torvalds@linux-foundation.org>
> Date:   Mon Apr 21 15:58:35 2008 -0700
> 
>     Merge git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/pci-2.6
> ...
>       PCI: clean up resource alignment management
> ...
> 
> but it could be that the issue has been already fixed in git tree
> (could you verify it please?).
> 

Latest git boots on the laptop so somewhere along the line, it got fixed.

> BTW according to lspci output you should be able to use piix driver
> instead of ide_generic on this laptop.
> 

I know but the config is a bit minimal for faster building as it's only
intended for sniff-testing patches.

Thanks for the help.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
