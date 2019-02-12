Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B83BC282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:21:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 165F1214DA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 13:21:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 165F1214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D2B98E0013; Tue, 12 Feb 2019 08:21:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7831B8E0011; Tue, 12 Feb 2019 08:21:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 671788E0013; Tue, 12 Feb 2019 08:21:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A0348E0011
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:21:52 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id u7so2349199edj.10
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:21:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language
         :content-transfer-encoding:mime-version;
        bh=t3RsL3SMelMTTdSZMj4vqBTqYzktafmOevpe3iETmBE=;
        b=gjocjmUziieDwpK+BGaE3h01Ue7WSuaiAXbBAYqXax1iHBpF1ZApNlIKNUXB4hbkft
         oRn2Jv9qB1B5alBdWXXNKteWqX7hQgdTojDZMWY/EqJFBmlTucLa1sTlWD8D5o/39d+Y
         dAkawYRtdRUUp5l1LKouvrjUKTy5q1OU8PkI1MDVlLe+f7PX9gtGnoKw0nNIAgseWLfF
         4og5xS0sDuOtUBzTV1umN8jEIbvxPMZKi4LJ/+Nld/9SkzYv32pcetN7VZPDh/q4SdUo
         YuU05nV9ZoTzIkGdpthsuCDcg4bg5lbLZ+OCNQrM53/t/yXUVzxQFvz1TU2u0P5wHKzL
         oaVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of shameerali.kolothum.thodi@huawei.com designates 185.176.76.210 as permitted sender) smtp.mailfrom=shameerali.kolothum.thodi@huawei.com
X-Gm-Message-State: AHQUAuYv26c/296Wwg/ROjx1sbtOUkFw4idSy85UhcpNRNUzF2AYT05t
	dprgVh7fPVEtiL8O9M0RIoKaggEZGU028Gz72/0bZUN5TIR/OmqB5YpeqztLGNBjMMLuCPCgD+l
	VsnOdp2dzj054JOQVBNcwT/3axegUqMzvdQIcwHZri5pd17GkCiRoWPn/R9GWPW/IWw==
X-Received: by 2002:a17:906:6053:: with SMTP id p19mr2668962ejj.227.1549977711506;
        Tue, 12 Feb 2019 05:21:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZQuGNeYE2oDxguV0DZrqZnyR7UD/uwHyrUruHartquSU8esx75kdxCqcwmL0PwanXU/5TG
X-Received: by 2002:a17:906:6053:: with SMTP id p19mr2668851ejj.227.1549977709312;
        Tue, 12 Feb 2019 05:21:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549977709; cv=none;
        d=google.com; s=arc-20160816;
        b=aAKVg02DVbR4KSzUbgraKNKD3giUSyV7BfPjXlmxWK+/EGR9FPzSf7pu+fmP701KTk
         kbMlDn7ZPelj6gXsWjX8Vb/mFe6NuEwDOoexeY2hxHCL95/Hv2tfjUnOqQuRAHZAHXmP
         9zymeQqWWa5AIRpwrCw8Yxo6Q2fRfQVyM/x/W/6Ne1T2iCYpr48heGvLSGZZPTyHC//e
         sgZTgwsw+y3AmJmYLXBAg1EQW5H86z0IPBHaT0t7Oj6W2m/glE57CMCpwmuaKaSQ8OdG
         VchOdjnlB6Yfis/2SPcdtdweJqJydAo+ShHQiTzbgdhkby41AziT7qk9L+spJ2c7T8xQ
         JF3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=t3RsL3SMelMTTdSZMj4vqBTqYzktafmOevpe3iETmBE=;
        b=cKQ9USaMOYoyyrC7sCoGwamSJI8SlYF8UWXqiE/I5ePWTZ1ZKWRbgF7Fz1G9/IS/Y7
         IfgzJEJj5iKifYGnEJ5owR+AjXkegJiz+/ND2lTfb9EMcawhkcCw0yGsOIe34KO1skQA
         zRk12V0mvRSb2f4W7nfJnvzBVevMFgCqNJTIAhrVGzGp0nmBOkLNdTm+PUu5/3yq8sb2
         Gj+PmvGitanH/csdRYknt+sV8R/+CArvI+QNrzJnwIAm61zcQSKkw1vUAzYqp4p/mdf4
         fe8DjoZ5SiKHFBGFpskbp984c+f1wNtMa8cOw7dbTtOGYYJVVrXo8IXCU1zBJHS/jrBm
         w9Xg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of shameerali.kolothum.thodi@huawei.com designates 185.176.76.210 as permitted sender) smtp.mailfrom=shameerali.kolothum.thodi@huawei.com
