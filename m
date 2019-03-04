Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E284C10F03
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 08:11:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DAF02082F
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 08:10:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uDFuyLc/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DAF02082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05E2C8E0003; Mon,  4 Mar 2019 03:10:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F27298E0001; Mon,  4 Mar 2019 03:10:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC97A8E0003; Mon,  4 Mar 2019 03:10:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9BAAA8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 03:10:58 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id z24so4512455pfn.7
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 00:10:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=KfOFdOucD1U97CCxvS8TuzZdQ4PD/e84qcQFlpBStSQ=;
        b=GiCbECif9McnHn+AABOVpHayUnentzNqvtahZIHngB69SjNLxAmpebPw4Ta0jBmvI+
         iqEPVOuqR44e/Z6gif8ZiWOu6Lz4Eu0AYiFGEjqLf22Qb++8Z0m48NRHtN0+HtDHiACl
         KA9afE/6g7TEhUwmjDrNXejY7YXjgX5mk/H/0k5usbQJxCrDYKtb7aqrmEkwX0eS70zA
         UGx8yXrFTfQ2Q2CY91v9k9W7kbTEGRtI4a8ZQyMvdbzGTbowvkrWXzROpVr5H0aqygGW
         u+QInUWXSAUhYh9//kFInzC3KvDlRyGEvctJtt1/6sbIpIGavn12eletlfkTFJpS+UNZ
         GKGw==
X-Gm-Message-State: APjAAAW0mRjhp3+0iF8QX8gLTxxLmrdRrAXvrnHkdv+kma1jBtJS1/wm
	k8ZtGPE2WIRh9Jv67VNvb01ixCO/UQyodmi26eX+gYWkMprHXC+l2JIl+KnJ4OBQ1LObQFppnNr
	+3AiFY23DoBvtLcPBiKKRb//0LEYYhWQKTGCsn5jswMn+Klp5i4gqg3P9Kl6Qg8A02iOU4GvfBf
	XYA7BAnM4m+OULggCR0igPdAOU7+8uKTWGw9nFTd01FsGXG8gsTDb75o8K87tFWT/05H290OWEr
	mfdOuaTVoJSPQxvjMXZHoSoxfJAybT1Kcv5atPJOVN0ZpFsuXjoppgSXFKXx6+lx/fI5K0x/d5p
	LMnmRs5hMH7PLckBotRgzxVNBz4DwAZC9YJdC5NLtKrCgs2PYmC06UWmeYupF2mVl34czjWrFw=
	=
X-Received: by 2002:a65:5844:: with SMTP id s4mr17249653pgr.77.1551687058235;
        Mon, 04 Mar 2019 00:10:58 -0800 (PST)
X-Received: by 2002:a65:5844:: with SMTP id s4mr17249587pgr.77.1551687056949;
        Mon, 04 Mar 2019 00:10:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551687056; cv=none;
        d=google.com; s=arc-20160816;
        b=LCVO2Pur+pP3IHP/K7pb44lZa7iIj64L70MRc5wfS57R4rzCuv7dvjH5oxyIvcJBRn
         NNc8azoOmCXebvPVq8aBoc6P6Q6fHjQbp+XZ/jIkrim8KJaEIAb0p7fe50Pama3Pz8tS
         K4AeZw4P7KpX6OHE6YUYXWugJYiBc2Uf+sIZF8RYfNR+boKqXxaE7nfVgNb8PDkkXkc1
         grFDdCwTB4MZY59JYgfWtWM5W4tkbqzWRc2uO0GZcNaERZRsgsCslsuHEXGdkz3XNH+A
         RS7rAI9SfIFUe8WdsQ6H9AShTqEYSX43Kl3EX/acX4OBY+9+MoFmIGT7WyTguAtYwfl7
         Mazw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=KfOFdOucD1U97CCxvS8TuzZdQ4PD/e84qcQFlpBStSQ=;
        b=z0LywfJputohHx8MAqJV4xM83H10y7sFxPqhKdPLkh3IOqi27aaWxb7Ok0/vL7bk8l
         Frte/CHq10DVZO9QTWX+MCN3peUjv/nWhY1irbCGkZiqlHVPP2DCxbVWeMN54X16gsGN
         6Zm6bhfR2NXPEvqRnsVjxCM0QX3k4Jf7lBLlYI0TYmwGGMxD2Vd1Zo6pk4j7Y+fSGZf7
         +JoAKVRiM5E3LqaORkc291yhJ2EoIxwVU//nrenIGya2Vs0Wsg4v+0hl4FywFvjIt3vA
         2/DI74RAyRu7fm97JhjeGjP9RlLZbVacVyFat6/JW5TmVtr5C/ZyvXSM89/9fmcQW/a+
         bhOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="uDFuyLc/";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y191sor7825912pgd.38.2019.03.04.00.10.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Mar 2019 00:10:56 -0800 (PST)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="uDFuyLc/";
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=KfOFdOucD1U97CCxvS8TuzZdQ4PD/e84qcQFlpBStSQ=;
        b=uDFuyLc/jJuEQsJtJDTI7zemEl9I/eG6UYZalJfhLuSQ5DshGdoeq466b6LWoJMECx
         BYqdpzIYsFfwOfrRH8eH+y+124e30VvYzxDQojReh73i6lUmzo2w8UQcQV8nWAsJ4uWL
         bHyi1BsMT/ifzLDiQLNRDGzhW6L6kdSuibU0nf7nseiccjUgouqmLvMnFFp9p5+5EKlG
         fp/p9MP5o7xr2VSGqOOb/7kM3sUTcMpm3nYXMNaEzA8OIaizqefA6jPR2XKz74pm1Xk0
         GLiPR9wj9HHWzOdQa6cNOcMJeRS8xU+3uzr49h8OHLw9TXkfxmctm25HPeKNbMyBNbsC
         FhFA==
