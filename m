Received: from knoppix.wat.veritas.com ([10.10.188.58]) (1003 bytes) by
    megami.veritas.com via sendmail with P:esmtp/R:smart_host/T:smtp
    (sender: <hugh@veritas.com>) id <m1C0o6Q-0000ycC@megami.veritas.com> for
    <linux-mm@kvack.org>; Fri, 27 Aug 2004 14:17:42 -0700 (PDT)
    (Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Fri, 27 Aug 2004 22:17:35 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: refill_inactive_zone question
In-Reply-To: <20040827190714.GB3332@logos.cnet>
Message-ID: <Pine.LNX.4.44.0408272213410.2144-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 27 Aug 2004, Marcelo Tosatti wrote:
> 
> Is it possible to have AnonPages without a mapping to them? I dont think so.

It was impossible, but my "remove page_map_lock" patches had to change that.

> Can't the check "if (total_swap_pages == 0 && PageAnon(page))" be moved
> inside "if (page_mapped(page))" ? 

Yes: it's like that in -mm, and I believe now in Linus' bk tree too.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
