From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [PATCH] dirty bit clearing on s390.
Date: Thu, 22 May 2003 17:18:52 +0200
References: <Pine.LNX.4.44.0305221034480.18177-100000@chimarrao.boston.redhat.com>
In-Reply-To: <Pine.LNX.4.44.0305221034480.18177-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200305221718.52392.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>, Arjan van de Ven <arjanv@redhat.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-mm@kvack.org, akpm@digeo.com
List-ID: <linux-mm.kvack.org>

On Thursday 22 May 2003 16:35, Rik van Riel wrote:
> On 22 May 2003, Arjan van de Ven wrote:
> > On Thu, 2003-05-22 at 13:20, Martin Schwidefsky wrote:
> > > Our solution is to move the clearing of the storage key (dirty bit)
> > > from set_pte to SetPageUptodate. A patch that implements this is
> > > attached. What do you think ?
> >
> > Is there anything that prevents a thread mmaping the page to redirty it
> > before the kernel marks it uptodate ?
>
> Nobody will mmap a page before PG_uptodate has been set.

Thanks, Rik.  This needs to go in as a comment.

Regards,

Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
