Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 438996B0069
	for <linux-mm@kvack.org>; Tue, 14 Oct 2014 01:15:30 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id rd3so7126432pab.20
        for <linux-mm@kvack.org>; Mon, 13 Oct 2014 22:15:29 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id yn9si12089493pac.118.2014.10.13.22.15.27
        for <linux-mm@kvack.org>;
        Mon, 13 Oct 2014 22:15:29 -0700 (PDT)
Date: Tue, 14 Oct 2014 14:15:55 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v4] zsmalloc: merge size_class to reduce fragmentation
Message-ID: <20141014051554.GA3692@js1304-P5Q-DELUXE>
References: <1411976727-29421-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20140929231022.GC18318@bbox>
 <20141002053949.GC7433@js1304-P5Q-DELUXE>
 <20141002054426.GA4515@bbox>
 <CALZtONAX0sXvynpWvg+MNayhNnoh=F2vc=MCQLEovfiU6x-HuA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONAX0sXvynpWvg+MNayhNnoh=F2vc=MCQLEovfiU6x-HuA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Minchan Kim <minchan.kim@lge.com>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, juno.choi@lge.com, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Luigi Semenzato <semenzato@google.com>, "seungho1.park" <seungho1.park@lge.com>, Nitin Gupta <ngupta@vflare.org>

On Thu, Oct 02, 2014 at 10:47:51AM -0400, Dan Streetman wrote:
> >> I think that using ref would makes intuitive code. Although there is
> >> some memory overhead, it is really small. So I prefer to this way.
> >>
> >> But, if you think that removing ref is better, I will do it.
> >> Please let me know your final decision.
> >
> > Yeb, please remove the ref. I want to keep size_class small for
> > cache footprint.
> 
> i think a foreach_size_class() would be useful for zs_destroy_pool(),
> and in case any other size class iterations are added in the future,
> and it wouldn't require the extra ref field.  You can use the fact
> that all merged size classes contain a class->index of the
> highest/largest size_class (because they all point to the same size
> class).  So something like:

Hello,

Using class->index looks good idea, but, I'd like not to add new
macro here, because, it isn't needed in other place now.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
