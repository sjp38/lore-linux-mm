Date: Tue, 2 Sep 2008 04:52:23 -0700 (PDT)
From: Sitsofe Wheeler <sitsofe@yahoo.com>
Subject: Re: Anonymous memory on machines without swap
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Message-ID: <517228.84065.qm@web38202.mail.mud.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Mon, 1 Sep 2008, Sitsofe Wheeler wrote:
> > 
> > Is it worth having the anonymous memory option turned on in kconfig when
> > using the kernel on a machine which has no swap/swapfiles? Does it
> > improve memory decisions in some secret way (even though there is no
> > swap available) or would it just be completely redundant?
> 
> Which is the anonymous memory option in kconfig?
> 
> There is CONFIG_SWAP, which you might as well turn off if you don't
> intend to use swap/swapfiles.  I don't think it makes any difference to
> memory decisions in such a case (they should be based on nr_swap_pages
> being 0), but it would shrink your kernel a little.

It was CONFIG_SWAP that I was thinking of but my misreading of the description was wide of the mark ("Support for paging of anonymous memory (swap)" is not at all the same as disabling anonymous memory...)

(Apologies for the double posting - GMANE seems to be acting up a bit...)


      

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
