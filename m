Message-Id: <200111161706.KAA26099@puffin.external.hp.com>
Subject: Re: [parisc-linux] Re: parisc scatterlist doesn't want page/offset 
In-Reply-To: Message from "David S. Miller" <davem@redhat.com>
   of "Fri, 16 Nov 2001 08:57:54 PST." <20011116.085754.00483458.davem@redhat.com>
Date: Fri, 16 Nov 2001 10:06:57 -0700
From: Grant Grundler <grundler@puffin.external.hp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: willy@debian.org, linux-mm@kvack.org, parisc-linux@lists.parisc-linux.org
List-ID: <linux-mm.kvack.org>

"David S. Miller" wrote:
> Note the "should", nobody forces them to use page+offset in
> a driver and 2.4.x will NEVER require it.  They just won't
> be able to DMA highmem pages, that's all.

ok.  That's what I wanted to hear.

thanks,
grant
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
