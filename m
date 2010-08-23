Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0157F6B03C7
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 12:19:57 -0400 (EDT)
Message-ID: <4C729F9E.1060907@redhat.com>
Date: Mon, 23 Aug 2010 19:19:42 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 03/12] Add async PF initialization to PV guest.
References: <1279553462-7036-1-git-send-email-gleb@redhat.com> <1279553462-7036-4-git-send-email-gleb@redhat.com> <4C729342.6070205@redhat.com> <20100823153549.GU10499@redhat.com> <alpine.DEB.2.00.1008231105230.8601@router.home>
In-Reply-To: <alpine.DEB.2.00.1008231105230.8601@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, mtosatti@redhat.com
List-ID: <linux-mm.kvack.org>

  On 08/23/2010 07:08 PM, Christoph Lameter wrote:
> On Mon, 23 Aug 2010, Gleb Natapov wrote:
>
>>> The guest will have to align this on a 64 byte boundary, should this
>>> be marked __aligned(64) here?
>>>
>> I do __aligned(64) when I declare variable of that type:
>>
>> static DEFINE_PER_CPU(struct kvm_vcpu_pv_apf_data, apf_reason) __aligned(64);
> 64 byte boundary: You mean cacheline aligned? We have a special define for
> that.
>
> DEFINE_PER_CPU_SHARED_ALIGNED
>

It's an ABI, so we can't use something that might change when Intel 
releases a cpu with 75.2 byte cache lines.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
