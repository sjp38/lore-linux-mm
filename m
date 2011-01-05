Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B923B6B0088
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 03:44:02 -0500 (EST)
Date: Wed, 5 Jan 2011 09:43:57 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC]
 /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
Message-ID: <20110105084357.GA21349@tiehlicka.suse.cz>
References: <20110104105214.GA10759@tiehlicka.suse.cz>
 <907929848.134962.1294203162923.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <907929848.134962.1294203162923.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

[Let's CC Andrew to pick up the patch - please see bellow]

On Tue 04-01-11 23:52:42, CAI Qian wrote:
> ----- Original Message -----
> > On Tue 04-01-11 05:21:46, CAI Qian wrote:
> > >
> > > > > 3) overcommit 2gb hugepages.
> > > > > mmap(NULL, 18446744071562067968, PROT_READ|PROT_WRITE,
> > > > > MAP_SHARED,
> > > > > 3, 0) = -1 ENOMEM (Cannot allocate memory)
> > > >
> > > > Hmm, you are trying to reserve/mmap a lot of memory (17179869182
> > > > 1GB
> > > > huge pages).
> > > That is strange - the test code merely did this,
> > > addr = mmap(ADDR, 2<<30, PROTECTION, FLAGS, fd, 0);
> > 
> > Didn't you want 1<<30 instead?
> No, it was expecting to use both the allocate + overcommited 1GB pages.

Then you propably wanted 2*1UL<<30 rather than 2<<30 which is something
different than you want, I guess. Anyway this is not related to the
bogus value in nr_overcommit_hugepages after your testcase.
