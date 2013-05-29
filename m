Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id C5BA16B0132
	for <linux-mm@kvack.org>; Wed, 29 May 2013 18:08:13 -0400 (EDT)
Date: Wed, 29 May 2013 15:08:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: page_alloc: fix watermark check in
 __zone_watermark_ok()
Message-Id: <20130529150811.3d4d9a55f704e95be64c7b52@linux-foundation.org>
In-Reply-To: <CAH9JG2U7787jzqdnr1Z7kZbyEUvHZJG_XZiPENGJQVENsqVDTA@mail.gmail.com>
References: <518B5556.4010005@samsung.com>
	<519FCC46.2000703@codeaurora.org>
	<CAH9JG2U7787jzqdnr1Z7kZbyEUvHZJG_XZiPENGJQVENsqVDTA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kmpark@infradead.org>
Cc: Laura Abbott <lauraa@codeaurora.org>, Tomasz Stanislawski <t.stanislaws@samsung.com>, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, minchan@kernel.org, mgorman@suse.de, 'Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>

On Sat, 25 May 2013 13:32:02 +0900 Kyungmin Park <kmpark@infradead.org> wrote:

> > I haven't seen any response to this patch but it has been of some benefit
> > to some of our use cases. You're welcome to add
> >
> > Tested-by: Laura Abbott <lauraa@codeaurora.org>
> >
> 
> Thanks Laura,
> We already got mail from Andrew, it's merged mm tree.

Yes, but I have it scheduled for 3.11 with no -stable backport.

This is because the patch changelog didn't tell me about the
userspace-visible impact of the bug.  Judging from Laura's comments, this
was a mistake.

So please: details.  What problems were observable to Laura and do we
think this bug should be fixed in 3.10 and earlier?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
