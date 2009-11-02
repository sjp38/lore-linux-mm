Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 951326B0062
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 10:19:24 -0500 (EST)
Message-ID: <4AEEF878.2090805@redhat.com>
Date: Mon, 02 Nov 2009 17:19:20 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 08/11] Add "wait for page" hypercall.
References: <1257076590-29559-1-git-send-email-gleb@redhat.com> <1257076590-29559-9-git-send-email-gleb@redhat.com> <4AEED907.5030306@redhat.com> <20091102151320.GC27911@redhat.com>
In-Reply-To: <20091102151320.GC27911@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 11/02/2009 05:13 PM, Gleb Natapov wrote:
> On Mon, Nov 02, 2009 at 03:05:11PM +0200, Avi Kivity wrote:
>    
>> On 11/01/2009 01:56 PM, Gleb Natapov wrote:
>>      
>>> We want to be able to inject async pagefault into guest event if a guest
>>> is not executing userspace code. But in this case guest may receive
>>> async page fault in non-sleepable context. In this case it will be
>>> able to make "wait for page" hypercall vcpu will be put to sleep until
>>> page is swapped in and guest can continue without reschedule.
>>>        
>> What's wrong with just 'hlt' and checking in the guest?
>>
>>      
> Halting here will leave vcpu with interrupt disabled and this will prevent
> "wake up" signal delivery.

Page faults can be delivered with interrupts disabled.

>   Enabling interrupts is also not an options
> since we can't be sure that vcpu can process interrupt at this point.
>    

That's too bad, allowing interrupts in this context can help maintain 
responsiveness.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