X-Google-Smtp-Source: APXvYqwDFsAjTcs9vGSPjkraJqsPLoeJOoYCdCY4mIoCIxcD8rMUhxhyncf+EZhVgw8gmijRKTGsLw==
X-Received: by 2002:a65:624a:: with SMTP id q10mr17706122pgv.377.1551687056257;
        Mon, 04 Mar 2019 00:10:56 -0800 (PST)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id d86sm12105717pfm.18.2019.03.04.00.10.51
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Mar 2019 00:10:55 -0800 (PST)
Date: Mon, 4 Mar 2019 17:10:48 +0900
From: Minchan Kim <minchan@kernel.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org,
	peterz@infradead.org, riel@surriel.com, mhocko@suse.com,
	ying.huang@intel.com, jrdr.linux@gmail.com, jglisse@redhat.com,
	aneesh.kumar@linux.ibm.com, david@redhat.com, aarcange@redhat.com,
	raquini@redhat.com, rientjes@google.com, kirill@shutemov.name,
	mgorman@techsingularity.net, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3] mm/memory.c: do_fault: avoid usage of stale
 vm_area_struct
Message-ID: <20190304081048.GA98096@google.com>
References: <20190302185144.GD31083@redhat.com>
 <5b3fdf19e2a5be460a384b936f5b56e13733f1b8.1551595137.git.jstancek@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5b3fdf19e2a5be460a384b936f5b56e13733f1b8.1551595137.git.jstancek@redhat.com>
User-Agent: Mutt/1.10.1+60 (6df12dc1) (2018-08-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 03, 2019 at 08:28:04AM +0100, Jan Stancek wrote:
> LTP testcase mtest06 [1] can trigger a crash on s390x running 5.0.0-rc8.
> This is a stress test, where one thread mmaps/writes/munmaps memory area
> and other thread is trying to read from it:
> 
>   CPU: 0 PID: 2611 Comm: mmap1 Not tainted 5.0.0-rc8+ #51
>   Hardware name: IBM 2964 N63 400 (z/VM 6.4.0)
>   Krnl PSW : 0404e00180000000 00000000001ac8d8 (__lock_acquire+0x7/0x7a8)
>   Call Trace:
>   ([<0000000000000000>]           (null))
>    [<00000000001adae4>] lock_acquire+0xec/0x258
>    [<000000000080d1ac>] _raw_spin_lock_bh+0x5c/0x98
>    [<000000000012a780>] page_table_free+0x48/0x1a8
>    [<00000000002f6e54>] do_fault+0xdc/0x670
>    [<00000000002fadae>] __handle_mm_fault+0x416/0x5f0
>    [<00000000002fb138>] handle_mm_fault+0x1b0/0x320
>    [<00000000001248cc>] do_dat_exception+0x19c/0x2c8
>    [<000000000080e5ee>] pgm_check_handler+0x19e/0x200
> 
> page_table_free() is called with NULL mm parameter, but because
> "0" is a valid address on s390 (see S390_lowcore), it keeps
> going until it eventually crashes in lockdep's lock_acquire.
> This crash is reproducible at least since 4.14.
> 
> Problem is that "vmf->vma" used in do_fault() can become stale.
> Because mmap_sem may be released, other threads can come in,
> call munmap() and cause "vma" be returned to kmem cache, and
> get zeroed/re-initialized and re-used:
> 
> handle_mm_fault                           |
>   __handle_mm_fault                       |
>     do_fault                              |
>       vma = vmf->vma                      |
>       do_read_fault                       |
>         __do_fault                        |
>           vma->vm_ops->fault(vmf);        |
>             mmap_sem is released          |
>                                           |
>                                           | do_munmap()
>                                           |   remove_vma_list()
>                                           |     remove_vma()
>                                           |       vm_area_free()
>                                           |         # vma is released
>                                           | ...
>                                           | # same vma is allocated
>                                           | # from kmem cache
>                                           | do_mmap()
>                                           |   vm_area_alloc()
>                                           |     memset(vma, 0, ...)
>                                           |
>       pte_free(vma->vm_mm, ...);          |
>         page_table_free                   |
>           spin_lock_bh(&mm->context.lock);|
>             <crash>                       |
> 
> Cache mm_struct to avoid using potentially stale "vma".
> 
> [1] https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/mem/mtest06/mmap1.c
> 
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>

Isn't it -stable material?

