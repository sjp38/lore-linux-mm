Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6288B6B0007
	for <linux-mm@kvack.org>; Tue,  1 May 2018 18:26:07 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id 106-v6so9879437otg.22
        for <linux-mm@kvack.org>; Tue, 01 May 2018 15:26:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r96-v6sor4916415ota.33.2018.05.01.15.26.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 May 2018 15:26:06 -0700 (PDT)
Subject: Re: [PATCH] proc/kcore: Don't bounds check against address 0
References: <1039518799.26129578.1525185916272.JavaMail.zimbra@redhat.com>
 <20180501201143.15121-1-labbott@redhat.com>
 <20180501144604.1cf872e7938bffc01a26349f@linux-foundation.org>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <4db64722-47b5-767c-4090-bdd9c1522e96@redhat.com>
Date: Tue, 1 May 2018 15:26:00 -0700
MIME-Version: 1.0
In-Reply-To: <20180501144604.1cf872e7938bffc01a26349f@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Anderson <anderson@redhat.com>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Ingo Molnar <mingo@kernel.org>, Andi Kleen <andi@firstfloor.org>

On 05/01/2018 02:46 PM, Andrew Morton wrote:
> On Tue,  1 May 2018 13:11:43 -0700 Laura Abbott <labbott@redhat.com> wrote:
> 
>> The existing kcore code checks for bad addresses against
>> __va(0) with the assumption that this is the lowest address
>> on the system. This may not hold true on some systems (e.g.
>> arm64) and produce overflows and crashes. Switch to using
>> other functions to validate the address range.
>>
>> Tested-by: Dave Anderson <anderson@redhat.com>
>> Signed-off-by: Laura Abbott <labbott@redhat.com>
>> ---
>> I took your previous comments as a tested by, please let me know if that
>> was wrong. This should probably just go through -mm. I don't think this
>> is necessary for stable but I can request it later if necessary.
> 
> I'm surprised.  "overflows and crashes" sounds rather serious??
> 

It's currently only seen on arm64 and it's not clear if anyone
wants to use that particular combination on a stable release.
I think a better phrase is "this is not urgent for stable".

Thanks,
Laura
