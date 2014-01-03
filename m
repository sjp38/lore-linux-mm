Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3696B0031
	for <linux-mm@kvack.org>; Fri,  3 Jan 2014 17:08:56 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so16138407pab.6
        for <linux-mm@kvack.org>; Fri, 03 Jan 2014 14:08:56 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.11.231])
        by mx.google.com with ESMTPS id ot3si47055224pac.21.2014.01.03.14.08.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jan 2014 14:08:55 -0800 (PST)
Message-ID: <52C734F4.5020602@codeaurora.org>
Date: Fri, 03 Jan 2014 14:08:52 -0800
From: Laura Abbott <lauraa@codeaurora.org>
MIME-Version: 1.0
Subject: Re: [RFC PATCHv3 00/11] Intermix Lowmem and vmalloc
References: <1388699609-18214-1-git-send-email-lauraa@codeaurora.org> <52C70024.1060605@sr71.net>
In-Reply-To: <52C70024.1060605@sr71.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, Andrew Morton <akpm@linux-foundation.org>, Kyungmin Park <kmpark@infradead.org>, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org

On 1/3/2014 10:23 AM, Dave Hansen wrote:
> On 01/02/2014 01:53 PM, Laura Abbott wrote:
>> The goal here is to allow as much lowmem to be mapped as if the block of memory
>> was not reserved from the physical lowmem region. Previously, we had been
>> hacking up the direct virt <-> phys translation to ignore a large region of
>> memory. This did not scale for multiple holes of memory however.
>
> How much lowmem do these holes end up eating up in practice, ballpark?
> I'm curious how painful this is going to get.
>

In total, the worst case can be close to 100M with an average case 
around 70M-80M. The split and number of holes vary with the layout but 
end up with 60M-80M one hole and the rest in the other.

Thanks,
Laura

-- 
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
