Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 0AA2E6B005A
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 08:09:32 -0400 (EDT)
Message-ID: <4A782C61.4030809@redhat.com>
Date: Tue, 04 Aug 2009 15:41:05 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/12] ksm: five little cleanups
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils> <Pine.LNX.4.64.0908031314070.16754@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0908031314070.16754@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> 1. We don't use __break_cow entry point now: merge it into break_cow.
> 2. remove_all_slot_rmap_items is just a special case of
>    remove_trailing_rmap_items: use the latter instead.
> 3. Extend comment on unmerge_ksm_pages and rmap_items.
> 4. try_to_merge_two_pages should use try_to_merge_with_ksm_page
>    instead of duplicating its code; and so swap them around.
> 5. Comment on cmp_and_merge_page described last year's: update it.
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
>
>
>   
Acked-by: Izik Eidus <ieidus@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
