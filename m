Message-ID: <4021A6BA.5000808@cyberone.com.au>
Date: Thu, 05 Feb 2004 13:13:14 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] mm improvements
References: <16416.64425.172529.550105@laputa.namesys.com>	<Pine.LNX.4.44.0402041459420.3574-100000@localhost.localdomain> <16417.3444.377405.923166@laputa.namesys.com>
In-Reply-To: <16417.3444.377405.923166@laputa.namesys.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <Nikita@Namesys.COM>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Nikita Danilov wrote:

>Hugh Dickins writes:
> > On Wed, 4 Feb 2004, Nikita Danilov wrote:
> > > Hugh Dickins writes:
> > >  > If you go the writepage-while-mapped route (more general gotchas?
> > >  > I forget), you'll have to make an exception for shmem_writepage.
> > > 
> > > May be one can just call try_to_unmap() from shmem_writepage()?
> > 
> > That sounds much cleaner.  But I've not yet found what tree your
> > p12-dont-unmap-on-pageout.patch applies to, so cannot judge it.
>
>Whole
>ftp://ftp.namesys.com/pub/misc-patches/unsupported/extra/2004.02.04/
>applies to the 2.6.2-rc2.
>
>I just updated p12-dont-unmap-on-pageout.patch in-place.
>
>  
>

Sure, I can give this a try. It makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
