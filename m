Date: Wed, 14 May 2003 15:04:55 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: Race between vmtruncate and mapped areas?
In-Reply-To: <Pine.LNX.4.44.0305141501180.10617-100000@chimarrao.boston.redhat.com>
Message-ID: <Pine.LNX.4.44.0305141503010.10617-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Dave McCracken <dmccr@us.ibm.com>, mika.penttila@kolumbus.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 May 2003, Rik van Riel wrote:
> On Wed, 14 May 2003, Andrew Morton wrote:
> 
> > It would be nice to make them go away - they cause problems.
> 
> Not to mention they could end up being outside of any VMA,
> meaning there's no sane way to deal with them.

I hate to follow up to my own email, but the fact that
they're not in any VMA could mean we leak these pages
at exit() time.

Which means a security bug, as well as the potential to
end up with bad pointers in kernel space, eg. think about
the rmap code jumping to a no longer existing mm_struct.

The more I think about it, the more I agree with Andrew
that it would be really really nice to get rid of them ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
