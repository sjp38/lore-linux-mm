Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 08DE66B0036
	for <linux-mm@kvack.org>; Tue, 12 Mar 2013 12:53:51 -0400 (EDT)
Date: Tue, 12 Mar 2013 12:53:47 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: Swap defragging
Message-ID: <20130312165347.GC1953@cmpxchg.org>
References: <CAGDaZ_rvfrBVCKMuEdPcSod684xwbUf9Aj4nbas4_vcG3V9yfg@mail.gmail.com>
 <20130308023511.GD23767@cmpxchg.org>
 <513D4768.8050703@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <513D4768.8050703@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Raymond Jennings <shentino@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Mar 11, 2013 at 10:54:32AM +0800, Ric Mason wrote:
> Hi Johannes,
> On 03/08/2013 10:35 AM, Johannes Weiner wrote:
> >On Thu, Mar 07, 2013 at 06:07:23PM -0800, Raymond Jennings wrote:
> >>Just a two cent question, but is there any merit to having the kernel
> >>defragment swap space?
> >That is a good question.
> >
> >Swap does fragment quite a bit, and there are several reasons for
> >that.
> >
> >We swap pages in our LRU list order, but this list is sorted by first
> >access, not by access frequency (not quite that cookie cutter, but the
> >ordering is certainly fairly coarse).  This means that the pages may
> >already be in suboptimal order for swap in at the time of swap out.
> >
> >Once written to disk, the layout tends to stick.  One reason is that
> >we actually try to not free swap slots unless there is a shortage of
> 
> If all the swap slots will be freed when swapoff?

Well, yeah, but that's hardly an interesting case, is it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
