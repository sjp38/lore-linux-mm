Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id A91906B0035
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 05:25:32 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so9702897pad.11
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 02:25:32 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id dn2si8498219pdb.371.2014.08.04.02.25.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Aug 2014 02:25:31 -0700 (PDT)
Message-ID: <53DF5184.1040501@codeaurora.org>
Date: Mon, 04 Aug 2014 14:55:24 +0530
From: Chintan Pandya <cpandya@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: BUG when __kmap_atomic_idx equals KM_TYPE_NR
References: <1406787871-2951-1-git-send-email-cpandya@codeaurora.org>	<alpine.DEB.2.02.1407310001360.18238@chino.kir.corp.google.com>	<53DA0C5A.3010409@codeaurora.org> <20140731154540.441ab79ff32ae5c10f64bcbd@linux-foundation.org>
In-Reply-To: <20140731154540.441ab79ff32ae5c10f64bcbd@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/01/2014 04:15 AM, Andrew Morton wrote:
> On Thu, 31 Jul 2014 14:58:58 +0530 Chintan Pandya<cpandya@codeaurora.org>  wrote:
>
>>>
>>> I think Andrew's comment earlier was referring to the changelog only and
>>> not the patch, which looked correct.
>>
>> I think Andrew asked for a BUG case details also to justify the
>> overhead. But we have never encountered that BUG case. Present patch is
>> only logical fix to the code. However, in the fast path, if such
>> overhead is allowed, I can move BUG_ON out of any debug configs.
>> Otherwise, as per Andrew's suggestion, I will convert DEBUG_HIGHMEM into
>> DEBUG_VM which is used more frequently.
>
> The v1 patch added a small amount of overhead to kmap_atomic() for what
> is evidently a very small benefit.
>
> Yes, I suggest we remove CONFIG_DEBUG_HIGHMEM from the kernel entirely
> and switch all CONFIG_DEBUG_HIGHMEM sites to use CONFIG_DEBUG_VM.  That way
> the BUG_ON which you believe is useful will be tested by more people
> more often.

Ping!! Anything open for me to do here ?

-- 
Chintan Pandya

QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
member of the Code Aurora Forum, hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
