Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00D5EC282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:48:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8034C20881
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 23:48:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8034C20881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3E548E0002; Tue, 29 Jan 2019 18:48:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEDA78E0001; Tue, 29 Jan 2019 18:48:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDC728E0002; Tue, 29 Jan 2019 18:48:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id A32D98E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 18:48:00 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id x125so23383643qka.17
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:48:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=vLNFJzh1xssdIyzw8xz3b4zr9mr7LpgEYMNgaQzYyHU=;
        b=HFooTFAXCEQqzFuX8/VNFdDjZOGeWHhko6yVy4t8IPn6NZgnabzm/h2JveqrEMMwaq
         B+tJWQGqIwQwmxT42ofEM+IoxwKJIY7Dss0i/Ju77l8sqUsGKXAvf94F6NdGm3aVldW1
         CqKjCArnJiLz6zSern4+xc6GxTdH7G1faiCdCDF/IbMFdrIuOmu34oIZzaT3+Doep/Zj
         t9JgZqbhEEIZHGlILhh5v8/AaMpS2iRk4vDCSG8oKTZlRjgjURTEdPmGRT5USonjpeO2
         7oylupEzdrEQ3F8NL8ryWoWsqO5058qzDYxuCKIpGKFZpeYKhPgslxob017Soki65ZOv
         Qt0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukd6GltqUl77rl38/8c2kwhTLBuLl0l6nIpKfPY/cljkWDcctlOx
	sjBG46LVU99gzNHAUR4vsZBMgQwo3N2y0bl0B/GAZO1xyAVI+TnUnvpzgg7yCjpu7pbblzTuX+u
	3yCVUlR4Jw+5WF8w4g3dK28GLA3kEvrgIQYFy8vBVKPhKwCGB3wP94CKS0zsyLSu9/w==
X-Received: by 2002:ac8:3437:: with SMTP id u52mr26830922qtb.237.1548805680337;
        Tue, 29 Jan 2019 15:48:00 -0800 (PST)
X-Google-Smtp-Source: ALg8bN782tg/3VbHLT6W2DllyqZYtOoyI5EXyZMP7maK/Y7rlsZICQJsyVeg/eblkaS/mvk9hC0I
X-Received: by 2002:ac8:3437:: with SMTP id u52mr26830880qtb.237.1548805679231;
        Tue, 29 Jan 2019 15:47:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548805679; cv=none;
        d=google.com; s=arc-20160816;
        b=J8IXksCdpGUngLHvJsUjehh/47y+URMEs4NaTOxJdY/hghO7Pg2o4fv2ZukQ/0G+fk
         dyHxiZ8J9asyqgtFpptJ9GOjf2+2NMtMT84MacGfsF9pA770KpbgezWS2+oK/Abjeogk
         XdxFdjhAf5WM1PeF6bOePRaud5D/JOPhFfeO8I0AasmP+KdOK36HIZ2i5BqF/O2fTvbl
         x/MrcdV4unE7GWdTXzrOLTnB96W0J0gx8b4zv4tAjla/OEYADLKoLmKZDGtkqPrVMYF7
         aLD7WovBwtUtQ5iyfuwoG52+gCl/XDGtE1RL+hU7Xo7yuDD/b0VAT7uskTG1oeL2xy1r
         vADA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=vLNFJzh1xssdIyzw8xz3b4zr9mr7LpgEYMNgaQzYyHU=;
        b=zFghKvPQiGMquQM7BtvV1j4ds1Cm5mTbDtoDUsal74m2lIBPSwKNd7MxA1MwD8Y4FO
         3ZG0WmEf7Dy+JdZu/ksiY/bmNgH1PUiZy8wyYmIyEwwD/IaQzr68BKonjQaL8xjWZx8u
         6kgarbIHLly2cOiKT9BMMbPhi1qZWmv2TNfHFCm92tINX9nNzaSgw830gB4sK2InTppt
         bpcuwPjeB0s+7Ui4aUE3KTE8eIIJiB3q3Dk5OKC+QCF2Q/bD7Vh07wD21JzBrcVwZ/SU
         74Uian4rLOs8H47UWvIFqcfgT30qurgJOOMTwm5VOz40R+UP2+4A+v00tH51Ej0A5W84
         K6Cg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g1si5517480qtr.315.2019.01.29.15.47.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 15:47:59 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 231C889AC5;
	Tue, 29 Jan 2019 23:47:58 +0000 (UTC)
