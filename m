Date: Thu, 13 Jul 2000 19:21:39 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: writeback list
In-Reply-To: <396E2CC0.9B8BE5C7@sgi.com>
Message-ID: <Pine.LNX.4.21.0007131917280.1215-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rajagopal Ananthanarayanan <ananth@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Jul 2000, Rajagopal Ananthanarayanan wrote:
> Rik van Riel wrote:

> > we may have forgotten something in our new new vm design from
> > last weekend. While we have the list head available to put
> > pages in the writeback list, we don't have an entry in to put
> > the timestamp of the write in struct_page...
> > 
> > Maybe we want to have an active list after all and replace the
> > buffer_head pointer with a pointer to another structure that
> > tracks the writeback stuff that's now tracked by the buffer head?
> > 
> > (things like: prev, next, write_time and a few other things)
> 
> Yes, maintaining time information in the page will be useful for
> XFS also. Basically, there are pages in the page cache without a
> particular block(s) assigned to the page ... these are the
> delayed allocate pages. Such pages don't have any buffer_heads
> associated with them, until the delalloc is converted.

Exactly, this is what the write-back list will be used for.

> It will be great if the delalloc pages can be somehow temporally
> ordered. The write-back list you propose seems to fit the bill
> nicely.

To put it more strongly, the write-back list *needs* to be
temporally ordered if we want to have a kupdate like we have
today.

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
