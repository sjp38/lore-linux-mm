Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 54C936B005A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 12:28:06 -0400 (EDT)
Date: Mon, 3 Aug 2009 18:48:59 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 1/12] ksm: rename kernel_pages_allocated
Message-ID: <20090803164859.GG23385@random.random>
References: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
 <Pine.LNX.4.64.0908031308590.16754@sister.anvils>
 <4A76F27E.5070407@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A76F27E.5070407@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 03, 2009 at 05:21:50PM +0300, Izik Eidus wrote:
> Hugh Dickins wrote:
> > We're not implementing swapping of KSM pages in its first release;
> > but when that follows, "kernel_pages_allocated" will be a very poor
> > name for the sysfs file showing number of nodes in the stable tree:
> > rename that to "pages_shared" throughout.
> >
> > But we already have a "pages_shared", counting those page slots
> > sharing the shared pages: first rename that to... "pages_sharing".
> >
> > What will become of "max_kernel_pages" when the pages shared can
> > be swapped?  I guess it will just be removed, so keep that name.
> >
> > Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> > ---
> >
> >
> >   
> ACK.

Not sure if it worth doing the subtraction between the number of user
mappings pointing to the ksm_pages_shared.

Acked-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
