Date: Tue, 26 Sep 2000 10:54:23 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: the new VMt
Message-ID: <20000926105423.D1638@redhat.com>
References: <20000925143523.B19257@hq.fsmlabs.com> <E13df92-0005Zp-00@the-village.bc.nu> <20000925150744.A20586@hq.fsmlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20000925150744.A20586@hq.fsmlabs.com>; from yodaiken@fsmlabs.com on Mon, Sep 25, 2000 at 03:07:44PM -0600
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: yodaiken@fsmlabs.com
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>, Jamie Lokier <lk@tantalophile.demon.co.uk>, mingo@elte.hu, Andrea Arcangeli <andrea@suse.de>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Sep 25, 2000 at 03:07:44PM -0600, yodaiken@fsmlabs.com wrote:
> On Mon, Sep 25, 2000 at 09:46:35PM +0100, Alan Cox wrote:
> > > I'm not too sure of what you have in mind, but if it is
> > >      "process creates vast virtual space to generate many page table
> > >       entries -- using mmap"
> > > the answer is, virtual address space quotas and mmap should kill 
> > > the process on low mem for page tables.
> > 
> > Those quotas being exactly what beancounter is
> 
> But that is a function specific counter, not a counter in the 
> alloc code.

Beancounter is a framework for user-level accounting.  _What_ you
account is up to the callers.  Maybe this has been a miscommunication,
but beancounter is all about allowing callers to account for stuff
before allocation, not about having the page allocation functions
themselves enforce quotas.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
