Date: Wed, 7 Mar 2001 10:22:06 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Linux 2.2 vs 2.4 for PostgreSQL
Message-ID: <20010307102206.C7453@redhat.com>
References: <Pine.LNX.4.10.10103061626070.20708-100000@sphinx.mythic-beasts.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10103061626070.20708-100000@sphinx.mythic-beasts.com>; from matthew@hairy.beasts.org on Tue, Mar 06, 2001 at 07:36:23PM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Kirkwood <matthew@hairy.beasts.org>
Cc: linux-mm@kvack.org, Mike Galbraith <mikeg@wen-online.de>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Mar 06, 2001 at 07:36:23PM +0000, Matthew Kirkwood wrote:
> 
> Postgres is fairly fsync-happy.

Do you happen to know if it is using fsync, fdatasync or O_SYNC?  I'm
seeing performance regressions on 2.4 fsync versus 2.2 which I'm
chasing right now, but fdatasync doesn't seem to have that problem
(and fdatasync is always preferable if you are updating a file in
place and you don't care about the mtime timestamp being 100%
uptodate).

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
