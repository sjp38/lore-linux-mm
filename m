Date: Wed, 27 Aug 2003 14:45:37 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Strange memory usage reporting
In-Reply-To: <20030827095241.D639@nightmaster.csn.tu-chemnitz.de>
Message-ID: <Pine.LNX.4.44.0308271430150.1269-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Jaroslav Kysela <perex@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Aug 2003, Ingo Oeser wrote:
> On Tue, Aug 26, 2003 at 06:03:14PM +0100, Hugh Dickins wrote:
> > Which is the driver involved?  Though it's not wrong to give do_no_page
> > a Reserved page, beware of the the page->count accounting: while it's
> > Reserved, get_page or page_cache_get raises the count, but put_page
> > or page_cache_release does not decrement it - very easy to end up
> > with the page never freed.
> 
> Why is this so asymetric? I would understand ignoring these pages
> in the freeing logic, but why exclude them also from refcounting?

I don't think there's a _good_ reason, it just evolved that way.

The real answer is to get rid of PageReserved completely, which
I'll embark on again in 2.7 (I did start a couple of times in 2.5,
but each time it was too late).

There was a halfway-house suggestion in 2.5 about three months ago,
inspired (as usual) by Reserved page problems in AIO's get_user_pages,
to do as you suggest: submit them to normal refcounting.  I don't
know what became of that, I didn't have much time to get involved.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
