Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A02C6C4151A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 06:56:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3ABF72184A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 06:56:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ozlabs-ru.20150623.gappssmtp.com header.i=@ozlabs-ru.20150623.gappssmtp.com header.b="ExhGQar3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3ABF72184A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ozlabs.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C51478E0013; Tue, 12 Feb 2019 01:56:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD94B8E000D; Tue, 12 Feb 2019 01:56:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2C2C8E0013; Tue, 12 Feb 2019 01:56:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4FA838E000D
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 01:56:29 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id y1so1408055pgo.0
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:56:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :openpgp:autocrypt:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=L+O+yqOCjIT/hJaSbV8WHN2FaIdXJgWYLrDX2DsdHBs=;
        b=P/8WdT/9HUBYHulxMQ4K97Tur4EXC5p8/HG0xwImuYfXwMpAgdwA0ViLTqsl6pLRJ0
         4XHPEAIEDz3Qqe7UqeB8i0d0YARzQa+YakBQZn4Kmxii0zbsrOaw+xJcc48eMiFPnVmQ
         XgKMeY+b9j/68VsBNxcvekpH4Whoq4Xkvas6PV52MfHUJC6qdPFlAjcAaZk2cFPiNkkd
         kiJuI4yqiM84JbTOw0nsrE2SN/aJ3N9RwlCxwBc0Kdrbx04xdZ6RQCaC95ht5Ga9Kc7g
         JDxLW5I4i9RfKEycwClIWRlluUkYeNAD3UIzeBj162+tMpA1KIS1E/9Huo7IMsO5VSrw
         8e5Q==
X-Gm-Message-State: AHQUAubtUZclFILCzRWud4XLJZyCIBgYYxGcFTIfO2tsdOc3YFKL0g1Q
	ejcuShTjchK9xORWLyb6y2SrlOoDLSK/TiGCTSRLEnnqk0oI8r3SPaQ3rvo8GUPQd4KfwdIH97u
	Pif+226GJiPlD+a/OzzSsArQdwGh9bQuocRylY0Q8F2hC5ktkFRdD2ubvvfHrpedb4MVN1ZrCEZ
	pAy2nEb3KhTvG3nyDhwCZurklH1fjsT507fTTJ+MFNe6bVUUBAe3ZGqxPnFvgGyNZVTxM24C2DC
	J/s+m1gGVMTGtn4ngLKzIUvC/8aVk9y1fhmuQSFE9URS1BiKLpCvfo2ZmgMSbWmlIoiTFIsBJuO
	cX7Kr1oMXGLY6YQKA/e92hryltp7qgccxdEHgBAuwv70pZ9usPF2uP7kA9WITdFewLO5f5mX8Qq
	L
X-Received: by 2002:a17:902:4225:: with SMTP id g34mr2575568pld.152.1549954588850;
        Mon, 11 Feb 2019 22:56:28 -0800 (PST)
