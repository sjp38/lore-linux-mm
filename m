Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f43.google.com (mail-vb0-f43.google.com [209.85.212.43])
	by kanga.kvack.org (Postfix) with ESMTP id F007A6B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 19:25:18 -0500 (EST)
Received: by mail-vb0-f43.google.com with SMTP id p5so6594794vbn.30
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 16:25:18 -0800 (PST)
Received: from mail-ve0-x233.google.com (mail-ve0-x233.google.com [2607:f8b0:400c:c01::233])
        by mx.google.com with ESMTPS id cy15si6651263veb.30.2014.02.11.16.25.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 16:25:18 -0800 (PST)
Received: by mail-ve0-f179.google.com with SMTP id jx11so6879086veb.10
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 16:25:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140211235816.A2B50E0090@blue.fi.intel.com>
References: <1392087957-15730-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20140211133956.ef8b9417ed09651fbcf6d3a9@linux-foundation.org>
	<CA+55aFx+-ynTnj2ycq6JFo56bo978n6ZjB6LBue-jb0ipw1tXg@mail.gmail.com>
	<20140211235816.A2B50E0090@blue.fi.intel.com>
Date: Tue, 11 Feb 2014 16:25:17 -0800
Message-ID: <CA+55aFyNmux-1dT0ADr24mVwCVRxL2CNXo9HLTgTh3dLD_pAcg@mail.gmail.com>
Subject: Re: [RFC, PATCH 0/2] mm: map few pages around fault address if they
 are in page cache
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm <linux-mm@kvack.org>

On Tue, Feb 11, 2014 at 3:58 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> Linus Torvalds wrote:
>
> It's on top of v3.14-rc1 + __do_fault() claen up[1].
>
> It's also on git:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux fault_around/v1
>
> [1] http://thread.gmane.org/gmane.linux.kernel.mm/113364

Ok, that patch-series looks good to me too.

And I still see nothing wrong that would cause it not to boot. I think
the "do_async_mmap_readahead()" in lock_secondary_pages() is silly and
shouldn't really be done, but I don't think it should cause any
problems per se, it just feels very wrong to do that inside the loop.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
