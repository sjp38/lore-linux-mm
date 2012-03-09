Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id C68716B004D
	for <linux-mm@kvack.org>; Fri,  9 Mar 2012 00:01:20 -0500 (EST)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 9 Mar 2012 05:51:46 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q294tMLd3698860
	for <linux-mm@kvack.org>; Fri, 9 Mar 2012 15:55:27 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q295126W021705
	for <linux-mm@kvack.org>; Fri, 9 Mar 2012 16:01:04 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] hugetlbfs: lockdep annotate root inode properly
In-Reply-To: <20120308141938.1d04afb7.akpm@linux-foundation.org>
References: <1331198116-13670-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120308130256.c7855cbd.akpm@linux-foundation.org> <20120308211926.GB6546@boyd> <20120308134050.f53a0b2f.akpm@linux-foundation.org> <20120308214951.GB23916@ZenIV.linux.org.uk> <20120308141938.1d04afb7.akpm@linux-foundation.org>
Date: Fri, 09 Mar 2012 10:30:53 +0530
Message-ID: <87y5ra8j22.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ZenIV.linux.org.uk>
Cc: Tyler Hicks <tyhicks@canonical.com>, linux-mm@kvack.org, davej@redhat.com, jboyer@redhat.com, linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mimi Zohar <zohar@linux.vnet.ibm.com>, David Gibson <david@gibson.dropbear.id.au>

On Thu, 8 Mar 2012 14:19:38 -0800, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Thu, 8 Mar 2012 21:49:52 +0000
> Al Viro <viro@ZenIV.linux.org.uk> wrote:
> 
> > > So we need to pull the i_mutex out of hugetlbfs_file_mmap().
> > 
> > IIRC, you have a patch in your tree doing just that...
> 
> Nope.
> 
> But it seems that you've recently seen such a patch - can you recall
> where?  Or was it the ecryptfs thing?
> 

So what we ended up doing was

http://article.gmane.org/gmane.linux.kernel.mm/74732

The patch update hugetlbfs_read to not take i_mutex. That should make
sure deadlock won't happen. 


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
