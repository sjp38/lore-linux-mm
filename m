Date: Wed, 14 May 2003 15:11:53 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: Race between vmtruncate and mapped areas?
In-Reply-To: <127820000.1052939265@baldur.austin.ibm.com>
Message-ID: <Pine.LNX.4.44.0305141511270.10617-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, mika.penttila@kolumbus.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 May 2003, Dave McCracken wrote:
> --On Wednesday, May 14, 2003 15:04:55 -0400 Rik van Riel <riel@redhat.com>
> wrote:
> 
> >> Not to mention they could end up being outside of any VMA,
> >> meaning there's no sane way to deal with them.
> > 
> > I hate to follow up to my own email, but the fact that
> > they're not in any VMA could mean we leak these pages
> > at exit() time.
> 
> Well, they are still inside the vma.  Truncate doesn't shrink the vma.  It
> just generates SIGBUS when the app tries to fault the pages in.

Right, I forgot about that.  Forget the memory leak and
security bug theory, then ;)))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
