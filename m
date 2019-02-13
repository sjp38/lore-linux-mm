Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8380C282C4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 00:37:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9932F222BB
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 00:37:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ozlabs-ru.20150623.gappssmtp.com header.i=@ozlabs-ru.20150623.gappssmtp.com header.b="LcRuSAFo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9932F222BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ozlabs.ru
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BC888E0002; Tue, 12 Feb 2019 19:37:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16B5B8E0001; Tue, 12 Feb 2019 19:37:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0321B8E0002; Tue, 12 Feb 2019 19:37:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B5E528E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 19:37:11 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b8so500740pfe.10
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 16:37:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :openpgp:autocrypt:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=tAYunJKNMjE36dCMTjrw5wVhdez/nETVhfNMf2zU1SI=;
        b=YZWaIRAMZhBLmR5iws22YLJ9cAybf7yOiw9vlMcSJWVlq9qLcUhIFgdxRDbwFlh5UL
         moiaxv7EmIiRTROBuH+GYpQL93NdRLQ0eRoeDzXvRWG5upL9B56cuuHvfxFuvYS4i2N2
         AymbX4oHrRBavjWbzgyP4MwjXt1okPCONFJJyFh1agb++SRcfmiswsefPTYtA2YaoLIg
         4IR63qnprpcvoo10+KHsYSW+rOTq741+8g0eqeC+4LH8PdVx70OVRiZqxHM7VmucH3mP
         02A78ifqYD/xjLuAJLBgRTh9NBqG38Vn9B6mpDzPHWR4XtXUjvuLSS3k6qpwgCblcqVy
         GCgQ==
X-Gm-Message-State: AHQUAuY4kUlNvLjiTWOyQ1qXzZmFMosFwJs41Q4hIu+4v8jjfLCP6fd4
	Rd9EckXqRaXPU5cWxYgvb7doEVXWqxx1nqTBMEaO26fy5y0Pf/+06smz5/QyoHIDZ4oE6vtz4Dg
	3/2FHKFDDiEjWPLWPlYciVnWWWq6DvdTpNf3oq3EWsqLO/rJvUdp7xj0WlM6Pq+7MX1RvXtG8Xt
	aMIVRUFOD4XGTCZrOw/jEFu7+JqTYAUWUuknKjiwb8YaV3SPlaa9XNw0RXB7PraJwaHTVDHdiSa
	zGkPzu2Df5FXwbFRVu0IxdUPCrBN7d/0FIycT3AYgEFj9bPcwpGfcCyE0IOX8MtwS02E9Cym1Cl
	EyeNJi6Deli+ROphbnb9ck84I3ukXiEiwKczjoFbWJxv2pQSvLvyoRq76l6+loTrUCe6yajEiAX
	8
X-Received: by 2002:a63:dc53:: with SMTP id f19mr6060598pgj.406.1550018231336;
        Tue, 12 Feb 2019 16:37:11 -0800 (PST)
