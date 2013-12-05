Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id 11F7D6B0031
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 19:00:24 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id z20so11819980yhz.22
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 16:00:23 -0800 (PST)
Received: from mail-yh0-x22f.google.com (mail-yh0-x22f.google.com [2607:f8b0:4002:c01::22f])
        by mx.google.com with ESMTPS id i10si27904125yhg.25.2013.12.04.16.00.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 16:00:23 -0800 (PST)
Received: by mail-yh0-f47.google.com with SMTP id 29so11883787yhl.20
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 16:00:22 -0800 (PST)
Date: Wed, 4 Dec 2013 16:00:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: linux-next: Tree for Dec 3 (mm/Kconfig)
In-Reply-To: <CAL8k4FwmVmCq8jPWNoRXKPtnSdRc3pwaMCE+AZoq_VoZphpR_A@mail.gmail.com>
Message-ID: <alpine.DEB.2.02.1312041558280.6329@chino.kir.corp.google.com>
References: <CAL8k4FwmVmCq8jPWNoRXKPtnSdRc3pwaMCE+AZoq_VoZphpR_A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sima Baymani <sima.baymani@gmail.com>
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org, tangchen@cn.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org, aquini@redhat.com, linux-kernel@vger.kernel.org, gang.chen@asianux.com, aneesh.kumar@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, kirill.shutemov@linux.intel.com, sjenning@linux.vnet.ibm.com, darrick.wong@oracle.com

On Wed, 4 Dec 2013, Sima Baymani wrote:

> When generating randconfig, got following warning:
> 
> warning: (HWPOISON_INJECT && MEM_SOFT_DIRTY) selects PROC_PAGE_MONITOR
> which has unmet direct dependencies (PROC_FS && MMU)
> 
> I would have liked to form a patch for it, but not sure whether to
> simply add PROC_FS && MMU as dependencies for HWPOISON_INJECT and
> MEM_SOFT_DIRTY, or if some other fix would be more suitable?
> 

CONFIG_HWPOISON_INJECT is unrelated, it already depends on CONFIG_PROC_FS.

CONFIG_PROC_PAGE_MONITOR is obviously only useful for CONFIG_PROC_FS, so 
the correct fix would be to make CONFIG_MEM_SOFT_DIRTY depend on 
CONFIG_PROC_FS.

Want to try sending a patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
