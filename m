Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8597760021B
	for <linux-mm@kvack.org>; Thu, 31 Dec 2009 03:43:42 -0500 (EST)
Date: Thu, 31 Dec 2009 08:43:39 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 2/3 -mmotm-2009-12-10-17-19] Count zero page as
 file_rss
In-Reply-To: <28c262360912301841r3ed43d31yc677fbc3a01fe5bb@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.0912310833560.26642@sister.anvils>
References: <ceeec51bdc2be64416e05ca16da52a126b598e17.1258773030.git.minchan.kim@gmail.com>  <ae2928fe7bb3d94a7ca18d3b3274fdfeb009803a.1258773030.git.minchan.kim@gmail.com>  <4B38876F.6010204@gmail.com>  <alpine.LSU.2.00.0912301619500.3369@sister.anvils>
 <28c262360912301841r3ed43d31yc677fbc3a01fe5bb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 31 Dec 2009, Minchan Kim wrote:
> On Thu, Dec 31, 2009 at 1:49 AM, Hugh Dickins
> <hugh.dickins@tiscali.co.uk> wrote:
> >
> > You are right that I completely overlooked the issue of whether to
> > include the ZERO_PAGE in rss counts (now being a !vm_normal_page,
> > it was just natural to leave it out); and I overlooked the fact that
> > it used to be counted into file_rss in the old days (being !PageAnon).
> >
> > So I'm certainly at fault for that, and thank you for bringing the
> > issue to attention; but once considered, I can't actually see a good
> > reason why we should add code to count ZERO_PAGEs into file_rss now.
> > And if this patch falls, then 1/3 and 3/3 would fall also.
> >
> > And the patch below would be incomplete anyway, wouldn't it?
> > There would need to be a matching change to zap_pte_range(),
> > but I don't see that.
> 
> Thanks.
> If we think this patch is need, I will repost path with fix it.
> 
> What do you think?

If someone comes up with a convincing case in which their system
is behaving significantly worse because the zero page is not being
counted in rss now, then we shall probably want your patch.

But I still don't yet see a reason to add code just to keep the
anon_rss+file_rss number looking the same as it was before, in this
exceptional case where there's a significant number of zero pages.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
