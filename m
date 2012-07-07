Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 00DEA6B0074
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 20:38:27 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so18610324pbb.14
        for <linux-mm@kvack.org>; Fri, 06 Jul 2012 17:38:27 -0700 (PDT)
Date: Sat, 7 Jul 2012 09:38:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: don't invoke __alloc_pages_direct_compact when order
 0
Message-ID: <20120707003819.GA2041@barrios>
References: <1341588521-17744-1-git-send-email-js1304@gmail.com>
 <20120706155920.GA7721@barrios>
 <CAAmzW4N+-xS65-NDJF2V9nzGDBTFC=20sZ8LJx5wCZ8=t7SpTQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4N+-xS65-NDJF2V9nzGDBTFC=20sZ8LJx5wCZ8=t7SpTQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Jul 07, 2012 at 01:58:24AM +0900, JoonSoo Kim wrote:
> 2012/7/7 Minchan Kim <minchan@kernel.org>:
> > Hi Joonsoo,
> >
> > On Sat, Jul 07, 2012 at 12:28:41AM +0900, Joonsoo Kim wrote:
> >> __alloc_pages_direct_compact has many arguments so invoking it is very costly.
> >
> > It's already slow path so it's pointless for such optimization.
> 
> I know this is so minor optimization.
> But why don't we do such a one?
> Is there any weak point?

Let's think about it.
You are adding *new rule* for minor optimization.
If new users uses __alloc_pages_direct_compact in future, they always have to
check whether order is zero not not. So it could increase code size as well as
bad for readbility. Even, I'm not sure adding branch is always win than
just passing the some arguement in all architecures.

> 
> >> And in almost invoking case, order is 0, so return immediately.
> >
> > You can't make sure it.
> 
> Okay.
> 
> >>
> >> Let's not invoke it when order 0
> >
> > Let's not ruin git blame.
> 
> Hmm...
> When I do git blame, I can't find anything related to this.

I mean if we merge the pointless patch, it could be showed firstly instead of
meaningful patch when we do git blame. It makes us bothering when we find blame-patch.

> 
> Thanks for comments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
