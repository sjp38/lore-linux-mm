Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E5C1E6007FC
	for <linux-mm@kvack.org>; Fri,  6 Aug 2010 09:29:29 -0400 (EDT)
Received: from eu_spt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L6Q00FBPG515M@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 06 Aug 2010 14:29:25 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L6Q003C3G50ZQ@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 06 Aug 2010 14:29:25 +0100 (BST)
Date: Fri, 06 Aug 2010 15:31:00 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCHv2 2/4] mm: cma: Contiguous Memory Allocator added
In-reply-to: <201008030919.36575.hverkuil@xs4all.nl>
Message-id: <op.vg0qhyki7p4s8u@pikus>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-transfer-encoding: Quoted-Printable
References: <cover.1280151963.git.m.nazarewicz@samsung.com>
 <201008011526.13566.hverkuil@xs4all.nl> <op.vgticdzj7p4s8u@pikus>
 <201008030919.36575.hverkuil@xs4all.nl>
Sender: owner-linux-mm@kvack.org
To: Hans Verkuil <hverkuil@xs4all.nl>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Jonathan Corbet' <corbet@lwn.net>, Pawel Osciak <p.osciak@samsung.com>, 'Mark Brown' <broonie@opensource.wolfsonmicro.com>, linux-kernel@vger.kernel.org, 'Hiremath Vaibhav' <hvaibhav@ti.com>, 'FUJITA Tomonori' <fujita.tomonori@lab.ntt.co.jp>, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Zach Pfeffer' <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello Hans,

I've just posted updated patchset.  It changes the way regions are
reserved somehow so our discussion is not entirely applicable to a
new version I think.

I preserved the original "map" there.  I came to a conclusion that
your approach is not that different from what I had in mind but I
noticed that with your syntax it's impossible to specify the order
of regions to try. For instance that driver should first try region
"foo" and then region "bar" and not the other way around.

I'm looking forward to hearing your comments on the newest version
of CMA.

-- =

Best regards,                                        _     _
| Humble Liege of Serenely Enlightened Majesty of  o' \,=3D./ `o
| Computer Science,  Micha=C5=82 "mina86" Nazarewicz       (o o)
+----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