Received: from redhat.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A8C965C3FD;
	Tue, 29 Jan 2019 23:47:54 +0000 (UTC)
Date: Tue, 29 Jan 2019 18:47:52 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Message-ID: <20190129234752.GR3176@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com>
 <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205749.GN3176@redhat.com>
 <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com>
 <20190129215028.GQ3176@redhat.com>
 <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 29 Jan 2019 23:47:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 03:58:45PM -0700, Logan Gunthorpe wrote:
> 
> 
> On 2019-01-29 2:50 p.m., Jerome Glisse wrote:
> > No this is the non HMM case i am talking about here. Fully ignore HMM
> > in this frame. A GPU driver that do not support or use HMM in anyway
> > has all the properties and requirement i do list above. So all the points
> > i was making are without HMM in the picture whatsoever. I should have
> > posted this a separate patches to avoid this confusion.
> > 
> > Regarding your HMM question. You can not map HMM pages, all code path
> > that would try that would trigger a migration back to regular memory
> > and will use the regular memory for CPU access.
> > 
> 
> I thought this was the whole point of HMM... And eventually it would
> support being able to map the pages through the BAR in cooperation with
> the driver. If not, what's that whole layer for? Why not just have HMM
> handle this situation?

The whole point is to allow to use device memory for range of virtual
address of a process when it does make sense to use device memory for
that range. So they are multiple cases where it does make sense:
[1] - Only the device is accessing the range and they are no CPU access
      For instance the program is executing/running a big function on
      the GPU and they are not concurrent CPU access, this is very
      common in all the existing GPGPU code. In fact AFAICT It is the
      most common pattern. So here you can use HMM private or public
      memory.
[2] - Both device and CPU access a common range of virtul address
      concurrently. In that case if you are on a platform with cache
      coherent inter-connect like OpenCAPI or CCIX then you can use
      HMM public device memory and have both access the same memory.
      You can not use HMM private memory.

So far on x86 we only have PCIE and thus so far on x86 we only have
private HMM device memory that is not accessible by the CPU in any
way.

It does not make that memory useless, far from it. Having only the
device work on the dataset while CPU is either waiting or accessing
something else is very common.


Then HMM is a toolbox, so here are some of the tools:
    HMM mirror - helper to mirror process address on to a device
    ie this is SVM(Share Virtual Memory)/SVA(Share Virtual Address)
    in software

    HMM private memory - allow to register device memory with the linux
    kernel. The memory is not CPU accessible. The memory is fully manage
    by the device driver. What and when to migrate is under the control
    of the device driver.

    HMM public memory - allow to register device memory with the linux
    kernel. The memory must be CPU accessible and cache coherent and
    abide by the platform memory model. The memory is fully manage by
    the device driver because otherwise it would disrupt the device
    driver operation (for instance GPU can also be use for graphics).

    Migration - helper to perform migration to and from device memory.
    It does not make any decission on itself it just perform all the
    steps in the right order and call back into the driver to get the
    migration going.

It is up to device driver to implement heuristic and provide userspace
API to control memory migration to and from device memory. For device
private memory on CPU page fault the kernel will force a migration back
to system memory so that the CPU can access the memory. What matter here
is that the memory model of the platform is intact and thus you can
safely use CPU atomic operation or rely on your platform memory model
for your program. Note that long term i would like to define common API
to expose to userspace to manage memory binding to specific device
memory so that we can mix and match multiple device memory into a single
process and define policy too.

Also CPU atomic instruction to PCIE BAR gives _undefined_ results and in
fact on some AMD/Intel platform it leads to weirdness/crash/freeze. So
obviously we can not map PCIE BAR to CPU without breaking the memory
model. More over on PCIE you might not be able to resize the BAR to
expose all the device memory. GPU can have several giga bytes of memory
and not all of them support PCIE bar resize, and sometimes PCIE bar
resize does not work either because of bios/firmware issue or simply
because you are running out of IO space.

