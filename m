Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id A71EF6B0034
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 00:29:09 -0400 (EDT)
Date: Tue, 4 Jun 2013 14:29:05 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: 3.9.4 Oops running xfstests (WAS Re: 3.9.3: Oops running
 xfstests)
Message-ID: <20130604042905.GG29466@dastard>
References: <510292845.4997401.1369279175460.JavaMail.root@redhat.com>
 <1588848128.8530921.1369885528565.JavaMail.root@redhat.com>
 <20130530052049.GK29466@dastard>
 <1824023060.8558101.1369892432333.JavaMail.root@redhat.com>
 <1462663454.9294499.1369969415681.JavaMail.root@redhat.com>
 <20130531060415.GU29466@dastard>
 <1517224799.10311874.1370228651422.JavaMail.root@redhat.com>
 <20130603040038.GX29466@dastard>
 <1317567060.11044929.1370315696270.JavaMail.root@redhat.com>
 <20130604041617.GF29466@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130604041617.GF29466@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, xfs@oss.sgi.com

On Tue, Jun 04, 2013 at 02:16:18PM +1000, Dave Chinner wrote:
> On Mon, Jun 03, 2013 at 11:14:56PM -0400, CAI Qian wrote:
> > [  102.312909] =============================================================================
> > [  102.312910] RSP: 0018:ffff88007d083e08  EFLAGS: 00010003
> > [  102.312912] BUG kmalloc-1024 (Tainted: G      D     ): Padding overwritten. 0xffff88005b4e7ec0-0xffff88005b4e7fff
> > [  102.312913] RAX: ffff88005b656288 RBX: ffff880079b43c80 RCX: 00000000000000a7
> > [  102.312914] -----------------------------------------------------------------------------
> 
> And a memory overwrite.
> 
> > [  102.313009] Padding ffff88005b4e7ec0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> > [  102.313010] Padding ffff88005b4e7ed0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> > [  102.313011] Padding ffff88005b4e7ee0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> > [  102.313013] Padding ffff88005b4e7ef0: 00 00 00 00 00 00 00 00 00 00 00 00 00 29 01 00  .............)..
> > [  102.313014] Padding ffff88005b4e7f00: 07 1b 04 73 65 6c 69 6e 75 78 73 79 73 74 65 6d  ...selinuxsystem
> > [  102.313015] Padding ffff88005b4e7f10: 5f 75 3a 6f 62 6a 65 63 74 5f 72 3a 75 73 72 5f  _u:object_r:usr_
> > [  102.313032] Padding ffff88005b4e7f20: 74 3a 73 30 00 00 00 00 49 4e 81 a4 02 02 00 00  t:s0....IN......
> > [  102.313033] Padding ffff88005b4e7f30: 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00  ................
> > [  102.313033] Padding ffff88005b4e7f40: 00 00 00 00 00 00 00 02 51 47 09 00 00 00 00 00  ........QG......
> > [  102.313043] Padding ffff88005b4e7f50: 51 47 09 00 00 00 00 00 51 ac 1e 27 21 f1 4e ad  QG......Q..'!.N.
> > [  102.313043] Padding ffff88005b4e7f60: 00 00 00 00 00 00 00 f2 00 00 00 00 00 00 00 01  ................
> > [  102.313044] Padding ffff88005b4e7f70: 00 00 00 00 00 00 00 01 00 00 0e 01 00 00 00 00  ................
> > [  102.313053] Padding ffff88005b4e7f80: 00 00 00 00 c1 6d 78 44 ff ff ff ff 00 00 00 00  .....mxD........
> > [  102.313054] Padding ffff88005b4e7f90: 00 00 00 00 00 00 08 10 36 a0 00 01 00 00 00 00  ........6.......
> > [  102.313062] Padding ffff88005b4e7fa0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> > [  102.313063] Padding ffff88005b4e7fb0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> > [  102.313072] Padding ffff88005b4e7fc0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> > [  102.313073] Padding ffff88005b4e7fd0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> > [  102.313074] Padding ffff88005b4e7fe0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> > [  102.313082] Padding ffff88005b4e7ff0: 00 00 00 00 00 00 00 00 00 00 00 00 00 29 01 00  .............)..
> 
> Oh, look, that contains attributes, and being at the top of a page,
> that tallies with the attribute code copying data from the top of
> the block down....

On second thoughts, I'm not so sure of this now. That actually has
an inode core in it (the bit starting from "IN"), so it can't be a
piece of code from the attribute compaction. So this piece of memory
has been used several times by different things before the overwrite
has triggered by the look of it.

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
