Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AFDB86B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 18:35:55 -0500 (EST)
Message-ID: <4AEF6CC3.4000508@redhat.com>
Date: Mon, 02 Nov 2009 18:35:31 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/11] Add "handle page fault" PV helper.
References: <1257076590-29559-1-git-send-email-gleb@redhat.com> <1257076590-29559-3-git-send-email-gleb@redhat.com> <20091102092214.GB8933@elte.hu> <4AEF2D0A.4070807@redhat.com> <4AEF3419.1050200@redhat.com>
In-Reply-To: <4AEF3419.1050200@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On 11/02/2009 02:33 PM, Avi Kivity wrote:
> On 11/02/2009 09:03 PM, Rik van Riel wrote:
>>> This patch is not acceptable unless it's done cleaner. Currently we
>>> already have 3 callbacks in do_page_fault() (kmemcheck, mmiotrace,
>>> notifier), and this adds a fourth one.
>>
>>
>> There's another alternative - add our own exception vector
>> for async page faults. Not sure if that is warranted though,
>> especially if we already have other callbacks in do_page_fault()
>> and we can consolidate them.
>>
>
> We can't add an exception vector since all the existing ones are either
> taken or reserved.

I believe some are reserved for operating system use.

That means the guest can pick one and tell the host to use
that one to notify it.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
