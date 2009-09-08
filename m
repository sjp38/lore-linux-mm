Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 469D96B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 15:00:05 -0400 (EDT)
Message-ID: <4AA6A989.60907@redhat.com>
Date: Tue, 08 Sep 2009 14:59:21 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/8] mm: FOLL_DUMP replace FOLL_ANON
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils> <Pine.LNX.4.64.0909072233240.15430@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0909072233240.15430@sister.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jeff Chua <jeff.chua.linux@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> The "FOLL_ANON optimization" and its use_zero_page() test have caused
> confusion and bugs: why does it test VM_SHARED? for the very good but
> unsatisfying reason that VMware crashed without.  As we look to maybe
> reinstating anonymous use of the ZERO_PAGE, we need to sort this out.
> 
> Easily done: it's silly for __get_user_pages() and follow_page() to
> be guessing whether it's safe to assume that they're being used for
> a coredump (which can take a shortcut snapshot where other uses must
> handle a fault) - just tell them with GUP_FLAGS_DUMP and FOLL_DUMP.
> 
> get_dump_page() doesn't even want a ZERO_PAGE: an error suits fine.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
