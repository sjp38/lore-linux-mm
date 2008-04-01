Date: Tue, 1 Apr 2008 08:25:43 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/7] mm: introduce VM_MIXEDMAP
Message-ID: <20080401062543.GA29864@wotan.suse.de>
References: <20080328015238.519230000@nick.local0.net> <20080328015421.905848000@nick.local0.net> <20080331150426.20d57ddb.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080331150426.20d57ddb.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: torvalds@linux-foundation.org, jaredeh@gmail.com, cotte@de.ibm.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 31, 2008 at 03:04:26PM -0700, Andrew Morton wrote:
> On Fri, 28 Mar 2008 12:52:39 +1100
> npiggin@suse.de wrote:
> 
> > From: npiggin@suse.de
> > From: Jared Hulbert <jaredeh@gmail.com>
> > To: akpm@linux-foundation.org
> > Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jared Hulbert <jaredeh@gmail.com>, Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org
> > Subject: [patch 1/7] mm: introduce VM_MIXEDMAP
> > Date: 	Fri, 28 Mar 2008 12:52:39 +1100
> > Sender: owner-linux-mm@kvack.org
> > User-Agent: quilt/0.46-14
> 
> It's unusual to embed the original author's From: line in the headers
> like that - it is usually placed in the message body and this arrangement
> might fool some people's scripts.

Hmm, OK. I guess either quilt or my sendmbox script messed up.

 
> patch 6/7 was subtly hidden, concatenated to 5/7, but I found it.

Oh? :( That came out of quilt send as well... I guess it is my
script. Thanks for untangling it.


> [7/7] needs to be redone please - git-s390 makes functional changes to
> add_shared_memory().

I'll let one of the s390 folk send you a patch when they feel like
it.

Regarding the lockless get_user_pages patches... it would be nice to
get them into -mm as well. They haven't had as much review as these
patches, but at least they did survive an OLTP run at IBM, so they
should be OK to sit in -mm I think (unless you have to many clashes).

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
