Date: Sun, 15 Oct 2000 08:01:14 -0400 (EDT)
From: Ingo Molnar <mingo@redhat.com>
Subject: Re: [RFC] atomic pte updates and pae changes, take 2
In-Reply-To: <20001014143309.D5813@redhat.com>
Message-ID: <Pine.LNX.4.21.0010150800250.30587-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Tweedie <sct@redhat.com>
Cc: Ben LaHaise <bcrl@redhat.com>, torvalds@transmeta.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 14 Oct 2000, Stephen Tweedie wrote:

> Looks good.  The only trouble I can see left is that pte_clear() is
> still using set_pte(), which doesn't work right for PAE36.  set_pte()
> is setting the high word first, which is fine for installing a new
> pte, but if you do that to clear a pte then you have left the old
> page-present bit intact while you've removed have of the pte.
> pte_clear() needs to clear the words in the other order (just as
> pte_get_and_clear correctly does).

yep, that should make it work. The pgd operations must use 64-bit
instructions - the pmds are fine to be 64-bit for the time being, but they
can be changed to the pte logic as well.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
