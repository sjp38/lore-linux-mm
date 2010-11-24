Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 83DA16B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 19:13:56 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAO0DsSA017983
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 24 Nov 2010 09:13:54 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D37B445DE5C
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:13:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 84E6645DE56
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:13:53 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FD2DE08001
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:13:53 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CE4811DB805F
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:13:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC 1/2] deactive invalidated pages
In-Reply-To: <87hbf89jfk.fsf@gmail.com>
References: <20101122143817.E242.A69D9226@jp.fujitsu.com> <87hbf89jfk.fsf@gmail.com>
Message-Id: <20101124091249.7BEB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 24 Nov 2010 09:13:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

> On Tue, 23 Nov 2010 16:16:55 +0900 (JST), KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > By Other approach, app developer uses POSIX_FADV_DONTNEED.
> > > But it has a problem. If kernel meets page is writing
> > > during invalidate_mapping_pages, it can't work.
> > > It is very hard for application programmer to use it.
> > > Because they always have to sync data before calling
> > > fadivse(..POSIX_FADV_DONTNEED) to make sure the pages could
> > > be discardable. At last, they can't use deferred write of kernel
> > > so that they could see performance loss.
> > > (http://insights.oetiker.ch/linux/fadvise.html)
> > 
> > If rsync use the above url patch, we don't need your patch. 
> > fdatasync() + POSIX_FADV_DONTNEED should work fine.
> > 
> This is quite true, but the patch itself is fairly invasive and
> unnecessarily so which makes it unsuitable for merging in the eyes of
> the rsync maintainers (not that I can blame them). This is by no fault
> of its author; using fadvise is just far harder than it should be.

Yeah. I agree with this patch don't have negative impact. I was only
curious why Minchan drop autodetect logic.

Please don't think I'm against your effort.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
