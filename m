Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5B414280267
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 01:35:09 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so19091055pdb.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 22:35:09 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id tl1si5600308pac.65.2015.07.14.22.35.08
        for <linux-mm@kvack.org>;
        Tue, 14 Jul 2015 22:35:08 -0700 (PDT)
Message-ID: <55A5F109.3020705@linux.intel.com>
Date: Wed, 15 Jul 2015 13:35:05 +0800
From: Jiang Liu <jiang.liu@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] x86, acpi, cpu-hotplug: Introduce apicid_to_cpuid[]
 array to store persistent cpuid <-> apicid mapping.
References: <1436261425-29881-1-git-send-email-tangchen@cn.fujitsu.com>	<1436261425-29881-4-git-send-email-tangchen@cn.fujitsu.com> <CAChTCPw6ZLs7XgApfN1exeB6TVcQji6ryq+HrK-admp=FGfiTA@mail.gmail.com> <55A5D4A5.8040806@cn.fujitsu.com>
In-Reply-To: <55A5D4A5.8040806@cn.fujitsu.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>, =?UTF-8?B?TWlrYSBQZW50dGlsw6Q=?= <mika.j.penttila@gmail.com>
Cc: rjw@rjwysocki.net, gongzhaogang@inspur.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2015/7/15 11:33, Tang Chen wrote:
> Hi Mika,
> 
> On 07/07/2015 07:14 PM, Mika PenttilA? wrote:
>> I think you forgot to reserve CPU 0 for BSP in cpuid mask.
> 
> Sorry for the late reply.
> 
> I'm not familiar with BSP.  Do you mean in get_cpuid(),
> I should reserve 0 for physical cpu0 in BSP ?
> 
> Would you please share more detail ?

BSP stands for "Bootstrapping Processor". In other word,
BSP is CPU0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
