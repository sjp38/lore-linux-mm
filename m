Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 098DD6B007D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 14:03:49 -0500 (EST)
Message-ID: <4AEF2D0A.4070807@redhat.com>
Date: Mon, 02 Nov 2009 14:03:38 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/11] Add "handle page fault" PV helper.
References: <1257076590-29559-1-git-send-email-gleb@redhat.com> <1257076590-29559-3-git-send-email-gleb@redhat.com> <20091102092214.GB8933@elte.hu>
In-Reply-To: <20091102092214.GB8933@elte.hu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On 11/02/2009 04:22 AM, Ingo Molnar wrote:
>
> * Gleb Natapov<gleb@redhat.com>  wrote:
>
>> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
>> index f4cee90..14707dc 100644
>> --- a/arch/x86/mm/fault.c
>> +++ b/arch/x86/mm/fault.c
>> @@ -952,6 +952,9 @@ do_page_fault(struct pt_regs *regs, unsigned long error_code)
>>   	int write;
>>   	int fault;
>>
>> +	if (arch_handle_page_fault(regs, error_code))
>> +		return;
>> +
>
> This patch is not acceptable unless it's done cleaner. Currently we
> already have 3 callbacks in do_page_fault() (kmemcheck, mmiotrace,
> notifier), and this adds a fourth one.

There's another alternative - add our own exception vector
for async page faults.  Not sure if that is warranted though,
especially if we already have other callbacks in do_page_fault()
and we can consolidate them.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
