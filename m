Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 44E716B0085
	for <linux-mm@kvack.org>; Sun, 24 Oct 2010 18:52:50 -0400 (EDT)
Received: by iwn9 with SMTP id 9so3774207iwn.14
        for <linux-mm@kvack.org>; Sun, 24 Oct 2010 15:52:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1287787911-4257-1-git-send-email-msb@chromium.org>
References: <1287787911-4257-1-git-send-email-msb@chromium.org>
Date: Mon, 25 Oct 2010 07:52:47 +0900
Message-ID: <AANLkTinWp-M4S5EXz6-xJvHAnzdk96_5+d2OJVjCycsm@mail.gmail.com>
Subject: Re: [PATCH] vmscan: move referenced VM_EXEC pages to active list
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mandeep Singh Baines <msb@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, Shaohua Li <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Sat, Oct 23, 2010 at 7:51 AM, Mandeep Singh Baines <msb@chromium.org> wrote:
> In commit 64574746, "vmscan: detect mapped file pages used only once",
> Johannes Weiner, added logic to page_check_reference to cycle again
> used once pages.
>
> In commit 8cab4754, "vmscan: make mapped executable pages the first
> class citizen", Wu Fengguang, added logic to shrink_active_list which
> protects file-backed VM_EXEC pages by keeping them in the active_list if
> they are referenced.
>
> This patch adds logic to move such pages from the inactive list to the
> active list immediately if they have been referenced. If a VM_EXEC page
> is seen as referenced during an inactive list scan, that reference must
> have occurred after the page was put on the inactive list. There is no
> need to wait for the page to be referenced again.
>
> Change-Id: I17c312e916377e93e5a92c52518b6c829f9ab30b
> Signed-off-by: Mandeep Singh Baines <msb@chromium.org>

It seems to be similar to http://www.spinics.net/lists/linux-mm/msg09617.html.
I don't know what it is going. Shaohua?



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
