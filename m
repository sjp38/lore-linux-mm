Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4363C6B02A4
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 20:50:54 -0400 (EDT)
Received: from eu_spt2 (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0L7F00GV0ECQ8V@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 20 Aug 2010 01:50:51 +0100 (BST)
Received: from localhost ([10.89.8.241])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0L7F00832EBK6O@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 20 Aug 2010 01:50:49 +0100 (BST)
Date: Fri, 20 Aug 2010 02:50:06 +0200
From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH/RFCv3 0/6] The Contiguous Memory Allocator framework
In-reply-to: <20100819144756.GA9485@phenom.dumpdata.com>
Message-id: <op.vhpolsnn7p4s8u@localhost>
MIME-version: 1.0
Content-type: text/plain; charset=utf-8; format=flowed; delsp=yes
Content-transfer-encoding: Quoted-Printable
References: <cover.1281100495.git.m.nazarewicz@samsung.com>
 <AANLkTikp49oOny-vrtRTsJvA3Sps08=w7__JjdA3FE8t@mail.gmail.com>
 <20100819144756.GA9485@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
To: Kyungmin Park <kyungmin.park@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-mm@kvack.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Pawel Osciak <p.osciak@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, linux-kernel@vger.kernel.org, Hiremath Vaibhav <hvaibhav@ti.com>, Hans Verkuil <hverkuil@xs4all.nl>, kgene.kim@samsung.com, Zach Pfeffer <zpfeffer@codeaurora.org>, jaeryul.oh@samsung.com, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010 16:47:56 +0200, Konrad Rzeszutek Wilk <konrad.wilk@o=
racle.com> wrote:
> Is there a git tree and/or link to the latest version that is based on=

> top 2.6.36-rc1?? I somehow seem to have lost the v3 of these patches.

I'm currently working on a v4 of the patchset after some comments from
Hans Verkuil on the #v4l.  I should manage to post it today (Korean time=
).

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
