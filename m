Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4AD22900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 00:01:14 -0400 (EDT)
Received: by pvg4 with SMTP id 4so1258261pvg.14
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 21:01:11 -0700 (PDT)
Subject: Re: [PATCH] shmem: factor out remove_indirect_page()
From: Namhyung Kim <namhyung@gmail.com>
In-Reply-To: <BANLkTin4mOMZqq4Sg04hj8Ep2XiCcZOBLg@mail.gmail.com>
References: <1302524879-4737-1-git-send-email-namhyung@gmail.com>
	 <BANLkTin4mOMZqq4Sg04hj8Ep2XiCcZOBLg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 15 Apr 2011 13:01:04 +0900
Message-ID: <1302840064.1537.14.camel@leonhard>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

2011-04-14 (ea(C)), 18:27 -0700, Hugh Dickins:
> On Mon, Apr 11, 2011 at 5:27 AM, Namhyung Kim <namhyung@gmail.com> wrote:
> > Split out some common code in shmem_truncate_range() in order to
> > improve readability (hopefully) and to reduce code duplication.
> >
> > Signed-off-by: Namhyung Kim <namhyung@gmail.com>
> 
> Thank you for taking the trouble to do this.
> 
> However... all that shmem_swp index code is irredeemably unreadable
> (my fault, dating from when I converted it to use highmem with kmaps),
> and I'd rather leave it untouched until we simply delete it
> completely.
> 
> I have a patch/set (good for my testing but not yet good for final
> submission) which removes all that code, and the need to allocate
> shmem_swp index pages (even when CONFIG_SWAP is not set!): instead
> saving the swp_entries in the standard pagecache radix_tree for the
> file, so no extra allocations are needed at all.
> 
> It is possible that my patch/set will not be accepted (extending the
> radix_tree in that way may meet some resistance); but I do think
> that's the right way forward.
> 

Looks reasonable. Please feel free to ignore this then, I'll look
forward to your patches.

Thanks.


-- 
Regards,
Namhyung Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
