Date: Fri, 10 Dec 1999 01:52:17 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <199912092344.AAA01364@agnes.faerie.monroyaume>
Message-ID: <Pine.LNX.4.10.9912100148050.12148-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: JF Martinez <jfm2@club-internet.fr>
Cc: wje@cthulhu.engr.sgi.com, R.E.Wolff@BitWizard.nl, Jeff Garzik <jgarzik@mandrakesoft.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.rutgers.edu, MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Dec 1999, JF Martinez wrote:

> > > yep, if eg. an fsck happened before modules are loaded then RAM is filled
> > > up with the buffer-cache. The best guarantee is to compile such drivers
> > > into the kernel.
> 
> Modules are crucial.  The best gurantee is fix the problem and keep
> the drivers where they must be: in modules not in the main kernel.

modules are nice for many things (like installation), but if you expect to
be able to allocate 100MB continuous RAM on a booted-up 128MB box then you
are simply out of luck.

if modules with tough RAM-needs are absolutely needed for whatever reason,
then use initrd and there will be no fsck problems ...

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
