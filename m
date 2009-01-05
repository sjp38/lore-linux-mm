Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E7F566B00AD
	for <linux-mm@kvack.org>; Mon,  5 Jan 2009 01:55:55 -0500 (EST)
Date: Mon, 5 Jan 2009 07:55:51 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] acpi: do not use kmem caches
Message-ID: <20090105065551.GB5209@wotan.suse.de>
References: <1228138641.14439.18.camel@penberg-laptop> <4933EE8A.2010007@gmail.com> <20081201161404.GE10790@wotan.suse.de> <4934149A.4020604@gmail.com> <20081201172044.GB14074@infradead.org> <alpine.LFD.2.00.0812011241080.3197@localhost.localdomain> <20081201181047.GK10790@wotan.suse.de> <alpine.LFD.2.00.0812311649230.3854@localhost.localdomain> <20090105041440.GB367@wotan.suse.de> <982D8D05B6407A49AD506E6C3AC8E7D6BFEEA2A60C@caralain.haven.nynaeve.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <982D8D05B6407A49AD506E6C3AC8E7D6BFEEA2A60C@caralain.haven.nynaeve.net>
Sender: owner-linux-mm@kvack.org
To: Skywing <Skywing@valhallalegends.com>
Cc: Len Brown <lenb@kernel.org>, Christoph Hellwig <hch@infradead.org>, Alexey Starikovskiy <aystarik@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jan 04, 2009 at 11:43:55PM -0600, Skywing wrote:
> -----Original Message-----
> From: linux-acpi-owner@vger.kernel.org [mailto:linux-acpi-owner@vger.kernel.org] On Behalf Of Nick Piggin
> Sent: Sunday, January 04, 2009 11:15 PM
> To: Len Brown
> Cc: Christoph Hellwig; Alexey Starikovskiy; Pekka Enberg; Linux Memory Management List; linux-acpi@vger.kernel.org
> Subject: Re: [patch][rfc] acpi: do not use kmem caches
> 
> > > I think they are here to stay.  We are running
> > > an interpreter in kernel-space with arbitrary input,
> > > so I think the ability to easily isolate run-time memory leaks
> > > on a non-debug system is important.
> > I don't really see the connection. Or why being an interpreter is so
> > special. Filesystems, network stack, etc run in kernel with arbitrary
> > input. If kmem caches are part of a security strategy, then it's
> > broken... You'd surely have to detect bad input before the interpreter
> > turns it into a memory leak (or recover afterward, in which case it
> > isn't a leak).
> 
> I think that the purposes of these was to act as a debugging aid, for example, if there were BIOS-supplied AML that was triggering a leak.  The point being here that a network card driver has a much more well-defined set of what can happen than a fully pluggable interpreter for third party code.

It just seems like different shades to me, rather than some completely
different thing. A single network driver, maybe, but consider that untrusted
input influences a very large part of the entire network stack... Or a
filesystem.

Basically, if the data is really untrusted or likely to result in a leak,
then it should be detected and sanitized properly, rather than being allowed
to leak.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
