Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA07849
	for <linux-mm@kvack.org>; Thu, 4 Dec 1997 17:34:38 -0500
Date: Thu, 4 Dec 1997 10:37:02 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: fork: out of memory
In-Reply-To: <199712040152.RAA00762@belvdere.vip.best.com>
Message-ID: <Pine.LNX.3.91.971204103425.6860D-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "David E. Fox" <dfox@belvdere.vip.best.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Dec 1997, David E. Fox wrote:

> > Was that with my patch running, or wery you trying to get it
> > in... On my own system (24Mb) I magaged to compile the kernel
> > with 'make -j5' without any problems...
> 
> Without the patch, i.e., clean 2.1.65 (make bzimage though)
>  
[snip]
> 
> I wrote in the other message that I got it to compile OK. 
> Strangely enough, it failed twice in the same spot (ide.c) which
> I haven't yet experienced. Third time though it worked.

Maybe you should compile in <magic-sysrq> support and try
<sysrq>-M when memory gets tight...
> 
> Strangely enough, I haven't seen any 'cannot fork' messages
> today (yet). I got a slew of them yesterday (over 40 messages
> saying 'cannot fork'). The only real difference is that netscape
> is sitting around. Wierd.
Hmm, strange. You'd expect Netscape to grab loads of memory
so other programs could get even less... Or was it just
'sitting around' and doing nothing:)

grtz,

Rik.

----------
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
