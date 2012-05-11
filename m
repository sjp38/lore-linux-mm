Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 3C78F6B004D
	for <linux-mm@kvack.org>; Thu, 10 May 2012 22:01:49 -0400 (EDT)
Received: by wibhn9 with SMTP id hn9so1034409wib.8
        for <linux-mm@kvack.org>; Thu, 10 May 2012 19:01:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALYq+qRFF-7p0P2+zG=4=s5+-D4pyB6G2wBCpuonoFRJ6FLo1Q@mail.gmail.com>
References: <CALYq+qRFF-7p0P2+zG=4=s5+-D4pyB6G2wBCpuonoFRJ6FLo1Q@mail.gmail.com>
Date: Fri, 11 May 2012 11:01:46 +0900
Message-ID: <CALYq+qSt+OU0FYBwA3a9hFMtBTFmGN--QmWowKz_pbZhJfurhQ@mail.gmail.com>
Subject: [Linaro-mm-sig] [PATCH 0/3] [RFC] Kernel Virtual Memory allocation
 issue in dma-mapping framework
From: Abhinav Kochhar <kochhar.abhinav@gmail.com>
Content-Type: multipart/alternative; boundary=e89a8f3baee370537204bfb91e27
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>

--e89a8f3baee370537204bfb91e27
Content-Type: text/plain; charset=ISO-8859-1

Hello,

This is a request for comments on dma-mapping patches for ARM. I
did some additions for issue related to kernel virtual memory allocations
in the iommu ops defined in dma-mapping framework.

The patches are based on:

git://git.linaro.org/people/mszyprowski/linux-dma-mapping.git3.4-rc3-arm-dma-v9

The code has been tested on Samsung Exynos5 SMDK5250.

These patches do the following:

1. Define a new dma attribute to identify user space allocation.

2. Add new wrapper functions to pass the dma attribute defined in (1)
above, as in the current framework there is no way to pass the new
attribute which can be used to differentiate between kernel and user
allocations.

3. Extend the existing arm_dma_ops for iommu enabled devices to
differentiate between kernel and user space allocations.

Patch summary:

[PATCH 1/3]:

Common: add DMA_ATTR_USER_SPACE to dma-attr. This can be passed to
arm_dma_ops to identify the type of allocation which can be either from
kernel or from user.

[PATCH 2/3]:

ARM: add "struct page_infodma" to hold information for allocated pages.
This can be attached to any of the devices which is making use of
dma-mapping APIs. Any interested device should allocate this structure and
store all the relevant information about the allocated pages to be able to
do a look up for all future references.

ARM: add dma_alloc_writecombine_user() function to pass DMA_ATTR_USER_SPACE
attribute

ARM: add dma_free_writecombine_user() function to pass DMA_ATTR_USER_SPACE
attribute

ARM: add dma_mmap_writecombine_user() function to pass DMA_ATTR_USER_SPACE
attribute

[PATCH 3/3]:

ARM: add check for allocation type in __dma_alloc_remap() function

ARM: add check for allocation type in arm_iommu_alloc_attrs() function

ARM: add check for allocation type in arm_iommu_mmap_attrs() function

ARM: re-used dma_addr as a flag to check for memory allocation type. It was
an unused argument and the prototype does not pass dma-attrs, so used this
as a means to pass the flag.

ARM: add check for allocation type in arm_iommu_free_attrs() function

arch/arm/include/asm/dma-mapping.h |   31 +++++++

arch/arm/mm/dma-mapping.c          |  168
++++++++++++++++++++++++++----------

include/linux/dma-attrs.h          |    1 +

3 files changed, 155 insertions(+), 45 deletions(-)

--e89a8f3baee370537204bfb91e27
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<p>Hello,</p>
<p>This is a=A0request for comments=A0on dma-mapping patches for ARM. I did=
=A0some=A0additions=A0for issue related to kernel virtual memory allocation=
s in the iommu ops defined in dma-mapping framework.=A0</p>
<p>The patches are based on:</p>
<p>git://<a href=3D"http://git.linaro.org/people/mszyprowski/linux-dma-mapp=
ing.git">git.linaro.org/people/mszyprowski/linux-dma-mapping.git</a> 3.4-rc=
3-arm-dma-v9</p>
<p>The code has been tested on Samsung Exynos5=A0SMDK5250.</p>
<p>These patches do the following:</p>
<p>1. Define a new dma attribute to identify user space allocation.</p>
<p>2. Add new wrapper functions to pass the dma attribute defined in (1) ab=
ove, as in the current framework there is no way to pass the new attribute =
which can be used to differentiate between kernel and user allocations.</p>

<p>3. Extend the existing arm_dma_ops for iommu enabled devices to differen=
tiate between kernel and user space allocations.</p>
<p>Patch summary:</p>
<p>[PATCH 1/3]:</p>
<p>Common: add DMA_ATTR_USER_SPACE to dma-attr. This can be passed to arm_d=
ma_ops to identify the type of allocation which can be either from kernel o=
r from user.</p>
<p>[PATCH 2/3]:</p>
<p>ARM:=A0add &quot;struct page_infodma&quot; to hold information for alloc=
ated pages. This can be attached to any of the devices which is making use =
of dma-mapping APIs. Any interested device should allocate this structure a=
nd store all the relevant information about the allocated pages to be able =
to do a look up for all future references.</p>

<p>ARM: add dma_alloc_writecombine_user() function to pass DMA_ATTR_USER_SP=
ACE attribute</p>
<p>ARM: add dma_free_writecombine_user() function to pass DMA_ATTR_USER_SPA=
CE attribute</p>
<p>ARM: add dma_mmap_writecombine_user() function to pass DMA_ATTR_USER_SPA=
CE attribute</p>
<p>[PATCH 3/3]:</p>
<p>ARM: add check for allocation type in __dma_alloc_remap() function</p>
<p>ARM: add check for allocation type in arm_iommu_alloc_attrs() function</=
p>
<p>ARM: add check for allocation type in arm_iommu_mmap_attrs() function</p=
>
<p>ARM: re-used dma_addr as a flag to check for memory allocation type. It =
was an unused argument and the prototype does not pass dma-attrs, so used t=
his as a means to pass the flag.</p>
<p>ARM: add check for allocation type in arm_iommu_free_attrs() function<br=
></p>
<p>arch/arm/include/asm/dma-mapping.h |=A0=A0=A031 +++++++</p>
<p>arch/arm/mm/dma-mapping.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0|=A0=A0168 ++++++=
++++++++++++++++++++----------</p>
<p>include/linux/dma-attrs.h=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0|=A0=A0=A0=A01 +<=
/p>
<p>3 files changed, 155 insertions(+), 45 deletions(-)</p>

--e89a8f3baee370537204bfb91e27--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
