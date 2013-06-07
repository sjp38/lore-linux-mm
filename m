Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 1D8CD6B0033
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 10:16:10 -0400 (EDT)
Message-ID: <51B1EB25.9000509@yandex-team.ru>
Date: Fri, 07 Jun 2013 18:16:05 +0400
From: Roman Gushchin <klamm@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [patch 09/10] mm: thrash detection-based file cache sizing
References: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org> <1369937046-27666-10-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1369937046-27666-10-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, metin d <metdos@yahoo.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On 30.05.2013 22:04, Johannes Weiner wrote:
> +/*
> + * Monotonic workingset clock for non-resident pages.
> + *
> + * The refault distance of a page is the number of ticks that occurred
> + * between that page's eviction and subsequent refault.
> + *
> + * Every page slot that is taken away from the inactive list is one
> + * more slot the inactive list would have to grow again in order to
> + * hold the current non-resident pages in memory as well.
> + *
> + * As the refault distance needs to reflect the space missing on the
> + * inactive list, the workingset time is advanced every time the
> + * inactive list is shrunk.  This means eviction, but also activation.
> + */
> +static atomic_long_t workingset_time;

It seems strange to me, that workingset_time is global.
Don't you want to make it per-cgroup?

Two more questions:
1) do you plan to take fadvise's into account somehow?
2) do you plan to use workingset information to enhance
	the readahead mechanism?

Thanks!

Regards,
Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
