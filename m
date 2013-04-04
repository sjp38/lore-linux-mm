Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id E06D56B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 22:17:36 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bi5so1226269pad.3
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 19:17:36 -0700 (PDT)
Message-ID: <515CE2B9.3080406@gmail.com>
Date: Thu, 04 Apr 2013 10:17:29 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: add phys addr validity check for /dev/mem mmap
References: <1364905733-23937-1-git-send-email-fhrbata@redhat.com> <515B2802.1050405@zytor.com> <515CD359.40004@gmail.com> <515CD3BF.5010104@zytor.com> <515CD4A7.6070903@gmail.com> <515CD81D.6020603@zytor.com> <515CDD0A.8040100@gmail.com> <6158c206-0861-41c9-84b8-6fec82b8110d@email.android.com>
In-Reply-To: <6158c206-0861-41c9-84b8-6fec82b8110d@email.android.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Frantisek Hrbata <fhrbata@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com

On 04/04/2013 10:14 AM, H. Peter Anvin wrote:
> Because git didn't exist before then?

Oh, I see, thanks! :-)

>
> Simon Jeons <simon.jeons@gmail.com> wrote:
>
>> On 04/04/2013 09:32 AM, H. Peter Anvin wrote:
>>> On 04/03/2013 06:17 PM, Simon Jeons wrote:
>>>> e820 also contain mmio, correct?
>>> No.
>>>
>>>> So cpu should not access address beyond
>>>> e820 map(RAM+MMIO).
>>> No.
>>>
>>> 	-hpa
>>>
>>>
>> One offline question, why can't check git log before 2005?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
