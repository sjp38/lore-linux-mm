Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AE3826B00BB
	for <linux-mm@kvack.org>; Mon,  5 Jan 2009 00:44:07 -0500 (EST)
From: Skywing <Skywing@valhallalegends.com>
Date: Sun, 4 Jan 2009 23:43:55 -0600
Subject: RE: [patch][rfc] acpi: do not use kmem caches
Message-ID: <982D8D05B6407A49AD506E6C3AC8E7D6BFEEA2A60C@caralain.haven.nynaeve.net>
References: <20081201120002.GB10790@wotan.suse.de>
 <4933E2C3.4020400@gmail.com> <1228138641.14439.18.camel@penberg-laptop>
 <4933EE8A.2010007@gmail.com> <20081201161404.GE10790@wotan.suse.de>
 <4934149A.4020604@gmail.com> <20081201172044.GB14074@infradead.org>
 <alpine.LFD.2.00.0812011241080.3197@localhost.localdomain>
 <20081201181047.GK10790@wotan.suse.de>
 <alpine.LFD.2.00.0812311649230.3854@localhost.localdomain>
 <20090105041440.GB367@wotan.suse.de>
In-Reply-To: <20090105041440.GB367@wotan.suse.de>
Content-Language: en-US
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>, Len Brown <lenb@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, Alexey Starikovskiy <aystarik@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

-----Original Message-----
From: linux-acpi-owner@vger.kernel.org [mailto:linux-acpi-owner@vger.kernel=
.org] On Behalf Of Nick Piggin
Sent: Sunday, January 04, 2009 11:15 PM
To: Len Brown
Cc: Christoph Hellwig; Alexey Starikovskiy; Pekka Enberg; Linux Memory Mana=
gement List; linux-acpi@vger.kernel.org
Subject: Re: [patch][rfc] acpi: do not use kmem caches

> > I think they are here to stay.  We are running
> > an interpreter in kernel-space with arbitrary input,
> > so I think the ability to easily isolate run-time memory leaks
> > on a non-debug system is important.
> I don't really see the connection. Or why being an interpreter is so
> special. Filesystems, network stack, etc run in kernel with arbitrary
> input. If kmem caches are part of a security strategy, then it's
> broken... You'd surely have to detect bad input before the interpreter
> turns it into a memory leak (or recover afterward, in which case it
> isn't a leak).

I think that the purposes of these was to act as a debugging aid, for examp=
le, if there were BIOS-supplied AML that was triggering a leak.  The point =
being here that a network card driver has a much more well-defined set of w=
hat can happen than a fully pluggable interpreter for third party code.

[Of course, this is just my interpretation from following the discussion; I=
'm not otherwise involved.]

- S

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
