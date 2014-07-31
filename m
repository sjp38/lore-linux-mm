Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 97AB56B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 01:36:35 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id eu11so2917453pac.18
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 22:36:35 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id bq15si1753444pdb.257.2014.07.30.22.36.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jul 2014 22:36:34 -0700 (PDT)
Message-ID: <53D9D5DD.6030603@codeaurora.org>
Date: Thu, 31 Jul 2014 11:06:29 +0530
From: Chintan Pandya <cpandya@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: BUG when __kmap_atomic_idx crosses boundary
References: <1406710355-4360-1-git-send-email-cpandya@codeaurora.org> <20140730020615.2f943cf7.akpm@linux-foundation.org>
In-Reply-To: <20140730020615.2f943cf7.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/30/2014 02:36 PM, Andrew Morton wrote:
> On Wed, 30 Jul 2014 14:22:35 +0530 Chintan Pandya<cpandya@codeaurora.org>  wrote:
>
>> __kmap_atomic_idx>= KM_TYPE_NR or<  ZERO is a bug.
>> Report it even if CONFIG_DEBUG_HIGHMEM is not enabled.
>> That saves much debugging efforts.
>
> Please take considerably more care when preparing patch changelogs.
Okay. I will prepare new commit message.
>
> kmap_atomic() is a very commonly called function so we'll need much
> more detail than this to justify adding overhead to it.
>
> I don't think CONFIG_DEBUG_HIGHMEM really needs to exist.  We could do
> s/CONFIG_DEBUG_HIGHMEM/CONFIG_DEBUG_VM/g and perhaps your secret bug
> whatever it was would have been found more easily.
Um, we didn't get bug directly hitting here.
>

__kmap_atomic_idx should not be equal to KM_TYPE_NR anyway. So, at least 
I will share that patch. For changing DEBUG_HIGHMEM to DEBUG_VM, I will 
work on it.

-- 
QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
