Date: Wed, 27 Aug 2003 09:52:41 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: Strange memory usage reporting
Message-ID: <20030827095241.D639@nightmaster.csn.tu-chemnitz.de>
References: <Pine.LNX.4.44.0308261550240.1958-100000@pnote.perex-int.cz> <Pine.LNX.4.44.0308261756570.1632-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0308261756570.1632-100000@localhost.localdomain>; from hugh@veritas.com on Tue, Aug 26, 2003 at 06:03:14PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Jaroslav Kysela <perex@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Aug 26, 2003 at 06:03:14PM +0100, Hugh Dickins wrote:
> Which is the driver involved?  Though it's not wrong to give do_no_page
> a Reserved page, beware of the the page->count accounting: while it's
> Reserved, get_page or page_cache_get raises the count, but put_page
> or page_cache_release does not decrement it - very easy to end up
> with the page never freed.

Why is this so asymetric? I would understand ignoring these pages
in the freeing logic, but why exclude them also from refcounting?

Regards

Ingo Oeser
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
