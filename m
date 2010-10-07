Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C11246B0071
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 13:48:33 -0400 (EDT)
Message-ID: <4CAE07E1.5050701@redhat.com>
Date: Thu, 07 Oct 2010 13:48:17 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 08/12] Handle async PF in a guest.
References: <1286207794-16120-1-git-send-email-gleb@redhat.com> <1286207794-16120-9-git-send-email-gleb@redhat.com> <4CADC6C3.3040305@redhat.com> <20101007171418.GA2397@redhat.com> <4CAE00CB.1070400@redhat.com>
In-Reply-To: <4CAE00CB.1070400@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, cl@linux-foundation.org, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

On 10/07/2010 01:18 PM, Avi Kivity wrote:
> On 10/07/2010 07:14 PM, Gleb Natapov wrote:

>> Host side keeps track of outstanding apfs and will not send apf for the
>> same phys address twice. It will halt vcpu instead.
>
> What about different pages, running the scheduler code?
>
> Oh, and we'll run the scheduler recursively.

When preempt is disabled in the guest, it will not invoke
the "reschedule for apf" code, but it will simply turn
into a normal page fault.

Last I looked, the scheduler code disabled preempt (for
obvious reasons).

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