X-Received: by 2002:a63:dc53:: with SMTP id f19mr6060558pgj.406.1550018230543;
        Tue, 12 Feb 2019 16:37:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550018230; cv=none;
        d=google.com; s=arc-20160816;
        b=YyxbePinBGdDW1j8GhJvh95B4OxmYxnshADw1YHg3nsVvRg1Ocw/Sp4ZISu2DaDcBe
         RqUZsQ30yFA03LCPzBotsy8ou0WftLGQelP/+S4KkA9VR7hzKewtVvUIN6+20PnM5JMK
         1XApHzlh9wvB+7ZEnR6AE+ZeGr62rF0Sbw7ohriUrlJZw+fRUsgvi6HdzD7FXb8Xqbns
         dLIC039/ETF55SDMSr2vNnNdhaSK6FCnhOd0Hv1EaWq4TXJAvOyLRH9+nt+FZvHXBppU
         99hdWO+BYz8rSuGdYyOAgt/RqtAlcSt6SVGxMGKEeLnA8j+iPyYiIPTgVaZ1RucUKULz
         Flzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject:dkim-signature;
        bh=tAYunJKNMjE36dCMTjrw5wVhdez/nETVhfNMf2zU1SI=;
        b=AHJQfeoT/a+feu1dSE/XzZqb4y/prywai4r6q2C0cE/ijjWUHioDj9wBik+R7BFXKu
         Zw0mGN/VM4Axw+/zW0eO3oSFJMvZjVStEi1hqMZWuQUTlyILuCbgwqvOQnYDMx8SfbR/
         RhHw6Oa+oy/gEk4mGLpFN2iGPEhQv997N2rW2JyyPeQa8C6sjbWV7vu7udS+IpDLQVyX
         1wEEV4fDo64/7OjEgISg/MR1LYBMsL9ZdgR0WZH9sWbGNF97vm9iwwEKUudnH/hy2RIW
         OPriPnFx46SC6ZfBKLU/InGCyFCRW/xJY23uFgAzxeaQVQHMwI9R2NY1qtyN+H/xqKWX
         YOTw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ozlabs-ru.20150623.gappssmtp.com header.s=20150623 header.b=LcRuSAFo;
       spf=pass (google.com: domain of aik@ozlabs.ru designates 209.85.220.65 as permitted sender) smtp.mailfrom=aik@ozlabs.ru
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x11sor16797014plv.55.2019.02.12.16.37.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 16:37:10 -0800 (PST)
Received-SPF: pass (google.com: domain of aik@ozlabs.ru designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ozlabs-ru.20150623.gappssmtp.com header.s=20150623 header.b=LcRuSAFo;
       spf=pass (google.com: domain of aik@ozlabs.ru designates 209.85.220.65 as permitted sender) smtp.mailfrom=aik@ozlabs.ru
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ozlabs-ru.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:openpgp:autocrypt:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=tAYunJKNMjE36dCMTjrw5wVhdez/nETVhfNMf2zU1SI=;
        b=LcRuSAFoFOPW4uEDKEUHWSLZ8ZQBV2SFlFrHUjTRXybOQhqgmI1o7wngQy+4A9TdNq
         7jIkUjKppuFMqDEmEEbY5kvkV61aOTSH+JWE4hTKTNH/v2KPiDKzZfphzbNOPRJmC1aF
         QPUIeD1p/TYKie8uu3cxFgglv4JuiqB5pJGJ4kYvlQkvdXM4+NthSFgbtMH9OfqZ8C2/
         0GQba151wED51MxaHxmgI/KYuI6G84ELiSpCkb3xIhLchM0nhXYzf5f5qtDFj4cYQc+Z
         t1FiaPq/N+EBfOyiG6R9b3kQqSx/3jje+axzMdbdRTXZHt8n6z4gziiPhmwAR2XiQioD
         4WAQ==
X-Google-Smtp-Source: AHgI3IZ24zAp0RWe2KQPIb0lh3y7UCgr+5EJBmu24VsQayyEqFxw/b7hVWRQi5rTR2HH2CNE+3/UIA==
X-Received: by 2002:a17:902:27a8:: with SMTP id d37mr6925424plb.182.1550018230281;
        Tue, 12 Feb 2019 16:37:10 -0800 (PST)
Received: from [10.61.2.175] ([122.99.82.10])
        by smtp.gmail.com with ESMTPSA id n10sm23168017pfj.14.2019.02.12.16.37.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 16:37:09 -0800 (PST)
Subject: Re: [PATCH 2/5] vfio/spapr_tce: use pinned_vm instead of locked_vm to
 account pinned pages
To: Daniel Jordan <daniel.m.jordan@oracle.com>,
 Christopher Lameter <cl@linux.com>
Cc: jgg@ziepe.ca, akpm@linux-foundation.org, dave@stgolabs.net, jack@suse.cz,
 linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
 linux-kernel@vger.kernel.org, alex.williamson@redhat.com, paulus@ozlabs.org,
 benh@kernel.crashing.org, mpe@ellerman.id.au, hao.wu@intel.com,
 atull@kernel.org, mdf@kernel.org
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
 <20190211224437.25267-3-daniel.m.jordan@oracle.com>
 <ee4d14db-05c3-6208-503c-16e287fa78eb@ozlabs.ru>
 <01000168e29daf0a-cb3a9394-e3dd-4d88-ad3c-31df1f9ec052-000000@email.amazonses.com>
 <20190212171839.env4rnjwdjyips6z@ca-dmjordan1.us.oracle.com>
From: Alexey Kardashevskiy <aik@ozlabs.ru>
Openpgp: preference=signencrypt
Autocrypt: addr=aik@ozlabs.ru; keydata=
 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
Message-ID: <660515dd-eb8a-36cc-5fac-a7814bb3ef69@ozlabs.ru>
Date: Wed, 13 Feb 2019 11:37:00 +1100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190212171839.env4rnjwdjyips6z@ca-dmjordan1.us.oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 13/02/2019 04:18, Daniel Jordan wrote:
> On Tue, Feb 12, 2019 at 04:50:11PM +0000, Christopher Lameter wrote:
>> On Tue, 12 Feb 2019, Alexey Kardashevskiy wrote:
>>
>>> Now it is 3 independent accesses (actually 4 but the last one is
>>> diagnostic) with no locking around them. Why do not we need a lock
>>> anymore precisely? Thanks,
>>
>> Updating a regular counter is racy and requires a lock. It was converted
>> to be an atomic which can be incremented without a race.
> 
> Yes, though Alexey may have meant that the multiple reads of the atomic in
> decrement_pinned_vm are racy.

Yes, I meant this race, thanks for clarifying this.

>  It only matters when there's a bug that would
> make the counter go negative, but it's there.
> 
> And FWIW the debug print in try_increment_pinned_vm is also racy.
> 
> This fixes all that.  It doesn't try to correct the negative pinned_vm as the
> old code did because it's already a bug and adjusting the value by the negative
> amount seems to do nothing but make debugging harder.
> 
> If it's ok, I'll respin the whole series this way (another point for common
> helper)

This looks good, thanks for fixing this.


> 
> diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
> index f47e020dc5e4..b79257304de6 100644
> --- a/drivers/vfio/vfio_iommu_spapr_tce.c
> +++ b/drivers/vfio/vfio_iommu_spapr_tce.c
> @@ -53,25 +53,24 @@ static long try_increment_pinned_vm(struct mm_struct *mm, long npages)
>  		atomic64_sub(npages, &mm->pinned_vm);
>  	}
>  
> -	pr_debug("[%d] RLIMIT_MEMLOCK +%ld %ld/%lu%s\n", current->pid,
> -			npages << PAGE_SHIFT,
> -			atomic64_read(&mm->pinned_vm) << PAGE_SHIFT,
> -			rlimit(RLIMIT_MEMLOCK), ret ? " - exceeded" : "");
> +	pr_debug("[%d] RLIMIT_MEMLOCK +%ld %lld/%lu%s\n", current->pid,
> +			npages << PAGE_SHIFT, pinned << PAGE_SHIFT,
> +			lock_limit, ret ? " - exceeded" : "");
>  
>  	return ret;
>  }
>  
>  static void decrement_pinned_vm(struct mm_struct *mm, long npages)
>  {
> +	s64 pinned;
> +
>  	if (!mm || !npages)
>  		return;
>  
> -	if (WARN_ON_ONCE(npages > atomic64_read(&mm->pinned_vm)))
> -		npages = atomic64_read(&mm->pinned_vm);
> -	atomic64_sub(npages, &mm->pinned_vm);
> -	pr_debug("[%d] RLIMIT_MEMLOCK -%ld %ld/%lu\n", current->pid,
> -			npages << PAGE_SHIFT,
> -			atomic64_read(&mm->pinned_vm) << PAGE_SHIFT,
> +	pinned = atomic64_sub_return(npages, &mm->pinned_vm);
> +	WARN_ON_ONCE(pinned < 0);
> +	pr_debug("[%d] RLIMIT_MEMLOCK -%ld %lld/%lu\n", current->pid,
> +			npages << PAGE_SHIFT, pinned << PAGE_SHIFT,
>  			rlimit(RLIMIT_MEMLOCK));
>  }
>  
> 

-- 
Alexey

