Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0A7D36B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 22:39:17 -0400 (EDT)
Message-ID: <4A8B6649.3080103@redhat.com>
Date: Wed, 19 Aug 2009 10:41:13 +0800
From: Amerigo Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [Patch 8/8] kexec: allow to shrink reserved memory
References: <20090812081731.5757.25254.sendpatchset@localhost.localdomain>	<20090812081906.5757.39417.sendpatchset@localhost.localdomain>	<m1bpmk8l1g.fsf@fess.ebiederm.org>	<4A83893D.50707@redhat.com>	<m1eirg5j9i.fsf@fess.ebiederm.org>	<4A83CD84.8040609@redhat.com>	<m1tz0avy4h.fsf@fess.ebiederm.org>	<4A8927DD.6060209@redhat.com>	<20090818092939.2efbe158.kamezawa.hiroyu@jp.fujitsu.com>	<4A8A4ABB.70003@redhat.com>	<20090818172552.779d0768.kamezawa.hiroyu@jp.fujitsu.com>	<4A8A83F4.6010408@redhat.com> <20090819085703.ccf9992a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090819085703.ccf9992a.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-kernel@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, linux-mm@kvack.org, Neil Horman <nhorman@redhat.com>, Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, bernhard.walle@gmx.de, Fenghua Yu <fenghua.yu@intel.com>, Ingo Molnar <mingo@elte.hu>, Anton Vorontsov <avorontsov@ru.mvista.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 18 Aug 2009 18:35:32 +0800
> Amerigo Wang <amwang@redhat.com> wrote:
>
>   
>> KAMEZAWA Hiroyuki wrote:
>>     
>>> On Tue, 18 Aug 2009 14:31:23 +0800
>>> Amerigo Wang <amwang@redhat.com> wrote:
>>>   
>>>       
>>>>>     It's hidden from the system before mem_init() ?
>>>>>   
>>>>>       
>>>>>           
>>>> Not sure, but probably yes. It is reserved in setup_arch() which is 
>>>> before mm_init() which calls mem_init().
>>>>
>>>> Do you have any advice to free that reserved memory after boot? :)
>>>>
>>>>     
>>>>         
>>> Let's see arch/x86/mm/init.c::free_initmem()
>>>
>>> Maybe it's all you want.
>>>
>>> 	- ClearPageReserved()
>>> 	- init_page_count()
>>> 	- free_page()
>>> 	- totalram_pages++
>>>   
>>>       
>> Just FYI: calling ClearPageReserved() caused an oops: "Unable to handle 
>> paging request".
>>
>> I am trying to figure out why...
>>
>>     
> Hmm...then....memmap is not there.
> pfn_valid() check will help you. What arch ? x86-64 ?
>   

Hmm, yes, x86_64, but this code is arch-independent, I mean it should 
work or not work on all arch, no?

So I am afraid we need to use other API to free it...

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
