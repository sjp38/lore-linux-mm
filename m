Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C62616B002D
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 16:59:35 -0500 (EST)
Message-ID: <4ECAC9C8.5040202@redhat.com>
Date: Mon, 21 Nov 2011 16:59:36 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/8] mm: compaction: avoid overwork in migrate sync mode
References: <1321635524-8586-1-git-send-email-mgorman@suse.de> <1321732460-14155-6-git-send-email-aarcange@redhat.com>
In-Reply-To: <1321732460-14155-6-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, linux-kernel@vger.kernel.org

On 11/19/2011 02:54 PM, Andrea Arcangeli wrote:
> Add a lightweight sync migration (sync == 2) mode that avoids overwork
> so more suitable to be used by compaction to provide lower latency but

> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -552,7 +552,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
>   		nr_migrate = cc->nr_migratepages;
>   		err = migrate_pages(&cc->migratepages, compaction_alloc,
>   				(unsigned long)cc, false,
> -				cc->sync);
> +				cc->sync ? 2 : 0);

Great idea, but it would be good if these numbers got
a symbolic name so people trying to learn the code can
figure it out a little easier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
