Received: by ik-out-1112.google.com with SMTP id c28so196171ika
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 09:02:57 -0700 (PDT)
Message-ID: <2c0942db0707250902v58e23d52v434bde82ba28f119@mail.gmail.com>
Date: Wed, 25 Jul 2007 09:02:56 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: -mm merge plans for 2.6.23
In-Reply-To: <46A6DFFD.9030202@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <46A57068.3070701@yahoo.com.au>
	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <46A58B49.3050508@yahoo.com.au>
	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	 <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>
	 <Pine.LNX.4.64.0707242211210.2229@asgard.lang.hm>
	 <46A6DFFD.9030202@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rene Herman <rene.herman@gmail.com>
Cc: david@lang.hm, Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 7/24/07, Rene Herman <rene.herman@gmail.com> wrote:
> Yes, but what's locate's usage scenario? I've never, ever wanted to use it.
> When do you know the name of something but not where it's located, other
> than situations which "which" wouldn't cover and after just having
> installed/unpacked something meaning locate doesn't know about it yet either?

I use it to find source files and documents all the time. One of my
work boxes has <runs a locate work | wc -l> ~38500 files and
directories under my source directory. And then there's the "I wrote
that tech doc two years ago, where was that. Hmm, what did I name it?
Bet it had 323 in the name, and doc in the path."

I'd just like updatedb to amortize its work better. If we had some way
to track all filesystem events, updatedb could keep a live and
accurate index on the filesystem. And this isn't just updatedb that
wants that, beagle and tracker et al also want to know filesystem
events so that they can index the documents themselves as well as the
metadata. And if they do it live, that spreads the cost out, including
the VM pressure.

Ray

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
