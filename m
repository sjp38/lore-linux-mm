Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE3546B02C6
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 16:22:18 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id 80so23852wmb.7
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 13:22:18 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y60si31291766wrb.428.2018.01.02.13.22.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jan 2018 13:22:17 -0800 (PST)
Date: Tue, 2 Jan 2018 13:22:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm for mmotm: Revert skip swap cache feture for
 synchronous device
Message-Id: <20180102132214.289b725cf00ac07d91e8f60b@linux-foundation.org>
In-Reply-To: <1514508907-10039-1-git-send-email-minchan@kernel.org>
References: <1514508907-10039-1-git-send-email-minchan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, James Bottomley <James.Bottomley@hansenpartnership.com>, kernel-team <kernel-team@lge.com>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ilya Dryomov <idryomov@gmail.com>, Jens Axboe <axboe@kernel.dk>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Huang Ying <ying.huang@intel.com>

On Fri, 29 Dec 2017 09:55:07 +0900 Minchan Kim <minchan@kernel.org> wrote:

> James reported a bug of swap paging-in for his testing and found it
> at rc5, soon to be -rc5.
> 
> Although we can fix the specific problem at the moment, it may
> have other lurkig bugs so want to have one more cycle in -next
> before merging.
> 
> This patchset reverts 23c47d2ada9f, 08fa93021d80, 8e31f339295f completely
> but 79b5f08fa34e partially because the swp_swap_info function that
> 79b5f08fa34e introduced is used by [1].

Gets a significant reject in do_swap_page().  Could you please take a
look, redo against current mainline?

Or not.  We had a bug and James fixed it.  That's what -rc is for.  Why
not fix the thing and proceed?

There's still James's "unaccountable shutdown delay".  Is that still
present?  Is it possible to see whether the full revert patch fixes it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