So on x86 we are stuck with HMM private memory, i am hopping that some
day in the future we will have CCIX or something similar. But for now
we have to work with what we have.

> And what struct pages are actually going to be backing these VMAs if
> it's not using HMM?

When you have some range of virtual address migrated to HMM private
memory then the CPU pte are special swap entry and they behave just
as if the memory was swapped to disk. So CPU access to those will
fault and trigger a migration back to main memory.

We still want to allow peer to peer to exist when using HMM memory
for a range of virtual address (of a vma that is not an mmap of a
device file) because the peer device do not rely on atomic or on the
platform memory model. In those cases we assume that the importer is
aware of the limitation and is asking access in good faith and thus
we want to allow the exporting device to either allow the peer mapping
(because it has enough BAR address to map) or fall back to main memory.


> > Again HMM has nothing to do here, ignore HMM it does not play any role
> > and it is not involve in anyway here. GPU want to control what object
> > they allow other device to access and object they do not allow. GPU driver
> > _constantly_ invalidate the CPU page table and in fact the CPU page table
> > do not have any valid pte for a vma that is an mmap of GPU device file
> > for most of the vma lifetime. Changing that would highly disrupt and
> > break GPU drivers. They need to control that, they need to control what
> > to do if another device tries to peer map some of their memory. Hence
> > why they need to implement the callback and decide on wether or not they
> > allow the peer mapping or use device memory for it (they can decide to
> > fallback to main memory).
> 
> But mapping is an operation of the memory/struct pages behind the VMA;
> not of the VMA itself and I think that's evident by the code in that the
> only way the VMA layer is involved is the fact that you're abusing
> vm_ops by adding new ops there and calling it by other layers.

For GPU driver the vma pte are populated on CPU page fault and they get
clear quickly after. A very usual pattern is:
    - CPU write something to the object through the object mapping ie
      through a vma. This trigger page fault which call the fault()
      callback from vm_operations struct. This populate the page table
      for the vma.
    - Userspace launch commands on the GPU, first thing kernel do is
      clear all CPU page table entry for objects listed in the commands
      ie we do not except any further CPU access nor do we want it.

GPU driver have always been geared toward minimizing CPU access to GPU
memory. For object that need to be access by both concurrently we use the
main memory and not the device memory.

So in fact you will almost never have valid pte for an mmap of a GPU
object (done throught the GPU device file). However it does not mean that
we want to block peer to peer to happen. Today the use cases we know for
peer to peer are with GPUDirect (NVidia) or ROCmDMA (AMD) roughly the
same thing. Most common use cases i am aware are:
    - RDMA is streaming in input directly into GPU memory avoiding the
      need to have a bounce buffer into memory (this save both main
      memory and PCIE bandwidth by avoiding RDMA->main then main->GPU).
    - RDMA is streaming out result (same idea as streaming in but in
      the other direction :))
    - RDMA is use to monitor computation progress on the GPU and it
      tries to do so with minimal disruption to the GPU. So RDMA would
      like to be able to peek into GPU memory to fetch some values
      and transmit them over the network.

I believe people would like to have more complex use case, like for
instance having the GPU be able to directly control some RDMA queue
to request data to some other host on the networ, or control some
block device queue to read data from block device directly. I believe
those can be implemented with the API set forward in those patches.

So for those above use cases it is fine to not have valid CPU pte and
only have peer to peer mapping. The CPU is not expected to be involve
and we should not make it a requirement. Hence we should not expect
to have valid pte.


Also another common use case is that GPU driver might leave pte that
points to main memory while the GPU is using device memory for the
object corresponding to the vma those pte are in. Expectation is that
the CPU access are synchronized with the device access through the
API use by the application. Note here we are talking non HMM, non SVM
case ie special object that are allocated through API specific functions
that result in driver ioctl and mmap of device file.


Hopes this helps understand the big picture from GPU driver point of
view :)

Cheers,
Jérôme

