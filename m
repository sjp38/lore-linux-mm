Date: Wed, 7 Mar 2001 11:16:19 +0000 (GMT)
From: Matthew Kirkwood <matthew@hairy.beasts.org>
Subject: Re: Linux 2.2 vs 2.4 for PostgreSQL
In-Reply-To: <20010307102206.C7453@redhat.com>
Message-ID: <Pine.LNX.4.10.10103071113020.1559-100000@sphinx.mythic-beasts.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org, Mike Galbraith <mikeg@wen-online.de>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Mar 2001, Stephen C. Tweedie wrote:

> > Postgres is fairly fsync-happy.
>
> Do you happen to know if it is using fsync, fdatasync or O_SYNC?  I'm
> seeing performance regressions on 2.4 fsync versus 2.2 which I'm
> chasing right now, but fdatasync doesn't seem to have that problem
> (and fdatasync is always preferable if you are updating a file in
> place and you don't care about the mtime timestamp being 100%
> uptodate).

The version I did these numbers on uses fsync(), but
they have recently changed that to fdatasync() in a
few applicable places.

I don't have that installed on my test machine yet,
but will have a look if it's deemed intersting.

Matthew.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
