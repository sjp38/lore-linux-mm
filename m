From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] dirty bit clearing on s390.
Date: Thu, 22 May 2003 16:21:36 +0200
References: <20030522112000.GA2597@mschwid3.boeblingen.de.ibm.com> <1053603729.2360.0.camel@laptop.fenrus.com>
In-Reply-To: <1053603729.2360.0.camel@laptop.fenrus.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200305221621.36656.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: arjanv@redhat.com, Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

On Thursday 22 May 2003 13:42, Arjan van de Ven wrote:
> On Thu, 2003-05-22 at 13:20, Martin Schwidefsky wrote:
> > Our solution is to move the clearing of the storage key (dirty bit)
> > from set_pte to SetPageUptodate. A patch that implements this is
> > attached. What do you think ?
>
> Is there anything that prevents a thread mmaping the page to redirty it
> before the kernel marks it uptodate ?

The storage key is only supposed to be cleared the first time a page is 
entered into any process page table.  The theory is that the s390 hook in 
SetPageUptodate can figure that out reliably (this theory needs to be 
examined closely).  If it can know that, then it also knows no other page 
table is mapping the page, so no dirty events can get lost.

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
