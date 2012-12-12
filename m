Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 655226B009D
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 17:08:16 -0500 (EST)
Message-ID: <50C8FFF3.1030206@redhat.com>
Date: Wed, 12 Dec 2012 17:06:43 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 6/8] mm: vmscan: clean up get_scan_count()
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org> <1355348620-9382-7-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1355348620-9382-7-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/12/2012 04:43 PM, Johannes Weiner wrote:
> Reclaim pressure balance between anon and file pages is calculated
> through a tuple of numerators and a shared denominator.
>
> Exceptional cases that want to force-scan anon or file pages configure
> the numerators and denominator such that one list is preferred, which
> is not necessarily the most obvious way:
>
>      fraction[0] = 1;
>      fraction[1] = 0;
>      denominator = 1;
>      goto out;
>
> Make this easier by making the force-scan cases explicit and use the
> fractionals only in case they are calculated from reclaim history.
>
> And bring the variable declarations/definitions in order.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
