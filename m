Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A11E36B006A
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 03:56:50 -0500 (EST)
Message-ID: <4B5816B6.9090607@redhat.com>
Date: Thu, 21 Jan 2010 10:56:22 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 04/12] Add "handle page fault" PV helper.
References: <1262700774-1808-5-git-send-email-gleb@redhat.com> <1263490267.4244.340.camel@laptop> <20100117144411.GI31692@redhat.com> <4B541D08.9040802@zytor.com> <20100118085022.GA30698@redhat.com> <4B5510B1.9010202@zytor.com> <20100119065537.GF14345@redhat.com> <4B55E5D8.1070402@zytor.com> <20100119174438.GA19450@redhat.com> <4B5611A9.4050301@zytor.com> <20100120100254.GC5238@redhat.com> <4B56F040.1080703@redhat.com> <4B573AEF.9010007@redhat.com>
In-Reply-To: <4B573AEF.9010007@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Gleb Natapov <gleb@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, tglx@linutronix.de, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 01/20/2010 07:18 PM, Rik van Riel wrote:
> On 01/20/2010 07:00 AM, Avi Kivity wrote:
>> On 01/20/2010 12:02 PM, Gleb Natapov wrote:
>>>
>>> I can inject the event as HW interrupt on vector greater then 32 but 
>>> not
>>> go through APIC so EOI will not be required. This sounds
>>> non-architectural
>>> and I am not sure kernel has entry point code for this kind of 
>>> event, it
>>> has one for exception and one for interrupts that goes through 
>>> __do_IRQ()
>>> which assumes that interrupts should be ACKed.
>>
>> Further, we start to interact with the TPR; Linux doesn't use the TPR or
>> cr8 but if it does one day we don't want it interfering with apf.
>
> That's not an issue is it?  The guest will tell the host what
> vector to use for pseudo page faults.

And kill 15 other vectors?

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
