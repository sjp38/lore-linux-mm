Message-ID: <396E2CC0.9B8BE5C7@sgi.com>
Date: Thu, 13 Jul 2000 13:55:28 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: writeback list
References: <8kl5ij$4vtnc$1@fido.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
> 
> Hi Stephen,
> 
> we may have forgotten something in our new new vm design from
> last weekend. While we have the list head available to put
> pages in the writeback list, we don't have an entry in to put
> the timestamp of the write in struct_page...
> 
> Maybe we want to have an active list after all and replace the
> buffer_head pointer with a pointer to another structure that
> tracks the writeback stuff that's now tracked by the buffer head?
> 
> (things like: prev, next, write_time and a few other things)
> 


Yes, maintaining time information in the page will be useful
for XFS also. Basically, there are pages in the page cache
without a particular block(s) assigned to the page ... these
are the delayed allocate pages. Such pages don't have any
buffer_heads associated with them, until the delalloc is converted.

It will be great if the delalloc pages can be somehow temporally ordered.
The write-back list you propose seems to fit the bill nicely.

regards,

ananth.


-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
