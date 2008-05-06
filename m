Received: by wa-out-1112.google.com with SMTP id m28so672942wag.8
        for <linux-mm@kvack.org>; Mon, 05 May 2008 18:01:26 -0700 (PDT)
Message-ID: <2f11576a0805051801xf144478pb7b04799f148db29@mail.gmail.com>
Date: Tue, 6 May 2008 10:01:26 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [-mm][PATCH 4/5] core of reclaim throttle
In-Reply-To: <20080505204318.3f95c83c@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080504201343.8F52.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080504215819.8F5E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080504221043.8F64.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080505175142.7de3f27b@cuia.bos.redhat.com>
	 <2f11576a0805051523h730fce0foa51f1fdbf9c46cbe@mail.gmail.com>
	 <20080505204318.3f95c83c@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > hmmm, AFAIK,
>  > on current kernel, sometimes __GFP_IO task wait for non __GFP_IO task
>  > by lock_page().
>  > Is this wrong?
>
>  This is fine.
>
>  The problem is adding a code path that causes non __GFP_IO tasks to
>  wait on __GFP_IO tasks.  Then you can have a deadlock.

Ah, OK.
I'll add __GFP_FS and __GFP_IO check at next post.

Thanks!


>  > therefore my patch care only recursive reclaim situation.
>  > I don't object to your opinion. but I hope understand exactly your opinion.
>
>  I believe not all non __GFP_IO or non __GFP_FS calls are recursive
>  reclaim, but there are some other code paths too.  For example from
>  fs/buffer.c

absolutely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
