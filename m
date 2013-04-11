Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 1D4066B0006
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 22:40:37 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id u28so499017qcs.22
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 19:40:36 -0700 (PDT)
Message-ID: <5166229D.2090904@gmail.com>
Date: Thu, 11 Apr 2013 10:40:29 +0800
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
Cc: Frantisek Hrbata <fhrbata@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com

Hi H.Peter,
On 04/04/2013 09:13 AM, H. Peter Anvin wrote:
> On 04/03/2013 06:11 PM, Simon Jeons wrote:
>> Why we consider boot_cpu_data.x86_phys_bits instead of e820 map here?
>>
> Because x86_phys_bits is what controls how much address space the
> processor has.  e820 tells us how much *RAM* the machine has, or
> specifically, how much RAM the machine had on boot.

I have 8GB memory in my machine, but when I accumulated every e820 
ranges which dump in dmesg, there are 25MB memory less then 8GB(1024*8) 
memory, why 25MB miss?

>
> 	-hpa
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
