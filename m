Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 4C06F6B0033
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 10:21:14 -0400 (EDT)
Subject: Re: [PATCH -V3 1/4] mm/cma: Move dma contiguous changes into a seperate config
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Alexander Graf <agraf@suse.de>
In-Reply-To: <1372743918-12293-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Mon, 8 Jul 2013 16:21:05 +0200
Content-Transfer-Encoding: quoted-printable
Message-Id: <1C7CE5C5-A66F-4EB1-B9D0-EED8B555E146@suse.de>
References: <1372743918-12293-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, m.szyprowski@samsung.com, mina86@mina86.com, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, kvm@vger.kernel.org


On 02.07.2013, at 07:45, Aneesh Kumar K.V wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>=20
> We want to use CMA for allocating hash page table and real mode area =
for
> PPC64. Hence move DMA contiguous related changes into a seperate =
config
> so that ppc64 can enable CMA without requiring DMA contiguous.
>=20
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> Acked-by: Paul Mackerras <paulus@samba.org>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Thanks, applied all to kvm-ppc-queue. Please provide a cover letter next =
time :).


Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
