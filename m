Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 953A238C0C
	for <linux-mm@kvack.org>; Mon, 25 Jun 2001 20:59:11 -0300 (EST)
Date: Mon, 25 Jun 2001 20:59:11 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [RFC] VM statistics to gather
In-Reply-To: <200106252339.f5PNd9x07535@maile.telia.com>
Message-ID: <Pine.LNX.4.33L.0106252048230.23373-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jun 2001, Roger Larsson wrote:

> What about
>
>    unsigned int vm_pgfails /* failed alloc attempts, in pages (not calls) */

What would that represent ?

How often __alloc_pages() exits without allocating anything?

> maybe even a
>
>    unsigned int vm_pgallocs /* alloc attempts, in pages */
>
> for sanity checking - should be the sum of several other combinations...

Sounds like a nice idea.

> Should memory zone be used as dimension?

Useful for allocations I guess, but it may be too confusing
if we do this for all statistics... OTOH...

Comments, anyone?

regards,

Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"


		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
