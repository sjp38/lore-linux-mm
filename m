Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 682A56B0087
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 09:57:41 -0500 (EST)
Received: by qyk4 with SMTP id 4so1653951qyk.14
        for <linux-mm@kvack.org>; Tue, 23 Nov 2010 06:57:39 -0800 (PST)
From: Ben Gamari <bgamari@gmail.com>
Subject: Re: [RFC 1/2] deactive invalidated pages
In-Reply-To: <20101122143817.E242.A69D9226@jp.fujitsu.com>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com> <20101122143817.E242.A69D9226@jp.fujitsu.com>
Date: Tue, 23 Nov 2010 09:57:35 -0500
Message-ID: <87hbf89jfk.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Nov 2010 16:16:55 +0900 (JST), KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > By Other approach, app developer uses POSIX_FADV_DONTNEED.
> > But it has a problem. If kernel meets page is writing
> > during invalidate_mapping_pages, it can't work.
> > It is very hard for application programmer to use it.
> > Because they always have to sync data before calling
> > fadivse(..POSIX_FADV_DONTNEED) to make sure the pages could
> > be discardable. At last, they can't use deferred write of kernel
> > so that they could see performance loss.
> > (http://insights.oetiker.ch/linux/fadvise.html)
> 
> If rsync use the above url patch, we don't need your patch. 
> fdatasync() + POSIX_FADV_DONTNEED should work fine.
> 
This is quite true, but the patch itself is fairly invasive and
unnecessarily so which makes it unsuitable for merging in the eyes of
the rsync maintainers (not that I can blame them). This is by no fault
of its author; using fadvise is just far harder than it should be.

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
