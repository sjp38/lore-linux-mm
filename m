Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 96A5C6B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 15:20:46 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 144so33844431pfv.5
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 12:20:46 -0800 (PST)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0096.outbound.protection.outlook.com. [104.47.0.96])
        by mx.google.com with ESMTPS id t65si32633235pfb.51.2016.11.07.10.39.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 07 Nov 2016 10:39:43 -0800 (PST)
Subject: Re: [PATCH] arm/vdso: introduce vdso_mremap hook
References: <20161101172214.2938-1-dsafonov@virtuozzo.com>
 <20161107182734.GL1041@n2100.armlinux.org.uk>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <0d3a03e0-43ad-1e6f-a065-17e5bfdd92f4@virtuozzo.com>
Date: Mon, 7 Nov 2016 21:36:48 +0300
MIME-Version: 1.0
In-Reply-To: <20161107182734.GL1041@n2100.armlinux.org.uk>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Kevin Brodsky <kevin.brodsky@arm.com>, Christopher Covington <cov@codeaurora.org>, Andy
 Lutomirski <luto@amacapital.net>, Oleg Nesterov <oleg@redhat.com>, Will
 Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@virtuozzo.com>

On 11/07/2016 09:27 PM, Russell King - ARM Linux wrote:
> On Tue, Nov 01, 2016 at 08:22:14PM +0300, Dmitry Safonov wrote:
>> diff --git a/arch/arm/kernel/vdso.c b/arch/arm/kernel/vdso.c
>> index 53cf86cf2d1a..d1001f87c2f6 100644
>> --- a/arch/arm/kernel/vdso.c
>> +++ b/arch/arm/kernel/vdso.c
>> @@ -54,8 +54,11 @@ static const struct vm_special_mapping vdso_data_mapping = {
>>  	.pages = &vdso_data_page,
>>  };
>>
>> +static int vdso_mremap(const struct vm_special_mapping *sm,
>> +		struct vm_area_struct *new_vma);
>
> I'd much rather avoid this forward declaration.  Is there any reason the
> function body can't be here?
>

Well, I didn't want it to be in the middle of static file variables -
those looks nice at this moment just on top of the file.
No other than that.

-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
