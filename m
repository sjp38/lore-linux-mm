Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 92D0C6B004D
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 10:21:10 -0500 (EST)
Date: Wed, 21 Dec 2011 10:21:01 -0500
From: Ted Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] vmalloc: remove #ifdef in function body
Message-ID: <20111221152101.GD24863@thunk.org>
References: <1324444679-9247-1-git-send-email-minchan@kernel.org>
 <1324445481.20505.7.camel@joe2Laptop>
 <20111221054531.GB28505@barrios-laptop.redhat.com>
 <1324447099.21340.6.camel@joe2Laptop>
 <op.v6ttagny3l0zgt@mpn-glaptop>
 <1324449156.21735.7.camel@joe2Laptop>
 <op.v6tug3vi3l0zgt@mpn-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <op.v6tug3vi3l0zgt@mpn-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Joe Perches <joe@perches.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 21, 2011 at 07:47:17AM +0100, Michal Nazarewicz wrote:
> This patch that you pointed to is against a??#ifdefs are uglya?? style
> described in Documentation/SubmittingPatches.
> 
> >If it's not in coding style, I suggest
> >it should be changed if it doesn't
> >add some other useful value.
> 
> That my be true.  I guess no one took time to adding it to the document.

Like all things, judgement is required.  Some of the greatest artists
know when it's OK (and in fact, a good thing) to break the rules.
Beethoven, for example, broke the rules when he added a chorus of
singers to his 9th Symphony.  Take a look at Bach's chorales,
universally acknowledged to be works of genius.  Yet there Bach has
occasionally double thirds, crossed voices, and engaged in parallel
fifths --- and big no-no's which go against the textbook rules of
chorale writing.

In this case, if you have an #ifdef surrounding an entire function
body, I think common sense says that the it's fine.  There's also the
rule which is says that all other things being equal, it's better not
to waste vertical space and useless boiler plate.

Worst of all is patches to change perfectly existing code because
someone is trying to be a stickler for rules, since it can break other
people's patches.  If you are need to make a change, it's best that it
be checkpatch clean.  But sending random cleanups just because someone
is trying to get their patch count in the kernel higher is Just
Stupid, and should be strongly discouraged.

(And that last, too, is a rule that has exceptions...)

							- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
