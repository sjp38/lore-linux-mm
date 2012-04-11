Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id B13316B004A
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 07:55:30 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so762737vcb.14
        for <linux-mm@kvack.org>; Wed, 11 Apr 2012 04:55:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALWz4iyZauXcfuepN6SE9bQpPXp5dH0XvXh6zByO_uNdWTt9ow@mail.gmail.com>
References: <1334000524-23972-1-git-send-email-yinghan@google.com>
	<CAJd=RBD6Sb4zmUkMTaT12cgwFLAQYmh6HuK1hLMa_Dda6FHBLQ@mail.gmail.com>
	<CALWz4iyZauXcfuepN6SE9bQpPXp5dH0XvXh6zByO_uNdWTt9ow@mail.gmail.com>
Date: Wed, 11 Apr 2012 19:55:29 +0800
Message-ID: <CAJd=RBDk6-FDoaj7Ly4Cw4WoEq3tLCjmZ01vZRQgXGCyFdVDhA@mail.gmail.com>
Subject: Re: [PATCH] Revert "mm: vmscan: fix misused nr_reclaimed in shrink_mem_cgroup_zone()"
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Wed, Apr 11, 2012 at 12:44 AM, Ying Han <yinghan@google.com> wrote:
>
> There are two places where we do early break out in direct reclaim path.
>
> 1. For each priority loop after calling shrink_zones(), we check
> (sc->nr_reclaimed >= sc->nr_to_reclaim)
>
> 2. For each memcg reclaim (shrink_mem_cgroup_zone) under
> shrink_zone(), we check (nr_reclaimed >= nr_to_reclaim)
>
> The second one says "if 32 (nr_to_reclaim) pages being reclaimed from
> this memcg under high priority, break". This check is necessary here
> to prevent over pressure each memcg under shrink_zone().
>
> Regarding the reverted patch, it tries to convert the "nr_reclaimed"
> to "total_reclaimed" for outer loop (restart). First of all, it
> changes the logic by doing less work each time
> should_continue_reclaim() is true. Second, the fix is simply broken by
> decrementing nr_to_reclaim each time.
>
Got, thanks:)

-hd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
