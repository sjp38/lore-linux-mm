Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA08081
	for <linux-mm@kvack.org>; Thu, 23 Jul 1998 17:33:04 -0400
Date: Thu, 23 Jul 1998 21:51:37 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: More info: 2.1.108 page cache performance on low memory
In-Reply-To: <87hg08vnmt.fsf@atlas.CARNet.hr>
Message-ID: <Pine.LNX.3.96.980723214715.18464B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm+eric@npwt.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 23 Jul 1998, Zlatko Calusic wrote:

> One wrong way of fixing it is to limit page cache size, IMNSHO.
> 
> I tried the other way, to age page cache harder, and it looks like it
> works very well. Patch is simple, so simple that I can't understand
> nobody suggested (something like) it yet.

These solutions are somewhat the same, but your one may take
a little less computational power and has a tradeoff in the
fact that it is very inflexible.

> --- filemap.c.virgin   Tue Jul 21 18:41:30 1998
> +++ filemap.c   Thu Jul 23 12:14:43 1998
> +                       age_page(page);
> +                       age_page(page);
>                         age_page(page);
> If I put only two age_page()s, there's still too much swapping for my
> taste.
> With three age_page()s, read performance is as expected, and still we
> manage memory more efficiently than without page aging.

This only proves that three age_page()s are a good number
for _your_ computer and your workload.

> Comments?

As Stephen put it so nicely when I (in a bad mood) proposed
another artificial limit:
" O no, another arbitrary limit in the kernel! "

And another one of Stephen's wisdoms (heavily paraphrased!):
" Good solutions are dynamic and/or self-tuning "
[Sorry Stephen, this was VERY heavily paraphrased :)]

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
