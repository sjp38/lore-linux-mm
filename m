Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id DDA8B6B0044
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 18:54:29 -0500 (EST)
Message-ID: <4B0C71F0.3000209@redhat.com>
Date: Tue, 24 Nov 2009 18:53:20 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/9] ksm: fix mlockfreed to munlocked
References: <Pine.LNX.4.64.0911241634170.24427@sister.anvils> <Pine.LNX.4.64.0911241638130.25288@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0911241638130.25288@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11/24/2009 11:40 AM, Hugh Dickins wrote:
> When KSM merges an mlocked page, it has been forgetting to munlock it:
> that's been left to free_page_mlock(), which reports it in /proc/vmstat
> as unevictable_pgs_mlockfreed instead of unevictable_pgs_munlocked (and
> whinges "Page flag mlocked set for process" in mmotm, whereas mainline
> is silently forgiving).  Call munlock_vma_page() to fix that.
>
> Signed-off-by: Hugh Dickins<hugh.dickins@tiscali.co.uk>
>
>    
Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
