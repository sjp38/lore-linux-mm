Date: Wed, 2 Jan 2008 18:53:26 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: why do we call clear_active_flags in shrink_inactive_list ?
Message-ID: <20080102185326.66a3a883@bree.surriel.com>
In-Reply-To: <44c63dc40712292332s4a2e7e4aief37a2dbdd03fc21@mail.gmail.com>
References: <44c63dc40712292332s4a2e7e4aief37a2dbdd03fc21@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: minchan Kim <barrioskmc@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 30 Dec 2007 16:32:42 +0900
"minchan Kim" <barrioskmc@gmail.com> wrote:

> In 2.6.23's shrink_inactive_list function, why do we have to call
> clear_active_flags after isolate_lru_pages call ?
> IMHO, If it call isolate_lru_pages with "zone->inactive_list", It can
> be sure that it is not PG_active. 

If we call isolate_lru_pages with mode = ISOLATE_BOTH, then it
can return both active and inactive pages and the calling function
has to be able to deal with both kinds of pages.

ISOLATE_BOTH is used when the kernel is trying to defragment memory,
for larger physically contiguous allocations.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
