Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1AF646B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 14:17:48 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id n5FIIAbD009479
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 23:48:10 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5FIHx9G950432
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 23:47:59 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n5FIHxhV012815
	for <linux-mm@kvack.org>; Tue, 16 Jun 2009 04:17:59 +1000
Date: Mon, 15 Jun 2009 23:47:53 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/10] Fix page_mkwrite() for blocksize < pagesize
	(version 3)
Message-ID: <20090615181753.GA26615@skywalker>
References: <1245088797-29533-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1245088797-29533-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 07:59:47PM +0200, Jan Kara wrote:
> 
> patches below are an attempt to solve problems filesystems have with
> page_mkwrite() when blocksize < pagesize (see the changelog of the second patch
> for details).
> 
> Could someone please review them so that they can get merged - especially the
> generic VFS/MM part? It fixes observed problems (WARN_ON triggers) for ext4 and
> makes ext2/ext3 behave more nicely (mmapped write getting page fault instead
> of silently discarding data).


Will you be able to send it as two series.

a) One that fix the blocksize < page size bug
b) making ext2/3 mmaped write give better allocation pattern.

Doing that will make sure (a) can go in this merge window. There are
other ext4 fixes waiting for (a) to be merged in.


> 
> The series is against Linus's tree from today. The differences against previous
> version are one bugfix in ext3 delalloc implementation... Please test and review.
> Thanks.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