Received: from huawei.com (lhrrgout.huawei.com. [185.176.76.210])
        by mx.google.com with ESMTPS id b28si1600262edd.78.2019.02.12.05.21.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 05:21:49 -0800 (PST)
Received-SPF: pass (google.com: domain of shameerali.kolothum.thodi@huawei.com designates 185.176.76.210 as permitted sender) client-ip=185.176.76.210;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of shameerali.kolothum.thodi@huawei.com designates 185.176.76.210 as permitted sender) smtp.mailfrom=shameerali.kolothum.thodi@huawei.com
Received: from lhreml701-cah.china.huawei.com (unknown [172.18.7.106])
	by Forcepoint Email with ESMTP id B2E65315BB3DCEAA294A;
	Tue, 12 Feb 2019 13:21:48 +0000 (GMT)
Received: from LHREML524-MBS.china.huawei.com ([169.254.2.78]) by
 lhreml701-cah.china.huawei.com ([10.201.108.42]) with mapi id 14.03.0415.000;
 Tue, 12 Feb 2019 13:21:39 +0000
From: Shameerali Kolothum Thodi <shameerali.kolothum.thodi@huawei.com>
To: Jonathan Cameron <jonathan.cameron@huawei.com>, Oscar Salvador
	<osalvador@suse.de>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@suse.com"
	<mhocko@suse.com>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>,
	"Pavel.Tatashin@microsoft.com" <Pavel.Tatashin@microsoft.com>,
	"david@redhat.com" <david@redhat.com>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>, "dave.hansen@intel.com"
	<dave.hansen@intel.com>, Linuxarm <linuxarm@huawei.com>, Robin Murphy
	<robin.murphy@arm.com>
Subject: RE: [RFC PATCH v2 0/4] mm, memory_hotplug: allocate memmap from
 hotadded memory
Thread-Topic: [RFC PATCH v2 0/4] mm, memory_hotplug: allocate memmap from
 hotadded memory
Thread-Index: AQHUwtEdigDNP0y6HEKCgupIm+NFFKXcIEiQ
Date: Tue, 12 Feb 2019 13:21:38 +0000
Message-ID: <5FC3163CFD30C246ABAA99954A238FA8392B5DB6@lhreml524-mbs.china.huawei.com>
References: <20190122103708.11043-1-osalvador@suse.de>
 <20190212124707.000028ea@huawei.com>
In-Reply-To: <20190212124707.000028ea@huawei.com>
Accept-Language: en-GB, en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.202.227.237]
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> -----Original Message-----
> From: Jonathan Cameron
> Sent: 12 February 2019 12:47
> To: Oscar Salvador <osalvador@suse.de>
> Cc: linux-mm@kvack.org; mhocko@suse.com; dan.j.williams@intel.com;
> Pavel.Tatashin@microsoft.com; david@redhat.com;
> linux-kernel@vger.kernel.org; dave.hansen@intel.com; Shameerali Kolothum
> Thodi <shameerali.kolothum.thodi@huawei.com>; Linuxarm
> <linuxarm@huawei.com>; Robin Murphy <robin.murphy@arm.com>
> Subject: Re: [RFC PATCH v2 0/4] mm, memory_hotplug: allocate memmap from
> hotadded memory
>=20
> On Tue, 22 Jan 2019 11:37:04 +0100
> Oscar Salvador <osalvador@suse.de> wrote:
>=20
> > Hi,
> >
> > this is the v2 of the first RFC I sent back then in October [1].
> > In this new version I tried to reduce the complexity as much as possibl=
e,
> > plus some clean ups.
> >
> > [Testing]
> >
> > I have tested it on "x86_64" (small/big memblocks) and on "powerpc".
> > On both architectures hot-add/hot-remove online/offline operations
> > worked as expected using vmemmap pages, I have not seen any issues so f=
ar.
> > I wanted to try it out on Hyper-V/Xen, but I did not manage to.
> > I plan to do so along this week (if time allows).
> > I would also like to test it on arm64, but I am not sure I can grab
> > an arm64 box anytime soon.
>=20
> Hi Oscar,
>=20
> I ran tests on one of our arm64 machines. Particular machine doesn't actu=
ally
> have
> the mechanics for hotplug, so was all 'faked', but software wise it's all=
 the
