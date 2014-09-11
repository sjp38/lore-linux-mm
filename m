Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id CED146B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 18:35:49 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y13so10514200pdi.21
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 15:35:49 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id ns9si4078000pdb.221.2014.09.11.15.35.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Sep 2014 15:35:48 -0700 (PDT)
Message-ID: <541223B1.5040705@zytor.com>
Date: Thu, 11 Sep 2014 15:35:29 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 07/10] x86, mpx: decode MPX instruction to get bound
 violation information
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-8-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.10.1409120015030.4178@nanos> <5412230A.6090805@intel.com>
In-Reply-To: <5412230A.6090805@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Qiaowei Ren <qiaowei.ren@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/11/2014 03:32 PM, Dave Hansen wrote:
> On 09/11/2014 03:18 PM, Thomas Gleixner wrote:
>> On Thu, 11 Sep 2014, Qiaowei Ren wrote:
>>> This patch sets bound violation fields of siginfo struct in #BR
>>> exception handler by decoding the user instruction and constructing
>>> the faulting pointer.
>>>
>>> This patch does't use the generic decoder, and implements a limited
>>> special-purpose decoder to decode MPX instructions, simply because the
>>> generic decoder is very heavyweight not just in terms of performance
>>> but in terms of interface -- because it has to.
>>
>> And why is that an argument to add another special purpose decoder?
> 
> Peter asked for it to be done this way specifically:
> 
> 	https://lkml.org/lkml/2014/6/19/411
> 

Specifically because marshaling the data in and out of the generic
decoder was more complex than a special-purpose decoder.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
