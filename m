From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199912140001.QAA07712@google.engr.sgi.com>
Subject: PG_DMA
Date: Mon, 13 Dec 1999 16:01:58 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

In 2.3.32-pre, I see that the PageDMA(page) macro has been changed to

#define PageDMA(page)            (contig_page_data.node_zones + ZONE_DMA == (page)->zone)

Why was this done? I would still prefer to see the PG_DMA bit, because
for discontig platforms, there is not a "contig_page_data". In short, 
this will break any platform that does use the CONFIG_DISCONTIGMEM code.

Thanks.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
