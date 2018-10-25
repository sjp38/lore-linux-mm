Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B28826B02A6
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 10:54:26 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d17-v6so4169099edv.4
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 07:54:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i34-v6sor6164562ede.1.2018.10.25.07.54.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 07:54:25 -0700 (PDT)
Date: Thu, 25 Oct 2018 14:54:23 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/3] mm, slub: not retrieve cpu_slub again in
 new_slab_objects()
Message-ID: <20181025145423.rngxmrpnq7g2xvic@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181025094437.18951-1-richard.weiyang@gmail.com>
 <01000166ab7a489c-a877d05e-957c-45b1-8b62-9ede88db40a3-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000166ab7a489c-a877d05e-957c-45b1-8b62-9ede88db40a3-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, Oct 25, 2018 at 01:46:49PM +0000, Christopher Lameter wrote:
>On Thu, 25 Oct 2018, Wei Yang wrote:
>
>> In current code, the following context always meets:
>>
>>   local_irq_save/disable()
>>     ___slab_alloc()
>>       new_slab_objects()
>>   local_irq_restore/enable()
>>
>> This context ensures cpu will continue running until it finish this job
>> before yield its control, which means the cpu_slab retrieved in
>> new_slab_objects() is the same as passed in.
>
>Interrupts can be switched on in new_slab() since it goes to the page
>allocator. See allocate_slab().
>
>This means that the percpu slab may change.

Ah, you are right, thank :-)

-- 
Wei Yang
Help you, Help me
