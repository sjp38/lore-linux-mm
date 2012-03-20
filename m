Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id D3E086B0044
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 19:56:53 -0400 (EDT)
Received: by lagz14 with SMTP id z14so623955lag.14
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 16:56:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F688B2D.20808@gmail.com>
References: <1330527862-16234-1-git-send-email-m.szyprowski@samsung.com>
	<1330527862-16234-10-git-send-email-m.szyprowski@samsung.com>
	<CAHQjnOO5DLOj8Fw=ZriSnXg8W3k7y8Dnu--Peqe6JJX0xGMhoQ@mail.gmail.com>
	<4F688B2D.20808@gmail.com>
Date: Wed, 21 Mar 2012 08:56:51 +0900
Message-ID: <CAHQjnOMjSPDOymJe356AWnJszQv+X-QWrVrB7ahYDkXBr5HrQw@mail.gmail.com>
Subject: Re: [PATCHv7 9/9] ARM: dma-mapping: add support for IOMMU mapper
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Subash Patel <subashrp@gmail.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, Shariq Hasnain <shariq.hasnain@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Krishna Reddy <vdumpa@nvidia.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>

On Tue, Mar 20, 2012 at 10:50 PM, Subash Patel <subashrp@gmail.com> wrote:
> Sorry for digging this very late. But as part of integrating dma_map v7 &
> sysmmu v12 on 3.3-rc5, I am facing below issue:
>
> a) By un-selecting IOMMU in menu config, I am able to allocate memory in
> vb2-dma-contig
>
> b) When I enable SYSMMU support for the IP's, I am receiving below fault:
>
> Unhandled fault: external abort on non-linefetch (0x818) at 0xb6f55000
>
> I think this has something to do with the access to the SYSMMU registers for
> writing the page table. Has anyone of you faced this issue while testing
> these(dma_map+iommu) patches on kernel mentioned above? This must be
> something related to recent changes, as I didn't have issues with these
> patches on 3.2 kernel.
>

0xb6f55000 is not an address of SYSMMU register if your kernel starts
at 0xc0000000.

Can you tell me any detailed information or situation?

Regards,

KyongHo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
