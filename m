Received: by ug-out-1314.google.com with SMTP id c2so538704ugf
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 18:32:49 -0700 (PDT)
Message-ID: <2c0942db0707251832i542249d5ve0006b3db0374678@mail.gmail.com>
Date: Wed, 25 Jul 2007 18:32:48 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
In-Reply-To: <b21f8390707251815o767590acrf6a6c4d7290a26a8@mail.gmail.com>
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
	 <b21f8390707251815o767590acrf6a6c4d7290a26a8@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Hawkins <darthmdh@gmail.com>
Cc: linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/25/07, Matthew Hawkins <darthmdh@gmail.com> wrote:
> On 7/26/07, Ray Lee <ray-lk@madrabbit.org> wrote:
> > I'd just like updatedb to amortize its work better. If we had some way
> > to track all filesystem events, updatedb could keep a live and
> > accurate index on the filesystem. And this isn't just updatedb that
> > wants that, beagle and tracker et al also want to know filesystem
> > events so that they can index the documents themselves as well as the
> > metadata. And if they do it live, that spreads the cost out, including
> > the VM pressure.
>
> We already have this, its called inotify (and if I'm not mistaken,
> beagle already uses it).

Yeah, I know about inotify, but it doesn't scale.

ray@phoenix:~$ find ~ -type d | wc -l
17933
ray@phoenix:~$

That's not fun with inotify, and that's just my home directory. The
vast majority of those are quiet the vast majority of the time, which
is the crux of the problem, and why inotify isn't a great fit for
on-demand virus scanners or indexers.

Ray

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
