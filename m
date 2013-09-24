Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id D6C3D6B0031
	for <linux-mm@kvack.org>; Tue, 24 Sep 2013 19:37:44 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so5280239pdj.12
        for <linux-mm@kvack.org>; Tue, 24 Sep 2013 16:37:44 -0700 (PDT)
Date: Tue, 24 Sep 2013 16:37:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv6 00/22] Transparent huge page cache: phase 1,
 everything but mmap()
Message-Id: <20130924163740.4bc7db61e3e520798220dc4c@linux-foundation.org>
In-Reply-To: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 23 Sep 2013 15:05:28 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> It brings thp support for ramfs, but without mmap() -- it will be posted
> separately.

We were never going to do this :(

Has anyone reviewed these patches much yet?

> Please review and consider applying.

It appears rather too immature at this stage.

> Intro
> -----
> 
> The goal of the project is preparing kernel infrastructure to handle huge
> pages in page cache.
> 
> To proof that the proposed changes are functional we enable the feature
> for the most simple file system -- ramfs. ramfs is not that useful by
> itself, but it's good pilot project.

At the very least we should get this done for a real filesystem to see
how intrusive the changes are and to evaluate the performance changes.


Sigh.  A pox on whoever thought up huge pages.  Words cannot express
how much of a godawful mess they have made of Linux MM.  And it hasn't
ended yet :( My take is that we'd need to see some very attractive and
convincing real-world performance numbers before even thinking of
taking this on.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
