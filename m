Date: Thu, 22 May 2003 10:35:08 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH] dirty bit clearing on s390.
In-Reply-To: <1053603729.2360.0.camel@laptop.fenrus.com>
Message-ID: <Pine.LNX.4.44.0305221034480.18177-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@redhat.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-mm@kvack.org, akpm@digeo.com, phillips@arcor.de
List-ID: <linux-mm.kvack.org>

On 22 May 2003, Arjan van de Ven wrote:
> On Thu, 2003-05-22 at 13:20, Martin Schwidefsky wrote:
> 
> > Our solution is to move the clearing of the storage key (dirty bit)
> > from set_pte to SetPageUptodate. A patch that implements this is
> > attached. What do you think ?
> 
> Is there anything that prevents a thread mmaping the page to redirty it
> before the kernel marks it uptodate ? 

Nobody will mmap a page before PG_uptodate has been set.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
