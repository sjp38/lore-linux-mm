Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 588E98D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 14:13:41 -0400 (EDT)
Date: Thu, 24 Mar 2011 20:13:18 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
In-Reply-To: <20110324172653.GA28507@elte.hu>
Message-ID: <alpine.DEB.2.00.1103242011540.4990@tiger>
References: <alpine.DEB.2.00.1103221635400.4521@tiger> <20110324142146.GA11682@elte.hu> <alpine.DEB.2.00.1103240940570.32226@router.home> <AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com> <20110324172653.GA28507@elte.hu>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323329-1280347503-1300990398=:4990"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Christoph Lameter <cl@linux.com>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1280347503-1300990398=:4990
Content-Type: TEXT/PLAIN; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT

Hi Ingo,

On Thu, 24 Mar 2011, Ingo Molnar wrote:
> * Pekka Enberg <penberg@kernel.org> wrote:
>
>> On Thu, Mar 24, 2011 at 4:41 PM, Christoph Lameter <cl@linux.com> wrote:
>>> On Thu, 24 Mar 2011, Ingo Molnar wrote:
>>>
>>>> FYI, some sort of boot crash has snuck upstream in the last 24 hours:
>>>>
>>>>  BUG: unable to handle kernel paging request at ffff87ffc147e020
>>>>  IP: [<ffffffff811aa762>] this_cpu_cmpxchg16b_emu+0x2/0x1c
>>>
>>> Hmmm.. This is the fallback code for the case that the processor does not
>>> support cmpxchg16b.
>>
>> How does alternative_io() work? Does it require
>> alternative_instructions() to be executed. If so, the fallback code
>> won't be active when we enter kmem_cache_init(). Is there any reason
>> check_bugs() is called so late during boot? Can we do something like
>> the totally untested attached patch?
>
> Does the config i sent you boot on your box? I think the bug is pretty generic
> and should trigger on any box.

Here's a patch that reorganizes the alternatives fixup to happen earlier 
so that the fallback should work. It boots on my machine so please give it 
a spin if possible.

I'll try out your .config next.

 			Pekka
--8323329-1280347503-1300990398=:4990--
