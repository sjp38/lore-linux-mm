Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 833D26B0032
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 00:01:03 -0400 (EDT)
Date: Mon, 3 Jun 2013 14:00:38 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: 3.9.4 Oops running xfstests (WAS Re: 3.9.3: Oops running
 xfstests)
Message-ID: <20130603040038.GX29466@dastard>
References: <510292845.4997401.1369279175460.JavaMail.root@redhat.com>
 <986348673.5787542.1369385526612.JavaMail.root@redhat.com>
 <20130527053608.GS29466@dastard>
 <1588848128.8530921.1369885528565.JavaMail.root@redhat.com>
 <20130530052049.GK29466@dastard>
 <1824023060.8558101.1369892432333.JavaMail.root@redhat.com>
 <1462663454.9294499.1369969415681.JavaMail.root@redhat.com>
 <20130531060415.GU29466@dastard>
 <1517224799.10311874.1370228651422.JavaMail.root@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1517224799.10311874.1370228651422.JavaMail.root@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: CAI Qian <caiqian@redhat.com>
Cc: xfs@oss.sgi.com, stable@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sun, Jun 02, 2013 at 11:04:11PM -0400, CAI Qian wrote:
> 
> > There's memory corruption all over the place.  It is most likely
> > that trinity is causing this - it's purpose is to trigger corruption
> > issues, but they aren't always immediately seen.  If you can trigger
> > this xfs trace without trinity having been run and without all the
> > RCU/idle/scheduler/cgroup issues occuring at the same time, then
> > it's likely to be caused by XFS. But right now, I'd say XFS is just
> > an innocent bystander caught in the crossfire. There's nothing I can
> > do from an XFS persepctive to track this down...
> OK, this can be reproduced by just running LTP and then xfstests without
> trinity at all...

Cai, can you be more precise about what is triggering it?  LTP and
xfstests do a large amount of stuff, and stack traces do not do not
help narrow down the cause at all.  Can you provide the follwoing
information and perform the follwoing steps:

	1. What xfstest is tripping over it? 
	2. Can you reproduce it just by running that one specific test
	  on a pristine system (i.e. freshly mkfs'd filesystems,
	  immediately after boot)
	3. if you can't reproduce it like that, does it reproduce on
	  an xfstest run on a pristine system? If so, what command
	  line are you running, and what are the filesystem
	  configurations?
	4. if you cannot reproduce it just with xfstests and you need
	  to run LTP first, then can you just run the xfstest that
	  is failing after running LTP and see if that triggers the
	  problem. If it does, please take a metadump of the
	  filesystems after LTP has run, save them, and if the
	  single test then fails send me the metadumps and your
	  xfstests command line.
	5. If all else fails, bisect the kernel to identify the
	  commit that introduces the problem....

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
