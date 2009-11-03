Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A5E5B6B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 23:57:19 -0500 (EST)
Message-ID: <4AEFB823.4040607@redhat.com>
Date: Tue, 03 Nov 2009 06:57:07 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/11] Add "handle page fault" PV helper.
References: <1257076590-29559-1-git-send-email-gleb@redhat.com> <1257076590-29559-3-git-send-email-gleb@redhat.com> <20091102092214.GB8933@elte.hu> <4AEF2D0A.4070807@redhat.com> <4AEF3419.1050200@redhat.com> <4AEF6CC3.4000508@redhat.com>
In-Reply-To: <4AEF6CC3.4000508@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Ingo Molnar <mingo@elte.hu>, Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On 11/03/2009 01:35 AM, Rik van Riel wrote:
>> We can't add an exception vector since all the existing ones are either
>> taken or reserved.
>
>
> I believe some are reserved for operating system use.

Table 6-1 says:

   9 |  | Coprocessor Segment Overrun (reserved)  |  Fault |  No  | 
Floating-point instruction.2
   15 |  a?? |  (Intel reserved. Do not use.) |   | No |
   20-31 |  a?? | Intel reserved. Do not use.  |
   32-255 |  a??  | User Defined (Non-reserved) Interrupts |  Interrupt  
|   | External interrupt or INT n instruction.

So we can only use 32-255, but these are not fault-like exceptions that 
can be delivered with interrupts disabled.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
