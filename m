Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5EDA86B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 05:51:13 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so5849267pdj.16
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 02:51:13 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20130924163740.4bc7db61e3e520798220dc4c@linux-foundation.org>
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20130924163740.4bc7db61e3e520798220dc4c@linux-foundation.org>
Subject: Re: [PATCHv6 00/22] Transparent huge page cache: phase 1, everything
 but mmap()
Content-Transfer-Encoding: 7bit
Message-Id: <20130925095105.06464E0090@blue.fi.intel.com>
Date: Wed, 25 Sep 2013 12:51:04 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Andrew Morton wrote:
> On Mon, 23 Sep 2013 15:05:28 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > It brings thp support for ramfs, but without mmap() -- it will be posted
> > separately.
> 
> We were never going to do this :(
> 
> Has anyone reviewed these patches much yet?

Dave did very good review. Few other people looked to separate patches.
See Reviewed-by/Acked-by tags in patches.

It looks like most mm experts are busy with numa balancing nowadays, so
it's hard to get more review.

The patchset was mostly ignored for few rounds and Dave suggested to split
to have less scary patch number.

> > Please review and consider applying.
> 
> It appears rather too immature at this stage.

More review is always welcome and I'm committed to address issues.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
