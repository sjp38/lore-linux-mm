From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200006211956.MAA60703@google.engr.sgi.com>
Subject: Re: 2.4: why is NR_GFPINDEX so large?
Date: Wed, 21 Jun 2000 12:56:12 -0700 (PDT)
In-Reply-To: <20000621195525Z131176-21000+55@kanga.kvack.org> from "Timur Tabi" at Jun 21, 2000 02:48:56 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Timur Tabi <ttabi@interactivesi.com>
Cc: Linux MM mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> 
> In mmzone.h, NR_GFPINDEX is set to 0x100.  This means that the node_zonelists
> array in pg_data_t has 256 elements.  However, then we have code like this in
> mm.h:
> 
> static inline struct page * alloc_pages(int gfp_mask, unsigned long order)
> {
> [snip]
> 	return __alloc_pages(contig_page_data.node_zonelists+(gfp_mask), order);
> }
> 
> gfp_mask is any combination of any of these flags (from mm.h):
> 
> #define __GFP_WAIT	0x01
> #define __GFP_HIGH	0x02
> #define __GFP_IO	0x04
> #define __GFP_DMA	0x08
> #define __GFP_HIGHMEM	0x10
> 
> Which means theorectically, the largest value is 0x1F, or 31.  This means that
> elements 32-255 of array node_zonelists are never accessed.  Can someone explain
> this to me?
> 

This is a left over from the days when we had a few more __GFP_ flags,
but that has been cleaned up now, so NR_GFPINDEX can go down. Be aware 
of any cache footprint issues though.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
