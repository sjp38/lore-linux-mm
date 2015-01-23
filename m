Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 85F7F6B006C
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 07:51:15 -0500 (EST)
Received: by mail-we0-f176.google.com with SMTP id w62so7392623wes.7
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 04:51:15 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id da6si2833735wjb.92.2015.01.23.04.51.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 04:51:13 -0800 (PST)
Message-ID: <54C243B8.7050103@suse.cz>
Date: Fri, 23 Jan 2015 13:51:04 +0100
From: Michal Marek <mmarek@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v9 01/17] Add kernel address sanitizer infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1421859105-25253-1-git-send-email-a.ryabinin@samsung.com> <1421859105-25253-2-git-send-email-a.ryabinin@samsung.com> <54C23FFB.5010800@suse.cz> <54C24321.5010205@samsung.com>
In-Reply-To: <54C24321.5010205@samsung.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, open@kvack.org, list@kvack.org, DOCUMENTATION <linux-doc@vger.kernel.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>

On 2015-01-23 13:48, Andrey Ryabinin wrote:
> On 01/23/2015 03:35 PM, Michal Marek wrote:
>> On 2015-01-21 17:51, Andrey Ryabinin wrote:
>>> +ifdef CONFIG_KASAN_INLINE
>>> +	call_threshold := 10000
>>> +else
>>> +	call_threshold := 0
>>> +endif
>>
>> Can you please move this to a Kconfig helper like you did with
>> CONFIG_KASAN_SHADOW_OFFSET? Despite occasional efforts to reduce the
>> size of the main Makefile, it has been growing over time. With this
>> patch set, we are approaching 2.6.28's record of 1669 lines.
>>
> 
> How about moving the whole kasan stuff into scripts/Makefile.kasan
> and just include it in generic Makefile?

That would be even better!

Thanks,
Michal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
