Date: Fri, 16 Nov 2001 08:57:54 -0800 (PST)
Message-Id: <20011116.085754.00483458.davem@redhat.com>
Subject: Re: [parisc-linux] Re: parisc scatterlist doesn't want page/offset 
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <200111161632.JAA25977@puffin.external.hp.com>
References: <davem@redhat.com>
	<200111161632.JAA25977@puffin.external.hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: grundler@puffin.external.hp.com
Cc: willy@debian.org, linux-mm@kvack.org, parisc-linux@lists.parisc-linux.org
List-ID: <linux-mm.kvack.org>

   > I suggest you do this now, it is totally painless.  I would almost
   > classify it as a mindless edit.
   
   Adding two members to a struct is not the problem.
   The problem is revisiting every usage of ->address in the DMA code
   and telling driver writers they should be using page+offset.
   
Note the "should", nobody forces them to use page+offset in
a driver and 2.4.x will NEVER require it.  They just won't
be able to DMA highmem pages, that's all.

The DMA code is so simple to fix ("mindless edit" is still how I
classify it) and you have _THREE_ (count them, 3) platform IOMMU code
patch examples to work with (alpha, sparc64, ia64).

Franks a lot,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
