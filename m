Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BJsnqF021857
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 15:54:49 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BJsaKW161100
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 13:54:41 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BJsZf4021267
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 13:54:35 -0600
Subject: Re: [PATCH] shm: Fix the filename of hugetlb sysv shared memory
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20070611111111.2345470d.akpm@linux-foundation.org>
References: <787b0d920706062027s5a8fd35q752f8da5d446afc@mail.gmail.com>
	 <20070606204432.b670a7b1.akpm@linux-foundation.org>
	 <787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com>
	 <20070607162004.GA27802@vino.hallyn.com>
	 <m1ir9zrtwe.fsf@ebiederm.dsl.xmission.com> <46697EDA.9000209@us.ibm.com>
	 <m1vedyqaft.fsf_-_@ebiederm.dsl.xmission.com>
	 <20070611111111.2345470d.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Mon, 11 Jun 2007 12:55:33 -0700
Message-Id: <1181591733.22665.5.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, "Serge E. Hallyn" <serge@hallyn.com>, Albert Cahalan <acahalan@gmail.com>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-06-11 at 11:11 -0700, Andrew Morton wrote:
> On Fri, 08 Jun 2007 17:43:34 -0600
> ebiederm@xmission.com (Eric W. Biederman) wrote:
> 
> > Some user space tools need to identify SYSV shared memory when
> > examining /proc/<pid>/maps.  To do so they look for a block device
> > with major zero, a dentry named SYSV<sysv key>, and having the minor of
> > the internal sysv shared memory kernel mount.
> > 
> > To help these tools and to make it easier for people just browsing
> > /proc/<pid>/maps this patch modifies hugetlb sysv shared memory to
> > use the SYSV<key> dentry naming convention.
> > 
> > User space tools will still have to be aware that hugetlb sysv
> > shared memory lives on a different internal kernel mount and so
> > has a different block device minor number from the rest of sysv
> > shared memory.
> 
> So..  I am sitting here believing that this patch and Badari's
> restore-shmid-as-inode-to-fix-proc-pid-maps-abi-breakage.patch are both
> needed in 2.6.22 and that they will fix all these issues up.
> 
> If that is untrue, someone please let us know..

Andrew,

My restore-shmid-as-inode-to-fix-proc-pid-maps-abi-breakage.patch is
definitely needed for 2.6.22 to fix ABI issue.

Eric's patch goes beyond and provides same naming convention for
hugetlbfs backed shm segs (which we never did in the past). So,
its not absolutely need for 2.6.22. You can queue up for next 
release,  unless Albert really wants to extend proc-ps utils for
hugetlbfs segments too.

But, its very simple patch - you might as well push this too.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
