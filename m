Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6DB6B0010
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 18:41:39 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id f5-v6so22096730plf.11
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 15:41:39 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id t6-v6si18197410pgk.306.2018.10.17.15.41.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 15:41:38 -0700 (PDT)
Subject: Re: [PATCH 1/2] serial: set suppress_bind_attrs flag only if builtin
References: <20181017140311.28679-1-anders.roxell@linaro.org>
 <20181017150546.0d451252950214bec74a6fc8@linux-foundation.org>
 <e0763032-3ae6-b352-e586-ad131ce689ca@codeaurora.org>
 <20181017153223.6c4e5156895dad7973f7d059@linux-foundation.org>
From: Jeffrey Hugo <jhugo@codeaurora.org>
Message-ID: <0bc08889-4801-33b6-8273-5cf2123baba5@codeaurora.org>
Date: Wed, 17 Oct 2018 16:41:34 -0600
MIME-Version: 1.0
In-Reply-To: <20181017153223.6c4e5156895dad7973f7d059@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Anders Roxell <anders.roxell@linaro.org>, Arnd Bergmann <arnd@arndb.de>, gregkh@linuxfoundation.org, linux@armlinux.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-serial@vger.kernel.org, tj@kernel.org, linux-arm-kernel@lists.infradead.org

On 10/17/2018 4:32 PM, Andrew Morton wrote:
> On Wed, 17 Oct 2018 16:21:08 -0600 Jeffrey Hugo <jhugo@codeaurora.org> wrote:
> 
>> On 10/17/2018 4:05 PM, Andrew Morton wrote:
>>> On Wed, 17 Oct 2018 16:03:10 +0200 Anders Roxell <anders.roxell@linaro.org> wrote:
>>>
>>>> Cc: Arnd Bergmann <arnd@arndb.de>
>>>> Co-developed-by: Arnd Bergmann <arnd@arndb.de>
>>>> Signed-off-by: Anders Roxell <anders.roxell@linaro.org>
>>>
>>> This should have Arnd's Signed-off-by: as well.
>>
>> I'm just interested to know, why?
> 
> So that Arnd certifies that
> 
>          (a) The contribution was created in whole or in part by me and I
>              have the right to submit it under the open source license
>              indicated in the file; or
> 
> and all the other stuff in Documentation/process/submitting-patches.rst
> section 11!
> 
> Also, because section 12 says so :)  And that final sentence is, I
> believe, appropriate.

Ah, interesting.  I see that the documentation was updated since I was 
told last year in the same situation by a different maintainer that 
co-authors should not have SOB lines on the patch.

Good to know.  Thanks for illuminating me.

-- 
Jeffrey Hugo
Qualcomm Datacenter Technologies as an affiliate of Qualcomm 
Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
