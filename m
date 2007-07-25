Message-ID: <46A6EB32.70402@yahoo.com.au>
Date: Wed, 25 Jul 2007 16:18:26 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [ck] Re: -mm merge plans for 2.6.23
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	 <200707102015.44004.kernel@kolivas.org>	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>	 <46A57068.3070701@yahoo.com.au>	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>	 <46A58B49.3050508@yahoo.com.au>	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>	 <46A6CC56.6040307@yahoo.com.au> <b21f8390707242309r4a925737p777e507e473df1ab@mail.gmail.com>
In-Reply-To: <b21f8390707242309r4a925737p777e507e473df1ab@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Hawkins <darthmdh@gmail.com>
Cc: Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Matthew Hawkins wrote:
> On 7/25/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> 
>> I'm not saying that we can't try to tackle that problem, but first of
>> all you have a really nice narrow problem where updatedb seems to be
>> causing the kernel to completely do the wrong thing. So we start on
>> that.
> 
> 
> updatedb isn't the only problem, its just an obvious one.  I like the
> idea of looking into the vfs for this and other one-shot applications
> (rather than looking at updatedb itself specifically)

That's the point, it is an obvious one. So it should be easy to work
out why it is going wrong, and fix it. (And hopefully that fixes some
of the less obvious problems too.)


> Many modern applications have a lot of open file handles.  For
> example, I just fired up my usual audio player and sys/fs/file-nr
> showed another 600 open files (funnily enough, I have roughly that
> many audio files :)  I'm not exactly sure what happens when this one
> gets swapped out for whatever reason (firefox/java/vmware/etc chews
> ram, updatedb, whatever) but I'm fairly confident what happens between
> kswapd and the vfs and whatever else we're caching is not optimal come
> time for this process to context-switch back in.  We're not running a
> highly-optimised number-crunching scientific app on desktops, we're
> running a full herd of poorly-coded hogs simultaneously through
> smaller pens.

And yet nobody wants to take the time to properly analyse why these
things are going wrong and reporting their findings? Or if they have,
where is that documented?

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
