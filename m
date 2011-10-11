Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 2C68F6B002D
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 14:13:56 -0400 (EDT)
From: Krishna Reddy <vdumpa@nvidia.com>
Date: Tue, 11 Oct 2011 11:13:31 -0700
Subject: RE: [Linaro-mm-sig] [PATCH 1/2] ARM: initial proof-of-concept IOMMU
 mapper for DMA-mapping
Message-ID: <401E54CE964CD94BAE1EB4A729C7087E3722519A1F@HQMAIL04.nvidia.com>
References: <1314971786-15140-1-git-send-email-m.szyprowski@samsung.com>
 <1314971786-15140-2-git-send-email-m.szyprowski@samsung.com>
 <594816116217195c28de13accaf1f9f2.squirrel@www.codeaurora.org>
 <001f01cc786d$d55222c0$7ff66840$%szyprowski@samsung.com>
 <401E54CE964CD94BAE1EB4A729C7087E37225197F8@HQMAIL04.nvidia.com>
 <00b101cc87ee$8976c410$9c644c30$%szyprowski@samsung.com>
In-Reply-To: <00b101cc87ee$8976c410$9c644c30$%szyprowski@samsung.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Arnd Bergmann' <arnd@arndb.de>, 'Joerg Roedel' <joro@8bytes.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, 'Laura Abbott' <lauraa@codeaurora.org>

Marek,

>It looks that You have simplified arm_iommu_map_sg() function too much.=20
>The main advantage of the iommu is to map scattered memory pages into=20
>contiguous dma address space. DMA-mapping is allowed to merge consecutive
>entries in the scatter list if hardware supports that.
>http://article.gmane.org/gmane.linux.kernel/1128416

I would update arm_iommu_map_sg() back to coalesce the sg list.

>I'm not sure if mmc drivers are aware of coalescing the SG entries togethe=
r.
>If not the code must be updated to use dma_sg_len() and the dma entries
>number returned from dma_map_sg() call.

MMC drivers seem to be aware of coalescing the SG entries together as they =
are using dma_sg_len().

Let me test and update the patch.

--
nvpublic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
