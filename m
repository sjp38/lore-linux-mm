Date: Thu, 1 Feb 2001 17:07:00 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] vma limited swapin readahead
In-Reply-To: <20010201105933.A12074@archimedes.oak.suse.com>
Message-ID: <Pine.LNX.4.21.0102011706010.1321-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gould <dg@suse.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Marcelo Tosatti <marcelo@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Feb 2001, David Gould wrote:
> On Thu, Feb 01, 2001 at 11:26:01AM +0000, Stephen C. Tweedie wrote:

> > Also remember that the readahead pages won't actually get mapped into
> > memory, so they can be recycled easily.  So, under swapping you tend
> > to find that the extra readin pages are going to be replacing old,
> > unneeded readahead pages to some extent, rather than swapping out
> > useful pages.
> 
> Ok. I am convinced. I would have even thought of this myself
> eventually...

See http://distro.conectiva.com.br/bugzilla/show_bug.cgi?id=1175
for more information about this bug, and a proposed way to fix
the problem.

Or the whole Linux-MM bugzilla:
	http://www.linux-mm.org/bugzilla.shtml

cheers,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
