Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1BC726B004D
	for <linux-mm@kvack.org>; Sun,  8 Nov 2009 11:44:54 -0500 (EST)
Message-ID: <4AF6F57C.6060706@zytor.com>
Date: Sun, 08 Nov 2009 08:44:44 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/11] Add "handle page fault" PV helper.
References: <1257076590-29559-1-git-send-email-gleb@redhat.com> <1257076590-29559-3-git-send-email-gleb@redhat.com> <20091102092214.GB8933@elte.hu> <20091102160410.GF27911@redhat.com> <20091102161248.GB15423@elte.hu> <20091102162234.GH27911@redhat.com> <20091102162941.GC14544@elte.hu> <20091102174208.GJ27911@redhat.com> <20091108113654.GO11372@elte.hu> <4AF6BCE5.3030701@redhat.com> <20091108125135.GA13099@elte.hu>
In-Reply-To: <20091108125135.GA13099@elte.hu>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Avi Kivity <avi@redhat.com>, Gleb Natapov <gleb@redhat.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Fr??d??ric Weisbecker <fweisbec@gmail.com>
List-ID: <linux-mm.kvack.org>

On 11/08/2009 04:51 AM, Ingo Molnar wrote:
> 
> * Avi Kivity <avi@redhat.com> wrote:
> 
>> On 11/08/2009 01:36 PM, Ingo Molnar wrote:
>>>> Three existing callbacks are: kmemcheck, mmiotrace, notifier. Two
>>>> of them kmemcheck, mmiotrace are enabled only for debugging, should
>>>> not be performance concern. And notifier call sites (two of them)
>>>> are deliberately, as explained by comment, not at the function entry,
>>>> so can't be unified with others. (And kmemcheck also has two different
>>>> call site BTW)
>>>
>>> We want mmiotrace to be generic distro capable so the overhead when 
>>> the hook is not used is of concern.
>>
>> Maybe we should generalize paravirt-ops patching in case if (x) f() is 
>> deemed too expensive.
> 
> Yes, that's a nice idea. We have quite a number of 'conditional 
> callbacks' in various critical paths that could be made lighter via such 
> a technique.
> 
> It would also free new callbacks from the 'it increases overhead even if 
> unused' criticism and made it easier to add them.
> 

There are a number of other things were we permanently bind to a single
instance of something, too.  Optimizing those away would be nice.
Consider memcpy(), where we may want to have different implementations
for different processors.

	-hpa


-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
