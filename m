Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 533F16B005A
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 08:31:39 -0400 (EDT)
Message-ID: <4A78319D.9030002@redhat.com>
Date: Tue, 04 Aug 2009 16:03:25 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 8/12] ksm: distribute remove_mm_from_lists
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils> <Pine.LNX.4.64.0908031316180.16754@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0908031316180.16754@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> Do some housekeeping in ksm.c, to help make the next patch easier
> to understand: remove the function remove_mm_from_lists, distributing
> its code to its callsites scan_get_next_rmap_item and __ksm_exit.
>
> That turns out to be a win in scan_get_next_rmap_item: move its
> remove_trailing_rmap_items and cursor advancement up, and it becomes
> simpler than before.  __ksm_exit becomes messier, but will change
> again; and moving its remove_trailing_rmap_items up lets us strengthen
> the unstable tree item's age condition in remove_rmap_item_from_tree.
>
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
>
>   
Acked-by: Izik Eidus <ieidus@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
