Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id D26606B00EE
	for <linux-mm@kvack.org>; Tue,  6 Sep 2011 06:28:02 -0400 (EDT)
Received: by fxg9 with SMTP id 9so5640923fxg.14
        for <linux-mm@kvack.org>; Tue, 06 Sep 2011 03:28:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1314971786-15140-3-git-send-email-m.szyprowski@samsung.com>
References: <1314971786-15140-1-git-send-email-m.szyprowski@samsung.com>
	<1314971786-15140-3-git-send-email-m.szyprowski@samsung.com>
Date: Tue, 6 Sep 2011 19:27:59 +0900
Message-ID: <CAHQjnONHr-Ao_KLjdRKgVQQUKtOmmoyqFwdkSZCDsE6hx1q-Ug@mail.gmail.com>
Subject: Re: [PATCH 2/2] ARM: Samsung: update/rewrite Samsung SYSMMU (IOMMU) driver
From: KyongHo Cho <pullip.cho@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Kukjin Kim <kgene.kim@samsung.com>, Linux Samsung SOC <linux-samsung-soc@vger.kernel.org>

Hi.

On Fri, Sep 2, 2011 at 10:56 PM, Marek Szyprowski
<m.szyprowski@samsung.com> wrote:
> + *
> + * iova must be aligned on a 4kB, 64kB, 1MB and 16MB boundaries, respect=
ively.
> + */

Actually, iova is just needed to be aligned by 4KiB because it is
minimum requirement.
I think IOMMU driver is capable of mapping a group of page frames that
is aligned
by 1MiB with an iova that is aligned by 4KB
if the iova is large enough to map the given page frames.

> +static int s5p_sysmmu_map(struct iommu_domain *domain, unsigned long iov=
a,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 phys_addr_t paddr, int =
gfp_order, int prot)
> +{
> + =A0 =A0 =A0 struct s5p_sysmmu_domain *s5p_domain =3D domain->priv;
> + =A0 =A0 =A0 int flpt_idx =3D flpt_index(iova);
> + =A0 =A0 =A0 size_t len =3D 0x1000UL << gfp_order;
> + =A0 =A0 =A0 void *flpt_va, *slpt_va;
> +
> + =A0 =A0 =A0 if (len !=3D SZ_16M && len !=3D SZ_1M && len !=3D SZ_64K &&=
 len !=3D SZ_4K) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 sysmmu_debug(3, "bad order: %d\n", gfp_orde=
r);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EINVAL;
> + =A0 =A0 =A0 }

Likewise, I think this driver need to support mapping 128KiB aligned,
128KiB physical memory, for example.

Otherwise, it is somewhat restrictive than we expect.

Thank you.

Cho KyongHo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
