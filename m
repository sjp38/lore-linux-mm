Message-Id: <200111161632.JAA25977@puffin.external.hp.com>
Subject: Re: [parisc-linux] Re: parisc scatterlist doesn't want page/offset 
In-Reply-To: Message from "David S. Miller" <davem@redhat.com>
   of "Fri, 16 Nov 2001 07:33:28 PST." <20011116.073328.129356309.davem@redhat.com>
Date: Fri, 16 Nov 2001 09:32:52 -0700
From: Grant Grundler <grundler@puffin.external.hp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: willy@debian.org, linux-mm@kvack.org, parisc-linux@lists.parisc-linux.org
List-ID: <linux-mm.kvack.org>

"David S. Miller" wrote:
> Part of the criteria to whether we merge back Jens' code is
> if the ports, given reasonable notice (ie. take this as your notice)
> have added in the support for page+offset pairs to their pci_map_sg
> code.

That is what willy was talking about.
You asking folks to muck with what's supposed to be working code.

> I suggest you do this now, it is totally painless.  I would almost
> classify it as a mindless edit.

Adding two members to a struct is not the problem.
The problem is revisiting every usage of ->address in the DMA code
and telling driver writers they should be using page+offset.

grant
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
