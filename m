Subject: Re: [parisc-linux] Re: parisc scatterlist doesn't want page/offset
Date: Fri, 16 Nov 2001 17:31:22 +0000 (GMT)
In-Reply-To: <200111161644.JAA26017@puffin.external.hp.com> from "Grant Grundler" at Nov 16, 2001 09:44:57 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <E164mpm-0004a2-00@the-village.bc.nu>
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Grant Grundler <grundler@puffin.external.hp.com>
Cc: Matthew Wilcox <willy@debian.org>, "David S. Miller" <davem@redhat.com>, linux-mm@kvack.org, parisc-linux@lists.parisc-linux.org
List-ID: <linux-mm.kvack.org>

> Until page/offset completely replaces address, I see a net increase
> in cycles for parisc (probably most archs) with only a tangible benefit
> for i386. Seems like the burden should be on the i386 folks to not
> impact other arches.
> My main gripe is adding this to 2.4 seems like the wrong time/place.
> I'm happy to revisit this in 2.5.

Its a bad impact on x86 so unfortunately it does need doing and I agree with
Dave - DaveM rarely implements something that is x86 beneficial but harms 
his beloved sparc64 without good reason.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
