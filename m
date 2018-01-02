Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B6BDB6B02CD
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 17:42:25 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 61so30979767plz.1
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 14:42:25 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id v8si34588750plg.491.2018.01.02.14.42.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Jan 2018 14:42:24 -0800 (PST)
Message-ID: <1514932941.4018.12.camel@HansenPartnership.com>
Subject: Re: [PATCH] mm for mmotm: Revert skip swap cache feture for
 synchronous device
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Tue, 02 Jan 2018 14:42:21 -0800
In-Reply-To: <20180102132214.289b725cf00ac07d91e8f60b@linux-foundation.org>
References: <1514508907-10039-1-git-send-email-minchan@kernel.org>
	 <20180102132214.289b725cf00ac07d91e8f60b@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, kernel-team <kernel-team@lge.com>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ilya Dryomov <idryomov@gmail.com>, Jens Axboe <axboe@kernel.dk>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Huang Ying <ying.huang@intel.com>

On Tue, 2018-01-02 at 13:22 -0800, Andrew Morton wrote:
> On Fri, 29 Dec 2017 09:55:07 +0900 Minchan Kim <minchan@kernel.org>
> wrote:
> 
> > 
> > James reported a bug of swap paging-in for his testing and found it
> > at rc5, soon to be -rc5.
> > 
> > Although we can fix the specific problem at the moment, it may
> > have other lurkig bugs so want to have one more cycle in -next
> > before merging.
> > 
> > This patchset reverts 23c47d2ada9f, 08fa93021d80, 8e31f339295f
> > completely
> > but 79b5f08fa34e partially because the swp_swap_info function that
> > 79b5f08fa34e introduced is used by [1].
> 
> Gets a significant reject in do_swap_page().A A Could you please take a
> look, redo against current mainline?
> 
> Or not.A A We had a bug and James fixed it.A A That's what -rc is
> for.A A Why not fix the thing and proceed?

My main worry was lack of testing at -rc5, since the bug could
essentially be excited by pushing pages out to swap and then trying to
access them again ... plus since one serious bug was discovered it
wouldn't be unusual for there to be others. A However, because of the
IPT stuff, I think Linus is going to take 4.15 over a couple of extra
-rc releases, so this is less of a problem.

> There's still James's "unaccountable shutdown delay".A A Is that still
> present?A A Is it possible to see whether the full revert patch fixes
> it?

On -rc6 it's no longer manifesting with just the bug fix applied, so it
might have been a -rc5 artifact.

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