> same.
>=20
> Upshot, seems to work as expected on arm64 as well.
> Tested-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
>=20
> Remove currently relies on some out of tree patches (and dirty hacks) due
> to the usual issue with how arm64 does pfn_valid. It's not even vaguely
> ready for upstream. I'll aim to post an informational set for anyone else
> testing in this area (it's more or less just a rebase of the patches from
> a few years ago).
>=20
> +CC Shameer who has been testing the virtualization side for more details=
 on
> that,=20

Right, I have sent out a RFC series[1] to enable mem hotplug for Qemu ARM v=
irt
platform. Using this Qemu, I ran few tests with your patches on a HiSilicon=
 ARM64
platform. Looks like it is doing the job.

root@ubuntu:~# uname -a
Linux ubuntu 5.0.0-rc1-mm1-00173-g22b0744 #5 SMP PREEMPT Tue Feb 5 10:32:26=
 GMT 2019 aarch64 aarch64 aarch64 GNU/Linux

root@ubuntu:~# numactl -H
available: 2 nodes (0-1)
node 0 cpus: 0
node 0 size: 981 MB
node 0 free: 854 MB
node 1 cpus:
node 1 size: 0 MB
node 1 free: 0 MB
node distances:
node   0   1=20
  0:  10  20=20
  1:  20  10=20
root@ubuntu:~# (qemu)=20
(qemu) object_add memory-backend-ram,id=3Dmem1,size=3D1G
(qemu) device_add pc-dimm,id=3Ddimm1,memdev=3Dmem1,node=3D1
root@ubuntu:~#=20
root@ubuntu:~# numactl -H
available: 2 nodes (0-1)
node 0 cpus: 0
node 0 size: 981 MB
node 0 free: 853 MB
node 1 cpus:
node 1 size: 1008 MB
node 1 free: 1008 MB
node distances:
node   0   1=20
  0:  10  20=20
  1:  20  10=20
root@ubuntu:~# =20

FWIW,
Tested-by: Shameer Kolothum <shameerali.kolothum.thodi@huawei.com>

Thanks,
Shameer
[1] https://lists.gnu.org/archive/html/qemu-devel/2019-01/msg06966.html

