Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C0DD16B00A5
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 04:07:40 -0500 (EST)
Message-ID: <4B5818EA.10709@redhat.com>
Date: Thu, 21 Jan 2010 11:05:46 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 04/12] Add "handle page fault" PV helper.
References: <4B541D08.9040802@zytor.com> <20100118085022.GA30698@redhat.com> <4B5510B1.9010202@zytor.com> <20100119065537.GF14345@redhat.com> <4B55E5D8.1070402@zytor.com> <20100119174438.GA19450@redhat.com> <4B5611A9.4050301@zytor.com> <20100120100254.GC5238@redhat.com> <4B5740CD.4020005@zytor.com> <4B58181B.60405@redhat.com> <20100121090421.GS5238@redhat.com>
In-Reply-To: <20100121090421.GS5238@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, tglx@linutronix.de, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On 01/21/2010 11:04 AM, Gleb Natapov wrote:
>
>> Do you mean create the stack frame manually?  I'd really like to
>> avoid that for many reasons, one of which is performance (need to do
>> all the virt-to-phys walks manually), the other is that we're
>> certain to end up with something horribly underspecified.  I'd
>> really like to keep as close as possible to the hardware.  For the
>> alternative approach, see Xen.
>>
>>      
> That and our event injection path can't play with guest memory right now
> since it is done from atomic context.
>    

That's true (I'd like to fix that though, for the real mode stuff).

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
