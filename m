Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id E365728027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 02:25:31 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so19877255pdb.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 23:25:31 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id go6si5717911pbc.237.2015.07.14.23.25.29
        for <linux-mm@kvack.org>;
        Tue, 14 Jul 2015 23:25:30 -0700 (PDT)
Message-ID: <55A5FD04.1090003@cn.fujitsu.com>
Date: Wed, 15 Jul 2015 14:26:12 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/5] x86, acpi, cpu-hotplug: Introduce apicid_to_cpuid[]
 array to store persistent cpuid <-> apicid mapping.
References: <1436261425-29881-1-git-send-email-tangchen@cn.fujitsu.com>	<1436261425-29881-4-git-send-email-tangchen@cn.fujitsu.com> <CAChTCPw6ZLs7XgApfN1exeB6TVcQji6ryq+HrK-admp=FGfiTA@mail.gmail.com> <55A5D4A5.8040806@cn.fujitsu.com> <55A5F109.3020705@linux.intel.com>
In-Reply-To: <55A5F109.3020705@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>, =?UTF-8?B?TWlrYSBQZW50dGlsw6Q=?= <mika.j.penttila@gmail.com>
Cc: rjw@rjwysocki.net, gongzhaogang@inspur.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org


On 07/15/2015 01:35 PM, Jiang Liu wrote:
> On 2015/7/15 11:33, Tang Chen wrote:
>> Hi Mika,
>>
>> On 07/07/2015 07:14 PM, Mika Penttil=C3=A4 wrote:
>>> I think you forgot to reserve CPU 0 for BSP in cpuid mask.
>> Sorry for the late reply.
>>
>> I'm not familiar with BSP.  Do you mean in get_cpuid(),
>> I should reserve 0 for physical cpu0 in BSP ?
>>
>> Would you please share more detail ?
> BSP stands for "Bootstrapping Processor". In other word,
> BSP is CPU0.
> .
>

Ha, how foolish I am.

And yes, cpu0 is not reserved when apicid =3D=3D boot_cpu_physical_apicid
comes true.

Will update the patch.

Thanks. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