and Robin who is driving forward memory hotplug in general on the arm64
> side.
>=20
> Thanks,
>=20
> Jonathan
>=20
> >
> > [Coverletter]:
> >
> > This is another step to make the memory hotplug more usable. The primar=
y
> > goal of this patchset is to reduce memory overhead of the hot added
> > memory (at least for SPARSE_VMEMMAP memory model). The current way
> we use
> > to populate memmap (struct page array) has two main drawbacks:
> >
> > a) it consumes an additional memory until the hotadded memory itself is
> >    onlined and
> > b) memmap might end up on a different numa node which is especially tru=
e
> >    for movable_node configuration.
> >
> > a) is problem especially for memory hotplug based memory "ballooning"
> >    solutions when the delay between physical memory hotplug and the
> >    onlining can lead to OOM and that led to introduction of hacks like =
auto
> >    onlining (see 31bc3858ea3e ("memory-hotplug: add automatic onlining
> >    policy for the newly added memory")).
> >
> > b) can have performance drawbacks.
> >
> > I have also seen hot-add operations failing on powerpc due to the fact
> > that we try to use order-8 pages when populating the memmap array.
> > Given 64KB base pagesize, that is 16MB.
> > If we run out of those, we just fail the operation and we cannot add
> > more memory.
> > We could fallback to base pages as x86_64 does, but we can do better.
> >
> > One way to mitigate all these issues is to simply allocate memmap array
> > (which is the largest memory footprint of the physical memory hotplug)
> > from the hotadded memory itself. VMEMMAP memory model allows us to
> map
> > any pfn range so the memory doesn't need to be online to be usable
> > for the array. See patch 3 for more details. In short I am reusing an
> > existing vmem_altmap which wants to achieve the same thing for nvdim
> > device memory.
> >
> > There is also one potential drawback, though. If somebody uses memory
> > hotplug for 1G (gigantic) hugetlb pages then this scheme will not work
> > for them obviously because each memory block will contain reserved
> > area. Large x86 machines will use 2G memblocks so at least one 1G page
> > will be available but this is still not 2G...
> >
> > I am not really sure somebody does that and how reliable that can work
> > actually. Nevertheless, I _believe_ that onlining more memory into
> > virtual machines is much more common usecase. Anyway if there ever is a
> > strong demand for such a usecase we have basically 3 options a) enlarge
> > memory blocks even more b) enhance altmap allocation strategy and reuse
> > low memory sections to host memmaps of other sections on the same NUMA
> > node c) have the memmap allocation strategy configurable to fallback to
> > the current allocation.
> >
> > [Overall design]:
> >
> > Let us say we hot-add 2GB of memory on a x86_64 (memblock size =3D 128M=
).
> > That is:
> >
> >  - 16 sections
> >  - 524288 pages
> >  - 8192 vmemmap pages (out of those 524288. We spend 512 pages for each
> section)
> >
> >  The range of pages is: 0xffffea0004000000 - 0xffffea0006000000
> >  The vmemmap range is:  0xffffea0004000000 - 0xffffea0004080000
> >
> >  0xffffea0004000000 is the head vmemmap page (first page), while all th=
e
> others
> >  are "tails".
> >
> >  We keep the following information in it:
> >
> >  - Head page:
> >    - head->_refcount: number of sections
> >    - head->private :  number of vmemmap pages
> >  - Tail page:
> >    - tail->freelist : pointer to the head
> >
> > This is done because it eases the work in cases where we have to comput=
e
> the
> > number of vmemmap pages to know how much do we have to skip etc, and to
> keep
> > the right accounting to present_pages.
> >
> > When we want to hot-remove the range, we need to be careful because the
> first
> > pages of that range, are used for the memmap maping, so if we remove
> those
> > first, we would blow up while accessing the others later on.
> > For that reason we keep the number of sections in head->_refcount, to k=
now
> how
> > much do we have to defer the free up.
> >
> > Since in a hot-remove operation, sections are being removed sequentiall=
y, the
> > approach taken here is that every time we hit free_section_memmap(), we
> decrease
> > the refcount of the head.
> > When it reaches 0, we know that we hit the last section, so we call
> > vmemmap_free() for the whole memory-range in backwards, so we make
> sure that
> > the pages used for the mapping will be latest to be freed up.
> >
> > The accounting is as follows:
> >
> >  Vmemmap pages are charged to spanned/present_paged, but not to
> manages_pages.
> >
> > I yet have to check a couple of things like creating an accounting item
> > like VMEMMAP_PAGES to show in /proc/meminfo to ease to spot the
> memory that
> > went in there, testing Hyper-V/Xen to see how they react to the fact th=
at
> > we are using the beginning of the memory-range for our own purposes, an=
d
> to
> > check the thing about gigantic pages + hotplug.
> > I also have to check that there is no compilation/runtime errors when
> > CONFIG_SPARSEMEM but !CONFIG_SPARSEMEM_VMEMMAP.
> > But before that, I would like to get people's feedback about the overal=
l
> > design, and ideas/suggestions.
> >
> >
> > [1] https://patchwork.kernel.org/cover/10685835/
> >
> > Michal Hocko (3):
> >   mm, memory_hotplug: cleanup memory offline path
> >   mm, memory_hotplug: provide a more generic restrictions for memory
> >     hotplug
> >   mm, sparse: rename kmalloc_section_memmap,
> __kfree_section_memmap
> >
> > Oscar Salvador (1):
> >   mm, memory_hotplug: allocate memmap from the added memory range
> for
> >     sparse-vmemmap
> >
> >  arch/arm64/mm/mmu.c            |  10 ++-
> >  arch/ia64/mm/init.c            |   5 +-
> >  arch/powerpc/mm/init_64.c      |   7 ++
> >  arch/powerpc/mm/mem.c          |   6 +-
> >  arch/s390/mm/init.c            |  12 ++-
> >  arch/sh/mm/init.c              |   6 +-
> >  arch/x86/mm/init_32.c          |   6 +-
> >  arch/x86/mm/init_64.c          |  20 +++--
> >  drivers/hv/hv_balloon.c        |   1 +
> >  drivers/xen/balloon.c          |   1 +
> >  include/linux/memory_hotplug.h |  42 ++++++++--
> >  include/linux/memremap.h       |   2 +-
> >  include/linux/page-flags.h     |  23 +++++
> >  kernel/memremap.c              |   9 +-
> >  mm/compaction.c                |   8 ++
> >  mm/memory_hotplug.c            | 186
> +++++++++++++++++++++++++++++------------
> >  mm/page_alloc.c                |  47 ++++++++++-
> >  mm/page_isolation.c            |  13 +++
> >  mm/sparse.c                    | 124
> +++++++++++++++++++++++++--
> >  mm/util.c                      |   2 +
> >  20 files changed, 431 insertions(+), 99 deletions(-)
> >
>=20

