Message-Id: <200111161644.JAA26017@puffin.external.hp.com>
Subject: Re: [parisc-linux] Re: parisc scatterlist doesn't want page/offset 
In-Reply-To: Message from Matthew Wilcox <willy@debian.org>
   of "Fri, 16 Nov 2001 15:43:50 GMT." <20011116154350.L25491@parcelfarce.linux.theplanet.co.uk>
Date: Fri, 16 Nov 2001 09:44:57 -0700
From: Grant Grundler <grundler@puffin.external.hp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <willy@debian.org>
Cc: "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org, parisc-linux@lists.parisc-linux.org
List-ID: <linux-mm.kvack.org>

Matthew Wilcox wrote:
> grant suggested adding support for it had performance implications,

Jens is right to some degree - I'm counting cycles in that code
path since every driver depends on it for every IO request.
Until page/offset completely replaces address, I see a net increase
in cycles for parisc (probably most archs) with only a tangible benefit
for i386. Seems like the burden should be on the i386 folks to not
impact other arches.

My main gripe is adding this to 2.4 seems like the wrong time/place.
I'm happy to revisit this in 2.5.

grant

ps. I still have to go hunt down the discussion jens was referring to.
  Maybe if I understood the direction better, I'd be more receptive.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
