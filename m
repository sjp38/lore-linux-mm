Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D1DDF8D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 09:50:19 -0500 (EST)
Received: from eu_spt1 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LBZ008Z7FVSHW@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 16 Nov 2010 14:50:16 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LBZ008RWFVSGI@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 16 Nov 2010 14:50:16 +0000 (GMT)
Date: Tue, 16 Nov 2010 15:50:16 +0100
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 0/3] hwmem: Hardware memory driver
In-reply-to: 
 <1289912882-23996-1-git-send-email-johan.xx.mossberg@stericsson.com>
Message-id: <op.vl9p52wp7p4s8u@pikus>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-transfer-encoding: Quoted-Printable
References: <1289912882-23996-1-git-send-email-johan.xx.mossberg@stericsson.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Johan Mossberg <johan.xx.mossberg@stericsson.com>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Nov 2010 14:07:59 +0100, Johan Mossberg <johan.xx.mossberg@st=
ericsson.com> wrote:
> The following patchset implements a "hardware memory driver". The
> main purpose of hwmem is:
>
> * To allocate buffers suitable for use with hardware. Currently
> this means contiguous buffers.
> * To synchronize the caches for the allocated buffers. This is
> achieved by keeping track of when the CPU uses a buffer and when
> other hardware uses the buffer, when we switch from CPU to other
> hardware or vice versa the caches are synchronized.
> * To handle sharing of allocated buffers between processes i.e.
> import, export.
>
> Hwmem is available both through a user space API and through a
> kernel API.
>
> Here at ST-Ericsson we use hwmem for graphics buffers. Graphics
> buffers need to be contiguous due to our hardware, are passed
> between processes (usually application and window manager)and are
> part of usecases where performance is top priority so we can't
> afford to synchronize the caches unecessarily.
>
> Hwmem and CMA (Contiguous Memory Allocator) overlap to some extent.
> Hwmem could use CMA as its allocator and thereby remove the overlap
> but then defragmentation can not be implemented as CMA currently
> has no support for this. We would very much like to see a
> discussion about adding defragmentation to CMA.

I would definitelly like to see what the two solution share and try to
merge those.

In particular, I'll try to figure out what you mean by defragmentation
and see whethe it could be added to CMA.

My idea about CMA is to provide only allocator framework and let others
interact with user space and/or share resources, which, as I understand,=

hwmem does.

PS. I don't follow linux-mm carefully, so I'd be great if you'd Cc me on=

     future versions of hwmem.

-- =

Best regards,                                        _     _
| Humble Liege of Serenely Enlightened Majesty of  o' \,=3D./ `o
| Computer Science,  Micha=C5=82 "mina86" Nazarewicz       (o o)
+----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
