Date: Wed, 7 Mar 2001 12:07:45 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Linux 2.2 vs 2.4 for PostgreSQL
Message-ID: <20010307120745.H7453@redhat.com>
References: <20010307102206.C7453@redhat.com> <Pine.LNX.4.10.10103071113020.1559-100000@sphinx.mythic-beasts.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10103071113020.1559-100000@sphinx.mythic-beasts.com>; from matthew@hairy.beasts.org on Wed, Mar 07, 2001 at 11:16:19AM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Kirkwood <matthew@hairy.beasts.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org, Mike Galbraith <mikeg@wen-online.de>, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Mar 07, 2001 at 11:16:19AM +0000, Matthew Kirkwood wrote:
> 
> The version I did these numbers on uses fsync(), but
> they have recently changed that to fdatasync() in a
> few applicable places.
> 
> I don't have that installed on my test machine yet,
> but will have a look if it's deemed intersting.

Given that I'm chasing fsync performance regressions here in 2.4, yes,
that might be quite useful to know.

Thanks,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
