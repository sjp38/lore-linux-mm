Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93CE2C10F0B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 22:04:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1986020856
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 22:04:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1986020856
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 826206B0269; Tue,  2 Apr 2019 18:04:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D4D06B026D; Tue,  2 Apr 2019 18:04:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C3F36B026F; Tue,  2 Apr 2019 18:04:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 289B16B0269
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 18:04:28 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 1so10834804ply.14
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 15:04:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1I2QFMTY/NFOM9BA9zBZOHywXvs9ZbEpts/LPqMqrmk=;
        b=UCAd8sVycEJErv1wOq3Dq+/hZXuw351FOicytE3ExSHnMFKkNsqeXmwIBBr62nYCUS
         q6qs2IddastGZ3xEQkSeeW/vzBYmmRvLswwxD8sBs9L9GueBVdgtfW5PaXy0z5/8wqd3
         QqEHhoqZCRhbPuEV0xXjlr+VhAZZt/D4LsKFoLnaiQdNDTbJgJAKID8m0iyWg5+vvBlk
         LV/dFfS4P4r9u3AvCeGLdfJsV9NClfAzQLvX1veNp3sEPPiMACzMosX1oC1VR/LGhsMn
         Aj1uPM0Z6vFIMwqAO+AykqYXkG9BxMn1IuRg7crNiJ79pOR/AijLmSgVMH2ecLQFBepG
         kRrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAUBCQ9HTD95d+WCWTNMMAHivdsEUQXyjVk4e9APm8yHM/37PN7C
	bJIwHS4EtMDsufPNTzEPKAYptszAXKbLOhTaO/UnLWsoYNOSi/dyevlYq5Bxh7DSr7MOMB2CvK1
	0DBBPxlQFP9kMw6hDgIDx9ZZpGKsLsm8UUbCOtR9q4sV9T74u37DpPjkTn+Un18MTEQ==
X-Received: by 2002:a17:902:e01:: with SMTP id 1mr74234819plw.128.1554242667772;
        Tue, 02 Apr 2019 15:04:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyW2xJQCCZW/UF7lEwW3Z/9UpkcAHzHoZc7Jy2f/NukmCvald2ZfaMo2GVRcO/qmFAmfxJb
X-Received: by 2002:a17:902:e01:: with SMTP id 1mr74234732plw.128.1554242666868;
        Tue, 02 Apr 2019 15:04:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554242666; cv=none;
        d=google.com; s=arc-20160816;
        b=dBw6jRckrrrUr/CRlT3cXZdYgeFaehurwDWoK2Z/nIEpP9uxabiBMjZw6C+Pgw26Ey
         CNIxglEerLIyZM3kaiAOAZnzu7XROI9u+eapAxSbg8Pw3OioLSa5kbzQSIllX6yvsGBx
         bGS5Wc7iM8QV+wVKNnyyDu/hmJr51xfgnqXQzuvfJ8CI7vSH46x7Oa8cbCX1cUj0JMVA
         c/mPC2fmKIKT8gy4pAphVwaHGUXKGpS3IkDKW+xa5ly9i+ocajFBtIfLDK91Y4ViShZ/
         Lod++h9hlCo/xVWR8jVuo0ZXt5hjCk1JTT5HrKtUtvB0R72uUeiXCem450IqnnQbaBIQ
         m/Hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=1I2QFMTY/NFOM9BA9zBZOHywXvs9ZbEpts/LPqMqrmk=;
        b=ILdyxaWMzoSGN+To23HcA9+9pg+9mzfgasYK61rw2Oucj8dyWa4xDNedW4OEZzk6Ud
         eAsQfKefctrpba5wcNtNDjvbMyuA/L2r8dThL3g0WNPEQSPbssnnJVonV3Z9tG3+iXIl
         vs3XMVEQ3ierNon+Wab2rMMo6WB9LlYfCn9STpZMklRMai1tPd6YvJxmTbJeGiijWMAp
         6B1J0xjK0oDh+xYcs11Q+JfVxpFnVH+alRW9+BmUVTlOt/L2LGpISkp8tvkC8rYgOOok
         HPdqYZTWcN+KHi4cdYGugJfq5hbojG6DMEeSu7BL4w7IsqGZv4q3582B77L3KnoK2+p1
         ARhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z13si11970034pgp.376.2019.04.02.15.04.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 15:04:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id EB8B0C84;
	Tue,  2 Apr 2019 22:04:25 +0000 (UTC)
