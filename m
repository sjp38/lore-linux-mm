Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 8DBB36B0006
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 21:53:21 -0400 (EDT)
Received: by mail-ob0-f175.google.com with SMTP id va7so2095447obc.34
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 18:53:20 -0700 (PDT)
Message-ID: <515CDD0A.8040100@gmail.com>
Date: Thu, 04 Apr 2013 09:53:14 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] x86: add phys addr validity check for /dev/mem mmap
References: <1364905733-23937-1-git-send-email-fhrbata@redhat.com> <515B2802.1050405@zytor.com> <515CD359.40004@gmail.com> <515CD3BF.5010104@zytor.com> <515CD4A7.6070903@gmail.com> <515CD81D.6020603@zytor.com>
In-Reply-To: <515CD81D.6020603@zytor.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Frantisek Hrbata <fhrbata@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com

On 04/04/2013 09:32 AM, H. Peter Anvin wrote:
> On 04/03/2013 06:17 PM, Simon Jeons wrote:
>> e820 also contain mmio, correct?
> No.
>
>> So cpu should not access address beyond
>> e820 map(RAM+MMIO).
> No.
>
> 	-hpa
>
>

One offline question, why can't check git log before 2005?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
