Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BA1259000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 13:34:59 -0400 (EDT)
Message-ID: <4DFF84BB.3050209@redhat.com>
Date: Tue, 21 Jun 2011 01:34:51 +0800
From: Cong Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: completely disable THP by transparent_hugepage=never
References: <1308587683-2555-1-git-send-email-amwang@redhat.com> <20110620165844.GA9396@suse.de> <4DFF7E3B.1040404@redhat.com> <4DFF7F0A.8090604@redhat.com> <4DFF8106.8090702@redhat.com> <4DFF8327.1090203@redhat.com>
In-Reply-To: <4DFF8327.1090203@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

ao? 2011a1'06ae??21ae?JPY 01:28, Rik van Riel a??e??:
> On 06/20/2011 01:19 PM, Cong Wang wrote:
>> ao? 2011a1'06ae??21ae?JPY 01:10, Rik van Riel a??e??:
>>> On 06/20/2011 01:07 PM, Cong Wang wrote:
>>>> ao? 2011a1'06ae??21ae?JPY 00:58, Mel Gorman a??e??:
>>>>> On Tue, Jun 21, 2011 at 12:34:28AM +0800, Amerigo Wang wrote:
>>>>>> transparent_hugepage=never should mean to disable THP completely,
>>>>>> otherwise we don't have a way to disable THP completely.
>>>>>> The design is broken.
>>>>>>
>>>>>
>>>>> I don't get why it's broken. Why would the user be prevented from
>>>>> enabling it at runtime?
>>>>>
>>>>
>>>> We need to a way to totally disable it, right? Otherwise, when I
>>>> configure
>>>> THP in .config, I always have THP initialized even when I pass "=never".
>>>>
>>>> For me, if you don't provide such way to disable it, it is not flexible.
>>>>
>>>> I meet this problem when I try to disable THP in kdump kernel, there is
>>>> no user of THP in kdump kernel, THP is a waste for kdump kernel. This is
>>>> why I need to find a way to totally disable it.
>>>
>>> What you have not explained yet is why having THP
>>> halfway initialized (but not used, and without a
>>> khugepaged thread) is a problem at all.
>>>
>>> Why is it a problem for you?
>>
>> It occupies some memory, memory is valuable in kdump kernel (usually
>> only 128M). :) Since I am sure no one will use it, why do I still need
>> to initialize it at all?
>
> Lets take a look at how much memory your patches end
> up saving.
>
> By bailing out earlier in hugepage_init, you end up
> saving 3 sysfs objects, one slab cache and a hash
> table with 1024 pointers. That's a total of maybe
> 10kB of memory on a 64 bit system.
>
> I'm not convinced that a 10kB memory reduction is
> worth the price of never being able to enable
> transparent hugepages when a system is booted with
> THP disabled...
>

Even if it is really 10K, why not save it since it doesn't
much effort to make this. ;) Not only memory, but also time,
this could also save a little time to initialize the kernel.

For me, the more serious thing is the logic, there is
no way to totally disable it as long as I have THP in .config
currently. This is why I said the design is broken.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
