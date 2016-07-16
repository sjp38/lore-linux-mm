Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB5576B0253
	for <linux-mm@kvack.org>; Sat, 16 Jul 2016 13:06:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so282630226pfa.2
        for <linux-mm@kvack.org>; Sat, 16 Jul 2016 10:06:19 -0700 (PDT)
Received: from mx0a-000f0801.pphosted.com (mx0a-000f0801.pphosted.com. [2620:100:9001:7a::1])
        by mx.google.com with ESMTPS id ss9si16242062pab.185.2016.07.16.10.06.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 16 Jul 2016 10:06:18 -0700 (PDT)
Subject: Re: [PATCH 3.10.y 04/12] x86/mm: Add barriers and document
 switch_mm()-vs-flush synchronization
References: <1468607194-3879-1-git-send-email-ciwillia@brocade.com>
 <1468607194-3879-4-git-send-email-ciwillia@brocade.com>
 <20160716091543.GA22375@1wt.eu>
From: "Charles (Chas) Williams" <ciwillia@brocade.com>
Message-ID: <55076269-f859-8c77-3074-54f359119a7f@brocade.com>
Date: Sat, 16 Jul 2016 13:04:45 -0400
MIME-Version: 1.0
In-Reply-To: <20160716091543.GA22375@1wt.eu>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Willy Tarreau <w@1wt.eu>
Cc: stable@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>, Luis Henriques <luis.henriques@canonical.com>

I didn't submit for 3.14 --  I will do so Monday.

On 07/16/2016 05:15 AM, Willy Tarreau wrote:
> Hi Chas,
>
> On Fri, Jul 15, 2016 at 02:26:26PM -0400, Charles (Chas) Williams wrote:
>> From: Andy Lutomirski <luto@kernel.org>
>>
>> commit 71b3c126e61177eb693423f2e18a1914205b165e upstream.
>>
>> When switch_mm() activates a new PGD, it also sets a bit that
>> tells other CPUs that the PGD is in use so that TLB flush IPIs
>> will be sent.  In order for that to work correctly, the bit
>> needs to be visible prior to loading the PGD and therefore
>> starting to fill the local TLB.
>>
>> Document all the barriers that make this work correctly and add
>> a couple that were missing.
>>
>> CVE-2016-2069
>
> I'm fine with queuing these patches for 3.10, but patches 4, 9 and 12
> of your series are not in 3.14, and I only apply patches to 3.10 if
> they are already present in 3.14 (or if there's a good reason of course).
> Please could you check that you already submitted them ? If so I'll just
> wait for them to pop up there. It's important for us to ensure that users
> upgrading from extended LTS kernels to normal LTS kernels are never hit
> by a bug that was previously fixed in the older one and not yet in the
> newer one.
>
> Thanks,
> Willy
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
