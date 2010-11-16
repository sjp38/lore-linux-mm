Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B47CE8D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 12:36:07 -0500 (EST)
Received: from eu_spt1 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LBZ007RUNK41L@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Tue, 16 Nov 2010 17:36:04 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LBZ006NMNK4Y2@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 16 Nov 2010 17:36:04 +0000 (GMT)
Date: Tue, 16 Nov 2010 18:36:03 +0100
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH 0/3] hwmem: Hardware memory driver
In-reply-to: 
 <C832F8F5D375BD43BFA11E82E0FE9FE0081BE73A1D@EXDCVYMBSTM005.EQ1STM.local>
Message-id: <op.vl9xudve7p4s8u@pikus>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-transfer-encoding: Quoted-Printable
References: 
 <1289912882-23996-1-git-send-email-johan.xx.mossberg@stericsson.com>
 <op.vl9p52wp7p4s8u@pikus>
 <C832F8F5D375BD43BFA11E82E0FE9FE0081BE739A0@EXDCVYMBSTM005.EQ1STM.local>
 <op.vl9r6xld7p4s8u@pikus>
 <C832F8F5D375BD43BFA11E82E0FE9FE0081BE73A1D@EXDCVYMBSTM005.EQ1STM.local>
Sender: owner-linux-mm@kvack.org
To: Johan MOSSBERG <johan.xx.mossberg@stericsson.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Nov 2010 17:16:23 +0100, Johan MOSSBERG <johan.xx.mossberg@st=
ericsson.com> wrote:

> Micha=C5=82 Nazarewicz wrote:
>> In particular, a cma_alloc() could return a pointer to an opaque
>> struct cma and to get physical address user would have to pin the
>> buffer with, say, cma_pin() and then call cma_phys() to obtain
>> physical address.

> I think cma_phys() is redundant, cma_pin() can return the physical
> address, that's how we did it in hwmem.

Makes sense.  I'd add cma_phys() for convenience anyway.

>> I'm only wondering if treating "unpin" as "free" and pin as another
>> "alloc" would not suffice?

> I don't understand. Wouldn't you lose all the data in the buffer
> when you free it? How would we handle something like the desktop
> image which is blitted to the display all the time but never
> changes? We'd have to keep a scattered version and then copy it
> into a temporary contiguous buffer which is not optimal
> performance wise. The other alternative would be to keep the
> allocation but then we would get fragmentation problems.

Got it.

Do you want to remap user space mappings when page is moved during
defragmentation? Or would user need to unmap the region?  Ie. would
mmap()ed buffer be pinned?

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
