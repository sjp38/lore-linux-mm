Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id A2E4E6B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 21:17:34 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id wp18so1379979obc.14
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 18:17:33 -0700 (PDT)
Message-ID: <515CD4A7.6070903@gmail.com>
Date: Thu, 04 Apr 2013 09:17:27 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: add phys addr validity check for /dev/mem mmap
References: <1364905733-23937-1-git-send-email-fhrbata@redhat.com> <515B2802.1050405@zytor.com> <515CD359.40004@gmail.com> <515CD3BF.5010104@zytor.com>
In-Reply-To: <515CD3BF.5010104@zytor.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Frantisek Hrbata <fhrbata@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com

Hi H.Peter,
On 04/04/2013 09:13 AM, H. Peter Anvin wrote:
> On 04/03/2013 06:11 PM, Simon Jeons wrote:
>> Why we consider boot_cpu_data.x86_phys_bits instead of e820 map here?
>>
> Because x86_phys_bits is what controls how much address space the
> processor has.  e820 tells us how much *RAM* the machine has, or
> specifically, how much RAM the machine had on boot.

e820 also contain mmio, correct? So cpu should not access address beyond 
e820 map(RAM+MMIO).

>
> 	-hpa
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
