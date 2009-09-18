Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 316386B00F4
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 16:11:17 -0400 (EDT)
Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id n8IK74Zw014771
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 13:07:04 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by zps76.corp.google.com with ESMTP id n8IK6WQF015627
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 13:07:02 -0700
Received: by pzk1 with SMTP id 1so1032016pzk.13
        for <linux-mm@kvack.org>; Fri, 18 Sep 2009 13:07:02 -0700 (PDT)
Date: Fri, 18 Sep 2009 13:06:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/7] hugetlbfs: Allow the creation of files suitable for
 MAP_PRIVATE on the vfs internal mount
In-Reply-To: <0f28cb0d89a7b83f7edf92181c5d13422f5b009c.1253276847.git.ebmunson@us.ibm.com>
Message-ID: <alpine.DEB.1.00.0909181306450.27556@chino.kir.corp.google.com>
References: <653aa659fd7970f7428f4eb41fa10693064e4daf.1253272709.git.ebmunson@us.ibm.com> <0f28cb0d89a7b83f7edf92181c5d13422f5b009c.1253276847.git.ebmunson@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, rdunlap@xenotime.net, michael@ellerman.id.au, ralf@linux-mips.org, wli@holomorphy.com, mel@csn.ul.ie, dhowells@redhat.com, arnd@arndb.de, fengguang.wu@intel.com, shuber2@gmail.com, hugh.dickins@tiscali.co.uk, zohar@us.ibm.com, hugh@veritas.com, mtk.manpages@gmail.com, chris@zankel.net, linux-man@vger.kernel.org, linux-doc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 18 Sep 2009, Eric B Munson wrote:

> There are two means of creating mappings backed by huge pages:
> 
>         1. mmap() a file created on hugetlbfs
>         2. Use shm which creates a file on an internal mount which essentially
>            maps it MAP_SHARED
> 
> The internal mount is only used for shared mappings but there is very
> little that stops it being used for private mappings. This patch extends
> hugetlbfs_file_setup() to deal with the creation of files that will be
> mapped MAP_PRIVATE on the internal hugetlbfs mount. This extended API is
> used in a subsequent patch to implement the MAP_HUGETLB mmap() flag.
> 
> Signed-off-by: Eric Munson <ebmunson@us.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
