Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 095F46B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 19:49:53 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so4371304pad.30
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 16:49:53 -0700 (PDT)
Date: Tue, 24 Sep 2013 16:49:50 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCHv6 00/22] Transparent huge page cache: phase 1, everything
 but mmap()
Message-ID: <20130924234950.GC2018@tassilo.jf.intel.com>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20130924163740.4bc7db61e3e520798220dc4c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130924163740.4bc7db61e3e520798220dc4c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 24, 2013 at 04:37:40PM -0700, Andrew Morton wrote:
> On Mon, 23 Sep 2013 15:05:28 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > It brings thp support for ramfs, but without mmap() -- it will be posted
> > separately.
> 
> We were never going to do this :(
> 
> Has anyone reviewed these patches much yet?

There already was a lot of review by various people.

This is not the first post, just the latest refactoring.

> > Intro
> > -----
> > 
> > The goal of the project is preparing kernel infrastructure to handle huge
> > pages in page cache.
> > 
> > To proof that the proposed changes are functional we enable the feature
> > for the most simple file system -- ramfs. ramfs is not that useful by
> > itself, but it's good pilot project.
> 
> At the very least we should get this done for a real filesystem to see
> how intrusive the changes are and to evaluate the performance changes.

That would give even larger patches, and people already complain
the patchkit is too large.

The only good way to handle this is baby steps, and you 
have to start somewhere.

> Sigh.  A pox on whoever thought up huge pages. 

managing 1TB+ of memory in 4K chunks is just insane.
The question of larger pages is not "if", but only "when".

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
