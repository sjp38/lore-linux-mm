Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8E0E96B016A
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 20:12:17 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 554073EE0BD
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 09:12:14 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3A8D445DE8A
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 09:12:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D74645DE7E
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 09:12:14 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F19D1DB803E
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 09:12:14 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CB9571DB802C
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 09:12:13 +0900 (JST)
Date: Tue, 9 Aug 2011 09:04:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] vmscan: activate executable pages after first usage
Message-Id: <20110809090455.92901845.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAEwNFnBojMWL1QRfn_buhwUwMOBRGSUGdWBgmzdt9vsCVmLFmQ@mail.gmail.com>
References: <20110808110658.31053.55013.stgit@localhost6>
	<20110808110659.31053.92935.stgit@localhost6>
	<CAEwNFnBojMWL1QRfn_buhwUwMOBRGSUGdWBgmzdt9vsCVmLFmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, 9 Aug 2011 09:02:28 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Mon, Aug 8, 2011 at 8:07 PM, Konstantin Khlebnikov
> <khlebnikov@openvz.org> wrote:
> > Logic added in commit v2.6.30-5507-g8cab475
> > (vmscan: make mapped executable pages the first class citizen)
> > was noticeably weakened in commit v2.6.33-5448-g6457474
> > (vmscan: detect mapped file pages used only once)
> >
> > Currently these pages can become "first class citizens" only after second usage.
> >
> > After this patch page_check_references() will activate they after first usage,
> > and executable code gets yet better chance to stay in memory.
> >
> > TODO:
> > run some cool tests like in v2.6.30-5507-g8cab475 =)
> >
> > Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> > ---
> 
> It might be a very controversial topic.
> AFAIR, at least, we did when vmscan: make mapped executable pages the
> first class citizen was merged. :)
> 
> You try to change behavior.
> 
> Old : protect *working set* executable page
> New: protect executable page *unconditionally*.
> 

Hmm ? I thought 
Old: protect pages if referenced twice
New: protect executable page if referenced once.

IIUC, ANON is proteced if it's referenced once.

So, this patch changes EXECUTABLE file to the same class as ANON pages.

Anyway, I agree test/measurement is required.

Thanks,
-Kame









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
