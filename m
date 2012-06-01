Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 998236B004D
	for <linux-mm@kvack.org>; Fri,  1 Jun 2012 15:31:45 -0400 (EDT)
Date: Fri, 1 Jun 2012 12:31:33 -0700 (PDT)
From: david@lang.hm
Subject: Re: [PATCH 0/6] mempolicy memory corruption fixlet
In-Reply-To: <alpine.DEB.2.00.1206010850430.6302@router.home>
Message-ID: <alpine.DEB.2.02.1206011230170.17976@asgard.lang.hm>
References: <1338368529-21784-1-git-send-email-kosaki.motohiro@gmail.com> <CA+55aFzoVQ29C-AZYx=G62LErK+7HuTCpZhvovoyS0_KTGGZQg@mail.gmail.com> <alpine.DEB.2.00.1205301328550.31768@router.home> <20120530184638.GU27374@one.firstfloor.org>
 <alpine.DEB.2.00.1205301349230.31768@router.home> <20120530193234.GV27374@one.firstfloor.org> <alpine.DEB.2.00.1205301441350.31768@router.home> <CAHGf_=ooVunBpSdBRCnO1uOoswqxcSy7Xf8xVcgEUGA2fXdcTA@mail.gmail.com> <20120530201042.GY27374@one.firstfloor.org>
 <CAHGf_=r_ZMKNx+VriO6822otF=U_huj7uxoc5GM-2DEVryKxNQ@mail.gmail.com> <alpine.DEB.2.02.1205311744280.17976@asgard.lang.hm> <alpine.DEB.2.00.1206010850430.6302@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andi Kleen <andi@firstfloor.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, stable@vger.kernel.org, hughd@google.com, sivanich@sgi.com

On Fri, 1 Jun 2012, Christoph Lameter wrote:

> Subject: Re: [PATCH 0/6] mempolicy memory corruption fixlet
> 
> On Thu, 31 May 2012, david@lang.hm wrote:
>
>> On Wed, 30 May 2012, KOSAKI Motohiro wrote:
>>
>>> On Wed, May 30, 2012 at 4:10 PM, Andi Kleen <andi@firstfloor.org> wrote:
>>>>> Yes, that's right direction, I think. Currently, shmem_set_policy()
>>>>> can't handle
>>>>> nonlinear mapping.
>>>>
>>>> I've been mulling for some time to just remove non linear mappings.
>>>> AFAIK they were only useful on 32bit and are obsolete and could be
>>>> emulated with VMAs instead.
>>>
>>> I agree. It is only userful on 32bit and current enterprise users don't use
>>> 32bit anymore. So, I don't think emulated by vmas cause user visible issue.
>>
>> I wish this was true, there are a lot of systems out there still running 32
>> bit linux, even on 64 bit capible hardware. This is especially true in
>> enterprises where they have either homegrown or proprietary software that
>> isn't 64 bit clean.
>
> 32 bit binaries (and entire distros) run fine under 64 bit kernels.

unfortunantly, not quite 100% of the time. It's very good, but the 
automount bug a month or so ago is an example of how you can run into rare 
problems. Many "enterprise" systems are not willing to risk it.

David Lang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
