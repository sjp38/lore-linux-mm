Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id E7CFC6B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 18:32:44 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id kx10so10873872pab.3
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 15:32:44 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id of4si4287474pbc.79.2014.09.11.15.32.43
        for <linux-mm@kvack.org>;
        Thu, 11 Sep 2014 15:32:43 -0700 (PDT)
Message-ID: <5412230A.6090805@intel.com>
Date: Thu, 11 Sep 2014 15:32:42 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 07/10] x86, mpx: decode MPX instruction to get bound
 violation information
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-8-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.10.1409120015030.4178@nanos>
In-Reply-To: <alpine.DEB.2.10.1409120015030.4178@nanos>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Qiaowei Ren <qiaowei.ren@intel.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/11/2014 03:18 PM, Thomas Gleixner wrote:
> On Thu, 11 Sep 2014, Qiaowei Ren wrote:
>> This patch sets bound violation fields of siginfo struct in #BR
>> exception handler by decoding the user instruction and constructing
>> the faulting pointer.
>>
>> This patch does't use the generic decoder, and implements a limited
>> special-purpose decoder to decode MPX instructions, simply because the
>> generic decoder is very heavyweight not just in terms of performance
>> but in terms of interface -- because it has to.
> 
> And why is that an argument to add another special purpose decoder?

Peter asked for it to be done this way specifically:

	https://lkml.org/lkml/2014/6/19/411

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
