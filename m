Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 50C1E6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 05:00:34 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1AA0VJ1025221
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 10 Feb 2009 19:00:31 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E27E45DD71
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 19:00:31 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F03C45DD70
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 19:00:31 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 83EB61DB803E
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 19:00:31 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 34E121DB803A
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 19:00:28 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch] vmscan: rename sc.may_swap to may_unmap
In-Reply-To: <28c262360902091502w5555528bt8e61e6c288aeff76@mail.gmail.com>
References: <20090209194309.GA8491@cmpxchg.org> <28c262360902091502w5555528bt8e61e6c288aeff76@mail.gmail.com>
Message-Id: <20090210185936.6FD2.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 10 Feb 2009 19:00:27 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: MinChan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, Feb 10, 2009 at 4:43 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > sc.may_swap does not only influence reclaiming of anon pages but pages
> > mapped into pagetables in general, which also includes mapped file
> > pages.
> >
> > From shrink_page_list():
> >
> >                if (!sc->may_swap && page_mapped(page))
> >                        goto keep_locked;
> >
> > For anon pages, this makes sense as they are always mapped and
> > reclaiming them always requires swapping.
> >
> > But mapped file pages are skipped here as well and it has nothing to
> > do with swapping.
> >
> > The real effect of the knob is whether mapped pages are unmapped and
> > reclaimed or not.  Rename it to `may_unmap' to have its name match its
> > actual meaning more precisely.
> >
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  mm/vmscan.c |   20 ++++++++++----------
> >  1 file changed, 10 insertions(+), 10 deletions(-)
> 
> It looks good to me. :)
> 
> Reviewed-by: MinChan Kim <minchan.kim@gmail.com>

me too :)

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