X-Received: by 2002:a17:902:4225:: with SMTP id g34mr2575522pld.152.1549954587984;
        Mon, 11 Feb 2019 22:56:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549954587; cv=none;
        d=google.com; s=arc-20160816;
        b=nSwIG7uobc/OgDL0P8vg/6b9v2CEW8zdNlhLozJdo+xAGoxPKq2np2S7nlOv5EGUUJ
         ABLg8jJG03GcwFjXcXg0WS9l+DQMYHQMpSCCDoEQHqpGrST0u/qibwznEDUQ/1yqfuhu
         eTyCfCw8YPmsBmxLi6tmdE5jWviLPDqeZ1xIaXGi5bL+V/YqXNlS67hME9Kr/0PGTsmp
         y8sUWEfG8C6et4N4W+ogRSn6z5OU4yoakDNEZ6JLaGyjJ+ymsznrAllRDeWd95M738sF
         kYwZWsIM3WMXDub76UmzdiIGgqjbQfjHr3rx1OigByQHgyKF8KQ/ec6QNe16eyQjwnFT
         cY1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject:dkim-signature;
        bh=L+O+yqOCjIT/hJaSbV8WHN2FaIdXJgWYLrDX2DsdHBs=;
        b=SsJwkB4v3WdxcQPZl1Rpu8TeCCAPDNAkzgjQg+eZ+1/2C/SzhQPWbGzIiH7TCNiivg
         4Yaa86+PJr8+tlAaaMCFvr6kAMkTJe6KuaBlkmHAHQpRSq9PFMGoQUGh1GI7a9JAtFYi
         a5ZYotSLbdyuLFzmkoDIQJz2SasX1DdIe8P4ar5RWI6ge8njf4+8Zo0J/W2WEEL22klI
         G89fZXJkg4RpPUwNbx6OS5khOIebr5FyVWs6n4oTX8jME7zTzdy+TPf5LLfQdxKQG2SA
         VUaFfckclSQJiOUllcT39lVPnigdyf7ODGVMr4CYlsudxw58zLPzEjIb8gOSXRt2Y3q8
         XpKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ozlabs-ru.20150623.gappssmtp.com header.s=20150623 header.b=ExhGQar3;
       spf=pass (google.com: domain of aik@ozlabs.ru designates 209.85.220.65 as permitted sender) smtp.mailfrom=aik@ozlabs.ru
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n6sor17489964pgv.69.2019.02.11.22.56.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 22:56:27 -0800 (PST)
Received-SPF: pass (google.com: domain of aik@ozlabs.ru designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ozlabs-ru.20150623.gappssmtp.com header.s=20150623 header.b=ExhGQar3;
       spf=pass (google.com: domain of aik@ozlabs.ru designates 209.85.220.65 as permitted sender) smtp.mailfrom=aik@ozlabs.ru
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ozlabs-ru.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:openpgp:autocrypt:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=L+O+yqOCjIT/hJaSbV8WHN2FaIdXJgWYLrDX2DsdHBs=;
        b=ExhGQar3V1J1/1cElO5Or4jcXjfkLSg/kqCN02ugKxfFCH6mKAGckuF7yFrq/XasK5
         ShW65FZIVC1MGBQKBQFdb5Je2l0smgYk+IcCyQOKnaSY5f+H+p/w0B9Cq+85wHMbO8kj
         pSlpfRVfTTbVfCI9aOhSvzozt0WfXMZQQ1MJUw/IaEiJNhDB94h5SYWJCG0aUXYqoasY
         rrPx2ytvqgG499nyz1en3ZQU5YDLC6cGNjUYGrvHcVc7w8Z/cGUGDoau1UE6auaQmBg0
         t6ofY0rVX2Sgb2M6Fdpzo6L/8mCtVWgzugmQnMdyrg6Kg2xHtbmr7xgRe0aIFDyisU33
         /7Nw==
X-Google-Smtp-Source: AHgI3Ia1m0EgZFqfG8DlV0MDmpm97/3HSXC1m1Q6apmq+zhrcO+dI3+WxEs4lGlUv7ytHet9qHjInA==
X-Received: by 2002:a65:64d6:: with SMTP id t22mr2333374pgv.52.1549954586737;
        Mon, 11 Feb 2019 22:56:26 -0800 (PST)
Received: from [10.61.2.175] ([122.99.82.10])
        by smtp.gmail.com with ESMTPSA id c7sm22661296pfa.24.2019.02.11.22.56.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 22:56:25 -0800 (PST)
Subject: Re: [PATCH 2/5] vfio/spapr_tce: use pinned_vm instead of locked_vm to
 account pinned pages
To: Daniel Jordan <daniel.m.jordan@oracle.com>, jgg@ziepe.ca
Cc: akpm@linux-foundation.org, dave@stgolabs.net, jack@suse.cz, cl@linux.com,
 linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
 linux-kernel@vger.kernel.org, alex.williamson@redhat.com, paulus@ozlabs.org,
 benh@kernel.crashing.org, mpe@ellerman.id.au, hao.wu@intel.com,
 atull@kernel.org, mdf@kernel.org
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
 <20190211224437.25267-3-daniel.m.jordan@oracle.com>
From: Alexey Kardashevskiy <aik@ozlabs.ru>
Openpgp: preference=signencrypt
Autocrypt: addr=aik@ozlabs.ru; keydata=
 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
Message-ID: <ee4d14db-05c3-6208-503c-16e287fa78eb@ozlabs.ru>
Date: Tue, 12 Feb 2019 17:56:18 +1100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190211224437.25267-3-daniel.m.jordan@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 12/02/2019 09:44, Daniel Jordan wrote:
> Beginning with bc3e53f682d9 ("mm: distinguish between mlocked and pinned
> pages"), locked and pinned pages are accounted separately.  The SPAPR
> TCE VFIO IOMMU driver accounts pinned pages to locked_vm; use pinned_vm
> instead.
> 
> pinned_vm recently became atomic and so no longer relies on mmap_sem
> held as writer: delete.
> 
> Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> ---
>  Documentation/vfio.txt              |  6 +--
>  drivers/vfio/vfio_iommu_spapr_tce.c | 64 ++++++++++++++---------------
>  2 files changed, 33 insertions(+), 37 deletions(-)
> 
> diff --git a/Documentation/vfio.txt b/Documentation/vfio.txt
> index f1a4d3c3ba0b..fa37d65363f9 100644
> --- a/Documentation/vfio.txt
> +++ b/Documentation/vfio.txt
> @@ -308,7 +308,7 @@ This implementation has some specifics:
>     currently there is no way to reduce the number of calls. In order to make
>     things faster, the map/unmap handling has been implemented in real mode
>     which provides an excellent performance which has limitations such as
> -   inability to do locked pages accounting in real time.
> +   inability to do pinned pages accounting in real time.
>  
>  4) According to sPAPR specification, A Partitionable Endpoint (PE) is an I/O
>     subtree that can be treated as a unit for the purposes of partitioning and
> @@ -324,7 +324,7 @@ This implementation has some specifics:
>  		returns the size and the start of the DMA window on the PCI bus.
>  
>  	VFIO_IOMMU_ENABLE
> -		enables the container. The locked pages accounting
> +		enables the container. The pinned pages accounting
>  		is done at this point. This lets user first to know what
>  		the DMA window is and adjust rlimit before doing any real job.
>  
> @@ -454,7 +454,7 @@ This implementation has some specifics:
>  
>     PPC64 paravirtualized guests generate a lot of map/unmap requests,
>     and the handling of those includes pinning/unpinning pages and updating
> -   mm::locked_vm counter to make sure we do not exceed the rlimit.
> +   mm::pinned_vm counter to make sure we do not exceed the rlimit.
>     The v2 IOMMU splits accounting and pinning into separate operations:
>  
>     - VFIO_IOMMU_SPAPR_REGISTER_MEMORY/VFIO_IOMMU_SPAPR_UNREGISTER_MEMORY ioctls
> diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
> index c424913324e3..f47e020dc5e4 100644
> --- a/drivers/vfio/vfio_iommu_spapr_tce.c
> +++ b/drivers/vfio/vfio_iommu_spapr_tce.c
> @@ -34,9 +34,11 @@
>  static void tce_iommu_detach_group(void *iommu_data,
>  		struct iommu_group *iommu_group);
>  
> -static long try_increment_locked_vm(struct mm_struct *mm, long npages)
> +static long try_increment_pinned_vm(struct mm_struct *mm, long npages)
>  {
> -	long ret = 0, locked, lock_limit;
> +	long ret = 0;
> +	s64 pinned;
> +	unsigned long lock_limit;
>  
>  	if (WARN_ON_ONCE(!mm))
>  		return -EPERM;
> @@ -44,39 +46,33 @@ static long try_increment_locked_vm(struct mm_struct *mm, long npages)
>  	if (!npages)
>  		return 0;
>  
> -	down_write(&mm->mmap_sem);
> -	locked = mm->locked_vm + npages;
> +	pinned = atomic64_add_return(npages, &mm->pinned_vm);
>  	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> -	if (locked > lock_limit && !capable(CAP_IPC_LOCK))
> +	if (pinned > lock_limit && !capable(CAP_IPC_LOCK)) {
>  		ret = -ENOMEM;
> -	else
> -		mm->locked_vm += npages;
> +		atomic64_sub(npages, &mm->pinned_vm);
> +	}
>  
> -	pr_debug("[%d] RLIMIT_MEMLOCK +%ld %ld/%ld%s\n", current->pid,
> +	pr_debug("[%d] RLIMIT_MEMLOCK +%ld %ld/%lu%s\n", current->pid,
>  			npages << PAGE_SHIFT,
> -			mm->locked_vm << PAGE_SHIFT,
> -			rlimit(RLIMIT_MEMLOCK),
> -			ret ? " - exceeded" : "");
> -
> -	up_write(&mm->mmap_sem);
> +			atomic64_read(&mm->pinned_vm) << PAGE_SHIFT,
> +			rlimit(RLIMIT_MEMLOCK), ret ? " - exceeded" : "");
>  
>  	return ret;
>  }
>  
> -static void decrement_locked_vm(struct mm_struct *mm, long npages)
> +static void decrement_pinned_vm(struct mm_struct *mm, long npages)
>  {
>  	if (!mm || !npages)
>  		return;
>  
> -	down_write(&mm->mmap_sem);
> -	if (WARN_ON_ONCE(npages > mm->locked_vm))
> -		npages = mm->locked_vm;
> -	mm->locked_vm -= npages;
> -	pr_debug("[%d] RLIMIT_MEMLOCK -%ld %ld/%ld\n", current->pid,
> +	if (WARN_ON_ONCE(npages > atomic64_read(&mm->pinned_vm)))
> +		npages = atomic64_read(&mm->pinned_vm);
> +	atomic64_sub(npages, &mm->pinned_vm);
> +	pr_debug("[%d] RLIMIT_MEMLOCK -%ld %ld/%lu\n", current->pid,
>  			npages << PAGE_SHIFT,
> -			mm->locked_vm << PAGE_SHIFT,
> +			atomic64_read(&mm->pinned_vm) << PAGE_SHIFT,
>  			rlimit(RLIMIT_MEMLOCK));
> -	up_write(&mm->mmap_sem);


So it used to be down_write+up_write and stuff in between.

Now it is 3 independent accesses (actually 4 but the last one is
diagnostic) with no locking around them. Why do not we need a lock
anymore precisely? Thanks,




>  }
>  
>  /*
> @@ -110,7 +106,7 @@ struct tce_container {
>  	bool enabled;
>  	bool v2;
>  	bool def_window_pending;
> -	unsigned long locked_pages;
> +	unsigned long pinned_pages;
>  	struct mm_struct *mm;
>  	struct iommu_table *tables[IOMMU_TABLE_GROUP_MAX_TABLES];
>  	struct list_head group_list;
> @@ -283,7 +279,7 @@ static int tce_iommu_find_free_table(struct tce_container *container)
>  static int tce_iommu_enable(struct tce_container *container)
>  {
>  	int ret = 0;
> -	unsigned long locked;
> +	unsigned long pinned;
>  	struct iommu_table_group *table_group;
>  	struct tce_iommu_group *tcegrp;
>  
> @@ -292,15 +288,15 @@ static int tce_iommu_enable(struct tce_container *container)
>  
>  	/*
>  	 * When userspace pages are mapped into the IOMMU, they are effectively
> -	 * locked memory, so, theoretically, we need to update the accounting
> -	 * of locked pages on each map and unmap.  For powerpc, the map unmap
> +	 * pinned memory, so, theoretically, we need to update the accounting
> +	 * of pinned pages on each map and unmap.  For powerpc, the map unmap
>  	 * paths can be very hot, though, and the accounting would kill
>  	 * performance, especially since it would be difficult to impossible
>  	 * to handle the accounting in real mode only.
>  	 *
>  	 * To address that, rather than precisely accounting every page, we
> -	 * instead account for a worst case on locked memory when the iommu is
> -	 * enabled and disabled.  The worst case upper bound on locked memory
> +	 * instead account for a worst case on pinned memory when the iommu is
> +	 * enabled and disabled.  The worst case upper bound on pinned memory
>  	 * is the size of the whole iommu window, which is usually relatively
>  	 * small (compared to total memory sizes) on POWER hardware.
>  	 *
> @@ -317,7 +313,7 @@ static int tce_iommu_enable(struct tce_container *container)
>  	 *
>  	 * So we do not allow enabling a container without a group attached
>  	 * as there is no way to know how much we should increment
> -	 * the locked_vm counter.
> +	 * the pinned_vm counter.
>  	 */
>  	if (!tce_groups_attached(container))
>  		return -ENODEV;
> @@ -335,12 +331,12 @@ static int tce_iommu_enable(struct tce_container *container)
>  	if (ret)
>  		return ret;
>  
> -	locked = table_group->tce32_size >> PAGE_SHIFT;
> -	ret = try_increment_locked_vm(container->mm, locked);
> +	pinned = table_group->tce32_size >> PAGE_SHIFT;
> +	ret = try_increment_pinned_vm(container->mm, pinned);
>  	if (ret)
>  		return ret;
>  
> -	container->locked_pages = locked;
> +	container->pinned_pages = pinned;
>  
>  	container->enabled = true;
>  
> @@ -355,7 +351,7 @@ static void tce_iommu_disable(struct tce_container *container)
>  	container->enabled = false;
>  
>  	BUG_ON(!container->mm);
> -	decrement_locked_vm(container->mm, container->locked_pages);
> +	decrement_pinned_vm(container->mm, container->pinned_pages);
>  }
>  
>  static void *tce_iommu_open(unsigned long arg)
> @@ -658,7 +654,7 @@ static long tce_iommu_create_table(struct tce_container *container,
>  	if (!table_size)
>  		return -EINVAL;
>  
> -	ret = try_increment_locked_vm(container->mm, table_size >> PAGE_SHIFT);
> +	ret = try_increment_pinned_vm(container->mm, table_size >> PAGE_SHIFT);
>  	if (ret)
>  		return ret;
>  
> @@ -677,7 +673,7 @@ static void tce_iommu_free_table(struct tce_container *container,
>  	unsigned long pages = tbl->it_allocated_size >> PAGE_SHIFT;
>  
>  	iommu_tce_table_put(tbl);
> -	decrement_locked_vm(container->mm, pages);
> +	decrement_pinned_vm(container->mm, pages);
>  }
>  
>  static long tce_iommu_create_window(struct tce_container *container,
> 

-- 
Alexey

