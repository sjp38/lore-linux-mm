Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F34656B002D
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 19:08:09 -0400 (EDT)
Received: by iaen33 with SMTP id n33so5546097iae.14
        for <linux-mm@kvack.org>; Thu, 06 Oct 2011 16:08:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111006145445.ed8d6dbb.akpm@linux-foundation.org>
References: <cover.1321112552.git.minchan.kim@gmail.com>
	<20111006145445.ed8d6dbb.akpm@linux-foundation.org>
Date: Fri, 7 Oct 2011 08:07:59 +0900
Message-ID: <CAEwNFnD1ExGDonb6ew75Th+WVH003+JUUJznPjXOcq3VhsLtNg@mail.gmail.com>
Subject: Re: [PATCH 0/3] Fix compaction about mlocked pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>

Hi Andrew,

On Fri, Oct 7, 2011 at 6:54 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Sun, 13 Nov 2011 01:37:40 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> This patch's goal is to enable mlocked page migration.
>> The compaction can migrate mlocked page to get a contiguous memory unlike lumpy.
>>
>
> This patch series appears to be a resend of stuff I already have.
>
> Given the various concerns which were voiced during review of
> mm-compaction-compact-unevictable-pages.patch and the uncertainty of
> the overall usefulness of the feature, I'm inclined to drop
>
> mm-compaction-compact-unevictable-pages.patch
> mm-compaction-compact-unevictable-pages-checkpatch-fixes.patch
> mm-compaction-accounting-fix.patch
>
> for now, OK?
>

It's okay on mm-compaction-compact-unevictable-pages.patch.
On mm-compaction-accounting-fix.patch, we still need it but I need to
change title as Mel commented out and I will send further patche which
changes stat names(https://lkml.org/lkml/2011/9/2/3) with it. So let's
drop it all.
I will resend further patches after rc-1.

Thanks, Andrew.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
