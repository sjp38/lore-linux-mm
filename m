Received: by wr-out-0506.google.com with SMTP id m59so242402wrm
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 14:28:25 -0700 (PDT)
Message-ID: <2c0942db0707251428r7a6a1cc9seea8dc59020f1bcb@mail.gmail.com>
Date: Wed, 25 Jul 2007 14:28:24 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: -mm merge plans for 2.6.23
In-Reply-To: <1185396952.9409.5.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <46A58B49.3050508@yahoo.com.au>
	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	 <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>
	 <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm>
	 <46A6DFFD.9030202@gmail.com>
	 <2c0942db0707250902v58e23d52v434bde82ba28f119@mail.gmail.com>
	 <1185396952.9409.5.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zan Lynx <zlynx@acm.org>
Cc: Rene Herman <rene.herman@gmail.com>, david@lang.hm, Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 7/25/07, Zan Lynx <zlynx@acm.org> wrote:
> On Wed, 2007-07-25 at 09:02 -0700, Ray Lee wrote:
>
> > I'd just like updatedb to amortize its work better. If we had some way
> > to track all filesystem events, updatedb could keep a live and
> > accurate index on the filesystem. And this isn't just updatedb that
> > wants that, beagle and tracker et al also want to know filesystem
> > events so that they can index the documents themselves as well as the
> > metadata. And if they do it live, that spreads the cost out, including
> > the VM pressure.
>
> That would be nice.  It'd be great if there was a per-filesystem inotify
> mode.  I can't help but think it'd be more efficient than recursing
> every directory and adding a watch.
>
> Or maybe a netlink thing that could buffer events since filesystem mount
> until a daemon could get around to starting, so none were lost.

See "Filesystem Event Reporter" by Yi Yang, that does pretty much
exactly that. http://lkml.org/lkml/2006/9/30/98 . Author had things to
update, never resubmitted it as far as I can tell.

Ray

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
