Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 309F96B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 16:59:51 -0400 (EDT)
Message-ID: <4F6A40E8.30601@redhat.com>
Date: Wed, 21 Mar 2012 16:58:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: avoid CONFIG_MMU=n build failure in pmd_none_or_trans_huge_or_clear_bad
References: <1332361711-26612-1-git-send-email-aarcange@redhat.com>
In-Reply-To: <1332361711-26612-1-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Larry Woodman <lwoodman@redhat.com>, Ulrich Obergfell <uobergfe@redhat.com>, Mark Salter <msalter@redhat.com>

On 03/21/2012 04:28 PM, Andrea Arcangeli wrote:
> pmd_none_or_trans_huge_or_clear_bad must be defined after
> pmd_trans_huge, so add #ifdef CONFIG_MMU around the whole block that
> shall not be needed for archs without pagetables.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>
> Reported-by: Mark Salter<msalter@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
