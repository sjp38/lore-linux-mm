Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 8BDAF8D0004
	for <linux-mm@kvack.org>; Sun, 24 Oct 2010 20:44:25 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9P0iNxg009533
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 25 Oct 2010 09:44:23 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2938645DE51
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 09:44:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E50245DE4C
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 09:44:23 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EA3CD1DB8016
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 09:44:22 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A58621DB8014
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 09:44:22 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: move referenced VM_EXEC pages to active list
In-Reply-To: <AANLkTinWp-M4S5EXz6-xJvHAnzdk96_5+d2OJVjCycsm@mail.gmail.com>
References: <1287787911-4257-1-git-send-email-msb@chromium.org> <AANLkTinWp-M4S5EXz6-xJvHAnzdk96_5+d2OJVjCycsm@mail.gmail.com>
Message-Id: <20101025094235.9154.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 25 Oct 2010 09:44:21 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mandeep Singh Baines <msb@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, Shaohua Li <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

> On Sat, Oct 23, 2010 at 7:51 AM, Mandeep Singh Baines <msb@chromium.org> wrote:
> > In commit 64574746, "vmscan: detect mapped file pages used only once",
> > Johannes Weiner, added logic to page_check_reference to cycle again
> > used once pages.
> >
> > In commit 8cab4754, "vmscan: make mapped executable pages the first
> > class citizen", Wu Fengguang, added logic to shrink_active_list which
> > protects file-backed VM_EXEC pages by keeping them in the active_list if
> > they are referenced.
> >
> > This patch adds logic to move such pages from the inactive list to the
> > active list immediately if they have been referenced. If a VM_EXEC page
> > is seen as referenced during an inactive list scan, that reference must
> > have occurred after the page was put on the inactive list. There is no
> > need to wait for the page to be referenced again.
> >
> > Change-Id: I17c312e916377e93e5a92c52518b6c829f9ab30b
> > Signed-off-by: Mandeep Singh Baines <msb@chromium.org>
> 
> It seems to be similar to http://www.spinics.net/lists/linux-mm/msg09617.html.
> I don't know what it is going. Shaohua?

Hi Mandeep,

Yeah, if you have enough time, can you please consider to join this testing? or can you
please explain your interactivity experience if there is.

Thanks.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
