Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 846166B0007
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 18:21:13 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 17-v6so20989343pgs.18
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 15:21:13 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id v32-v6si19389414pgk.16.2018.10.17.15.21.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 15:21:12 -0700 (PDT)
Subject: Re: [PATCH 1/2] serial: set suppress_bind_attrs flag only if builtin
References: <20181017140311.28679-1-anders.roxell@linaro.org>
 <20181017150546.0d451252950214bec74a6fc8@linux-foundation.org>
From: Jeffrey Hugo <jhugo@codeaurora.org>
Message-ID: <e0763032-3ae6-b352-e586-ad131ce689ca@codeaurora.org>
Date: Wed, 17 Oct 2018 16:21:08 -0600
MIME-Version: 1.0
In-Reply-To: <20181017150546.0d451252950214bec74a6fc8@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Anders Roxell <anders.roxell@linaro.org>
Cc: Arnd Bergmann <arnd@arndb.de>, gregkh@linuxfoundation.org, linux@armlinux.org.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-serial@vger.kernel.org, tj@kernel.org, linux-arm-kernel@lists.infradead.org

On 10/17/2018 4:05 PM, Andrew Morton wrote:
> On Wed, 17 Oct 2018 16:03:10 +0200 Anders Roxell <anders.roxell@linaro.org> wrote:
> 
>> Cc: Arnd Bergmann <arnd@arndb.de>
>> Co-developed-by: Arnd Bergmann <arnd@arndb.de>
>> Signed-off-by: Anders Roxell <anders.roxell@linaro.org>
> 
> This should have Arnd's Signed-off-by: as well.

I'm just interested to know, why?

-- 
Jeffrey Hugo
Qualcomm Datacenter Technologies as an affiliate of Qualcomm 
Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
