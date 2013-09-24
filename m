Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 35C1F6B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 19:58:52 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id wz12so5198951pbc.39
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 16:58:51 -0700 (PDT)
Date: Tue, 24 Sep 2013 16:58:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv6 00/22] Transparent huge page cache: phase 1,
 everything but mmap()
Message-Id: <20130924165848.4f3ba25b4de236fa746fb7ee@linux-foundation.org>
In-Reply-To: <20130924234950.GC2018@tassilo.jf.intel.com>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20130924163740.4bc7db61e3e520798220dc4c@linux-foundation.org>
	<20130924234950.GC2018@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <ak@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 24 Sep 2013 16:49:50 -0700 Andi Kleen <ak@linux.intel.com> wrote:

> > At the very least we should get this done for a real filesystem to see
> > how intrusive the changes are and to evaluate the performance changes.
> 
> That would give even larger patches, and people already complain
> the patchkit is too large.

The thing is that merging an implementation for ramfs commits us to
doing it for the major real filesystems.  Before making that commitment
we should at least have a pretty good understanding of what those
changes will look like.

Plus I don't see how we can realistically performance-test it without
having real physical backing store in the picture?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
