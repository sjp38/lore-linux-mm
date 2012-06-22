Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 7A4E76B0263
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 17:39:05 -0400 (EDT)
Date: Fri, 22 Jun 2012 14:39:03 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: clear pages_scanned only if draining a pcp adds
 pages to the buddy allocator again
Message-Id: <20120622143903.ea1c6484.akpm@linux-foundation.org>
In-Reply-To: <CAHGf_=rQ6AaZBjfvkWWKi+a5q+1R29_PGWDyD77VFisgJHPQEA@mail.gmail.com>
References: <1339690570-7471-1-git-send-email-kosaki.motohiro@gmail.com>
	<20120622131901.28f273e3.akpm@linux-foundation.org>
	<CAHGf_=rQ6AaZBjfvkWWKi+a5q+1R29_PGWDyD77VFisgJHPQEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

On Fri, 22 Jun 2012 17:10:59 -0400
KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:

> On Fri, Jun 22, 2012 at 4:19 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Thu, 14 Jun 2012 12:16:10 -0400
> > kosaki.motohiro@gmail.com wrote:
> >
> >> commit 2ff754fa8f (mm: clear pages_scanned only if draining a pcp adds pages
> >> to the buddy allocator again) fixed one free_pcppages_bulk() misuse. But two
> >> another miuse still exist.
> >
> > This changelog is irritating. __One can understand it a bit if one
> > happens to have a git repo handy (and why do this to the reader?), but
> > the changelog for 2ff754fa8f indicates that the patch might fix a
> > livelock. __Is that true of this patch? __Who knows...
> 
> The code in this simple patch speak the right usage, isn't it?

It depends who is listening.

Please, put yourself in the position of poor-scmuck@linux-distro.com
who is reading your patch and wondering whether it will fix some
customer bug report he is working on.  Or wondering whether he should
backport it into his company's next kernel release.  He simply won't be
able to do this with the information which was provided here.  And if
we don't tell him, who will?

> And yes,
> this patch also fixes a possibility of live lock. (but i haven't seen actual
> live lock cause from this mistake)

hrm, I guess I'll put it in the 3.6 pile.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
