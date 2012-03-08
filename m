Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 5F1CA6B002C
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 16:11:07 -0500 (EST)
Date: Thu, 8 Mar 2012 16:10:56 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] hugetlbfs: lockdep annotate root inode properly
Message-ID: <20120308211055.GA12161@redhat.com>
References: <1331198116-13670-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20120308130256.c7855cbd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120308130256.c7855cbd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, jboyer@redhat.com, tyhicks@canonical.com, linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mimi Zohar <zohar@linux.vnet.ibm.com>

On Thu, Mar 08, 2012 at 01:02:56PM -0800, Andrew Morton wrote:

 > >  ======================================================
 > >  [ INFO: possible circular locking dependency detected ]
 > >  3.3.0-rc4+ #190 Not tainted
 > >  -------------------------------------------------------
 > >  shared/1568 is trying to acquire lock:
 > >   (&sb->s_type->i_mutex_key#12){+.+.+.}, at: [<ffffffff811efa0f>] hugetlbfs_file_mmap+0x7d/0x108
 > > 
 > >  but task is already holding lock:
 > >   (&mm->mmap_sem){++++++}, at: [<ffffffff810f5589>] sys_mmap_pgoff+0xd4/0x12f
 > > 
 > >  which lock already depends on the new lock.
 > > 
  > 
 > Why have these lockdep warnings started coming out now - was the VFS
 > changed to newly take i_mutex somewhere in the directory handling?

This has been happening for almost a year!
https://lkml.org/lkml/2011/4/15/272
See also https://lkml.org/lkml/2012/2/16/498

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
