Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 7F8D36B0002
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 03:15:49 -0400 (EDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MNT0050M2RPNJ00@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 03 Jun 2013 08:15:47 +0100 (BST)
Message-id: <51AC429A.3030104@samsung.com>
Date: Mon, 03 Jun 2013 09:15:38 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] mm: page_alloc: fix watermark check in
 __zone_watermark_ok()
References: <518B5556.4010005@samsung.com> <519FCC46.2000703@codeaurora.org>
 <CAH9JG2U7787jzqdnr1Z7kZbyEUvHZJG_XZiPENGJQVENsqVDTA@mail.gmail.com>
 <20130529150811.3d4d9a55f704e95be64c7b52@linux-foundation.org>
In-reply-to: <20130529150811.3d4d9a55f704e95be64c7b52@linux-foundation.org>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kyungmin Park <kmpark@infradead.org>, Laura Abbott <lauraa@codeaurora.org>, Tomasz Stanislawski <t.stanislaws@samsung.com>, linux-mm@kvack.org, minchan@kernel.org, mgorman@suse.de, 'Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

Hello,

On 5/30/2013 12:08 AM, Andrew Morton wrote:
> On Sat, 25 May 2013 13:32:02 +0900 Kyungmin Park <kmpark@infradead.org> wrote:
>
> > > I haven't seen any response to this patch but it has been of some benefit
> > > to some of our use cases. You're welcome to add
> > >
> > > Tested-by: Laura Abbott <lauraa@codeaurora.org>
> > >
> >
> > Thanks Laura,
> > We already got mail from Andrew, it's merged mm tree.
>
> Yes, but I have it scheduled for 3.11 with no -stable backport.
>
> This is because the patch changelog didn't tell me about the
> userspace-visible impact of the bug.  Judging from Laura's comments, this
> was a mistake.
>
> So please: details.  What problems were observable to Laura and do we
> think this bug should be fixed in 3.10 and earlier?

This patch fixes issue introduced in commit 
d95ea5d18e699515468368415c93ed49b1a3221b,
so if possible, I suggest to get it backported to v3.7-v3.10 releases as 
well.

Best regards
-- 
Marek Szyprowski
Samsung R&D Institute Poland


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
