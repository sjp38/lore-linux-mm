Date: Mon, 1 Nov 2004 16:19:31 -0800 (PST)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH 0/7] abstract pagetable locking and pte updates
In-Reply-To: <4183009D.9080708@yahoo.com.au>
Message-ID: <Pine.LNX.4.58.0411011616150.8399@server.graphe.net>
References: <4181EF2D.5000407@yahoo.com.au> <41822D75.3090802@yahoo.com.au>
 <20041029205255.GH12934@holomorphy.com> <4183009D.9080708@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: William Lee Irwin III <wli@holomorphy.com>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 30 Oct 2004, Nick Piggin wrote:

> So it is a long way off from saying N architectures _do_ work,
> but the possibility is there.

There needs to be some fallback mechanism that allows to leave an arch the
way it is now and it will still work right. Then one can say that all
architectures will work.

> > What is unacceptable is the lack of research into the needs of arches
> > that has been put into this. The general core changes proposed can
> > never be adequate without a corresponding sweep of architecture-
> > specific code. While I fully endorse the concept of lockless pagetable
> > updates, there can be no correct implementation leaving architecture-
> > specific code unswept. I would encourage whoever cares to pursue this
> > to its logical conclusion to do the necessary reading, and audits, and
> > review of architecture manuals instead of designing core API's in vacuums.
> >
>
> Definitely - which is one of the reasons I posted it here, because I
> don't pretend to know all the arch details. But if you think I designed
> it in a vacuum you're wrong.

It is really a challenge to work with architectures that you cannot get
your hands on. We need to pool our resources otherwise this will never
work.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