Date: Tue, 2 Apr 2019 15:04:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Alan Tull <atull@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, Alex
 Williamson <alex.williamson@redhat.com>, Benjamin Herrenschmidt
 <benh@kernel.crashing.org>, Christoph Lameter <cl@linux.com>, Davidlohr
 Bueso <dave@stgolabs.net>, Michael Ellerman <mpe@ellerman.id.au>, Moritz
 Fischer <mdf@kernel.org>, Paul Mackerras <paulus@ozlabs.org>, Wu Hao
 <hao.wu@intel.com>, linux-mm@kvack.org, kvm@vger.kernel.org,
 kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-fpga@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/6] mm: change locked_vm's type from unsigned long to
 atomic64_t
Message-Id: <20190402150424.5cf64e19deeafa58fc6c1a9f@linux-foundation.org>
In-Reply-To: <20190402204158.27582-2-daniel.m.jordan@oracle.com>
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
	<20190402204158.27582-2-daniel.m.jordan@oracle.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue,  2 Apr 2019 16:41:53 -0400 Daniel Jordan <daniel.m.jordan@oracle.com> wrote:

> Taking and dropping mmap_sem to modify a single counter, locked_vm, is
> overkill when the counter could be synchronized separately.
> 
> Make mmap_sem a little less coarse by changing locked_vm to an atomic,
> the 64-bit variety to avoid issues with overflow on 32-bit systems.
> 
> ...
>
> --- a/arch/powerpc/kvm/book3s_64_vio.c
> +++ b/arch/powerpc/kvm/book3s_64_vio.c
> @@ -59,32 +59,34 @@ static unsigned long kvmppc_stt_pages(unsigned long tce_pages)
>  static long kvmppc_account_memlimit(unsigned long stt_pages, bool inc)
>  {
>  	long ret = 0;
> +	s64 locked_vm;
>  
>  	if (!current || !current->mm)
>  		return ret; /* process exited */
>  
>  	down_write(&current->mm->mmap_sem);
>  
> +	locked_vm = atomic64_read(&current->mm->locked_vm);
>  	if (inc) {
>  		unsigned long locked, lock_limit;
>  
> -		locked = current->mm->locked_vm + stt_pages;
> +		locked = locked_vm + stt_pages;
>  		lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
>  		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
>  			ret = -ENOMEM;
>  		else
> -			current->mm->locked_vm += stt_pages;
> +			atomic64_add(stt_pages, &current->mm->locked_vm);
>  	} else {
> -		if (WARN_ON_ONCE(stt_pages > current->mm->locked_vm))
> -			stt_pages = current->mm->locked_vm;
> +		if (WARN_ON_ONCE(stt_pages > locked_vm))
> +			stt_pages = locked_vm;
>  
> -		current->mm->locked_vm -= stt_pages;
> +		atomic64_sub(stt_pages, &current->mm->locked_vm);
>  	}

With the current code, current->mm->locked_vm cannot go negative. 
After the patch, it can go negative.  If someone else decreased
current->mm->locked_vm between this function's atomic64_read() and
atomic64_sub().

I guess this is a can't-happen in this case because the racing code
which performed the modification would have taken it negative anyway.

But this all makes me rather queazy.


Also, we didn't remove any down_write(mmap_sem)s from core code so I'm
thinking that the benefit of removing a few mmap_sem-takings from a few
obscure drivers (sorry ;)) is pretty small.


Also, the argument for switching 32-bit arches to a 64-bit counter was
suspiciously vague.  What overflow issues?  Or are we just being lazy?

