Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 52AA76B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 22:58:53 -0400 (EDT)
Received: by mail-da0-f53.google.com with SMTP id n34so482144dal.12
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 19:58:52 -0700 (PDT)
Message-ID: <516626E4.4000507@gmail.com>
Date: Thu, 11 Apr 2013 10:58:44 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: add phys addr validity check for /dev/mem mmap
References: <1364905733-23937-1-git-send-email-fhrbata@redhat.com> <515B2802.1050405@zytor.com> <515CD359.40004@gmail.com> <515CD3BF.5010104@zytor.com> <5166229D.2090904@gmail.com> <51662492.1030100@zytor.com>
In-Reply-To: <51662492.1030100@zytor.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Frantisek Hrbata <fhrbata@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com

Hi H.Peter,
On 04/11/2013 10:48 AM, H. Peter Anvin wrote:
> On 04/10/2013 07:40 PM, Simon Jeons wrote:
>> Hi H.Peter,
>> On 04/04/2013 09:13 AM, H. Peter Anvin wrote:
>>> On 04/03/2013 06:11 PM, Simon Jeons wrote:
>>>> Why we consider boot_cpu_data.x86_phys_bits instead of e820 map here?
>>>>
>>> Because x86_phys_bits is what controls how much address space the
>>> processor has.  e820 tells us how much *RAM* the machine has, or
>>> specifically, how much RAM the machine had on boot.
>> I have 8GB memory in my machine, but when I accumulated every e820
>> ranges which dump in dmesg, there are 25MB memory less then 8GB(1024*8)
>> memory, why 25MB miss?
>>
> For whatever reason your BIOS is stealing some memory, possibly for video.

Thanks for your quick response. ;-)
My machine is new which have i7 cpu. How much memory video need? 8MB? 
Why I miss 25MB?

>
> 	-hpa
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
