Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 587B49000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 11:14:16 -0400 (EDT)
Received: by ywb26 with SMTP id 26so1386430ywb.14
        for <linux-mm@kvack.org>; Mon, 20 Jun 2011 08:14:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110620150610.GG26089@n2100.arm.linux.org.uk>
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
	<1308556213-24970-8-git-send-email-m.szyprowski@samsung.com>
	<BANLkTikFdrOuXsLCfvyA_V+p7S_fd72dyQ@mail.gmail.com>
	<20110620150610.GG26089@n2100.arm.linux.org.uk>
Date: Tue, 21 Jun 2011 00:14:14 +0900
Message-ID: <BANLkTimJDpKR4Nm8Lz3V1Yov=07wadAmfQ@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH 7/8] common: dma-mapping: change
 alloc/free_coherent method to more generic alloc/free_attrs
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-arch@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, linux-arm-kernel@lists.infradead.org

On Tue, Jun 21, 2011 at 12:06 AM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> Wrong - there is a difference. =A0For pre-ARMv6 CPUs, it returns memory
> with different attributes from DMA coherent memory.
>
> And we're not going to sweep away pre-ARMv6 CPUs any time soon. =A0So
> you can't ignore dma_alloc_writecombine() which must remain to sanely
> support framebuffers.
>
OK. Thanks.

Then, I think we can implement dma_alloc_writecombine() away from dma_map_o=
ps.
IMHO, those devices that use dma_alloc_writecombine() are enough with
the default dma_map_ops.
Removing a member from dma_map_ops is too heavy work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
