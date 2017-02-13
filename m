Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 813496B0388
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 09:40:56 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id e137so151322699itc.0
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 06:40:56 -0800 (PST)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0130.outbound.protection.outlook.com. [104.47.2.130])
        by mx.google.com with ESMTPS id k140si10866847ioe.44.2017.02.13.06.40.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 13 Feb 2017 06:40:55 -0800 (PST)
Subject: Re: [PATCHv4 2/5] x86/mm: introduce mmap{,_legacy}_base
References: <20170130120432.6716-1-dsafonov@virtuozzo.com>
 <20170130120432.6716-3-dsafonov@virtuozzo.com>
 <alpine.DEB.2.20.1702102033420.4042@nanos>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <adca283e-3187-dff0-7db6-3cb98d6b3bc5@virtuozzo.com>
Date: Mon, 13 Feb 2017 17:37:09 +0300
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1702102033420.4042@nanos>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org

On 02/11/2017 05:13 PM, Thomas Gleixner wrote:
>> -static unsigned long mmap_base(unsigned long rnd)
>> +static unsigned long mmap_base(unsigned long rnd, unsigned long task_size)
>>  {
>> 	unsigned long gap = rlimit(RLIMIT_STACK);
> 	unsigned long gap_min, gap_max;
>
> 	/* Add comment what this means */
> 	gap_min = SIZE_128M + stack_maxrandom_size(task_size);
> 	/* Explain that ' /6 * 5' magic */
> 	gap_max = (task_size / 6) * 5;

So, I can't find about those limits on a gap size:
They were introduced by commit 8913d55b6c58 ("i386 virtual memory
layout rework").
All I could find is that 128Mb limit was more limit on virtual adress
space than on a memory available those days.
And 5/6 of task_size looks like heuristic value.
So I'm not sure, what to write in comments:
that rlimit on stack can't be bigger than 5/6 of task_size?
That looks obvious from the code.


-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
