Date: Mon, 2 Feb 2004 17:50:44 +0100
From: Roger Luethi <rl@hellgate.ch>
Subject: Re: VM benchmarks
Message-ID: <20040202165044.GA8156@k3.hellgate.ch>
References: <401D8D64.8010605@cyberone.com.au> <20040201160818.1499be18.akpm@osdl.org> <401D95C2.3080208@cyberone.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <401D95C2.3080208@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 02 Feb 2004 11:11:46 +1100, Nick Piggin wrote:
> efax is a compilation as well. I would be up for trying it, but it

The main advantage of efax over kbuild is that it is completely immune
to unfairness. And it used to have a low variance (in 2.4). Other than
that, access patterns are similar enough to make me suspect that gcc
loads are all quite similar.

> needs quite a lot of GUI dev libraries installed to compile it.
>
> I'll get onto it sometime I suppose, but for now I'll try to leave
> my test box unchanged.

You can actually do something like which shouldn't require the
dependencies on the test box:

/usr/lib/gcc-lib/i586-pc-linux-gnu/3.2.3/cc1plus -fpreprocessed efaxi586.ii \
-quiet -O2 -Wall -fexceptions -frtti -fsigned-char -fno-check-new -o main.s

All you need is the preprocessed code.


I can test a couple of patches I you care, though. Which ones?

Roger
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
