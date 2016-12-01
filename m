Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7DEC26B025E
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 12:32:03 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id g186so109015860pgc.2
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 09:32:03 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t76si943577pgc.18.2016.12.01.09.32.00
        for <linux-mm@kvack.org>;
        Thu, 01 Dec 2016 09:32:02 -0800 (PST)
Subject: Re: Kernel Panics on Xen ARM64 for Domain0 and Guest
References: <AM5PR0802MB2452C895A95FA378D6F3783D9E8A0@AM5PR0802MB2452.eurprd08.prod.outlook.com>
 <420a44c0-f86f-e6ab-44af-93ada7e01b58@arm.com>
 <20161128152915.GA7806@htj.duckdns.org>
From: Julien Grall <julien.grall@arm.com>
Message-ID: <a8f86294-acbb-4e20-efa3-311304030754@arm.com>
Date: Thu, 1 Dec 2016 17:31:57 +0000
MIME-Version: 1.0
In-Reply-To: <20161128152915.GA7806@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tj@kernel.org" <tj@kernel.org>
Cc: Wei Chen <Wei.Chen@arm.com>, "zijun_hu@htc.com" <zijun_hu@htc.com>, "cl@linux.com" <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, Kaly Xin <Kaly.Xin@arm.com>, Steve Capper <Steve.Capper@arm.com>, Stefano Stabellini <sstabellini@kernel.org>



On 28/11/16 15:29, tj@kernel.org wrote:
> Hello,

Hello,

> On Mon, Nov 28, 2016 at 11:59:15AM +0000, Julien Grall wrote:
>>> commit 3ca45a46f8af8c4a92dd8a08eac57787242d5021
>>> percpu: ensure the requested alignment is power of two
>>
>> It would have been useful to specify the tree used. In this case,
>> this commit comes from linux-next.
>
> I'm surprised this actually triggered.
>
>> diff --git a/arch/arm/xen/enlighten.c b/arch/arm/xen/enlighten.c
>> index f193414..4986dc0 100644
>> --- a/arch/arm/xen/enlighten.c
>> +++ b/arch/arm/xen/enlighten.c
>> @@ -372,8 +372,7 @@ static int __init xen_guest_init(void)
>>          * for secondary CPUs as they are brought up.
>>          * For uniformity we use VCPUOP_register_vcpu_info even on cpu0.
>>          */
>> -       xen_vcpu_info = __alloc_percpu(sizeof(struct vcpu_info),
>> -                                              sizeof(struct vcpu_info));
>> +       xen_vcpu_info = alloc_percpu(struct vcpu_info);
>>         if (xen_vcpu_info == NULL)
>>                 return -ENOMEM;
>
> Yes, this looks correct.  Can you please cc stable too?  percpu
> allocator never supported alignments which aren't power of two and has
> always behaved incorrectly with alignments which aren't power of two.

I will send the patch soon with stable CCed.

Regards,

-- 
Julien Grall

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
