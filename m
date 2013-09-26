Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C6DD06B0037
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 13:05:09 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so1587690pab.29
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 10:05:09 -0700 (PDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Thu, 26 Sep 2013 22:35:03 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 389CD1258054
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 22:35:12 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8QH4uKQ49152058
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 22:34:56 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8QH4urq001881
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 22:34:57 +0530
Message-ID: <52446841.2030301@linux.vnet.ibm.com>
Date: Thu, 26 Sep 2013 22:30:49 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [Results] [RFC PATCH v4 00/40] mm: Memory Power Management
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com> <52437128.7030402@linux.vnet.ibm.com> <20130925164057.6bbaf23bdc5057c42b2ab010@linux-foundation.org> <20130925234734.GK18242@two.firstfloor.org> <52438AA9.3020809@linux.intel.com> <20130925182129.a7db6a0fd2c7cc3b43fda92d@linux-foundation.org> <20130926015016.GM18242@two.firstfloor.org> <20130925195953.826a9f7d.akpm@linux-foundation.org> <524439D5.8020306@linux.vnet.ibm.com> <52445993.7050608@linux.intel.com>
In-Reply-To: <52445993.7050608@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, thomas.abraham@linaro.org, amit.kachhap@linaro.org

On 09/26/2013 09:28 PM, Arjan van de Ven wrote:
> On 9/26/2013 6:42 AM, Srivatsa S. Bhat wrote:
>> On 09/26/2013 08:29 AM, Andrew Morton wrote:
>>> On Thu, 26 Sep 2013 03:50:16 +0200 Andi Kleen <andi@firstfloor.org>
>>> wrote:
>>>
>>>> On Wed, Sep 25, 2013 at 06:21:29PM -0700, Andrew Morton wrote:
>>>>> On Wed, 25 Sep 2013 18:15:21 -0700 Arjan van de Ven
>>>>> <arjan@linux.intel.com> wrote:
>>>>>
>>>>>> On 9/25/2013 4:47 PM, Andi Kleen wrote:
>>>>>>>> Also, the changelogs don't appear to discuss one obvious
>>>>>>>> downside: the
>>>>>>>> latency incurred in bringing a bank out of one of the low-power
>>>>>>>> states
>>>>>>>> and back into full operation.  Please do discuss and quantify
>>>>>>>> that to
>>>>>>>> the best of your knowledge.
>>>>>>>
>>>>>>> On Sandy Bridge the memry wakeup overhead is really small. It's
>>>>>>> on by default
>>>>>>> in most setups today.
>>>>>>
>>>>>> btw note that those kind of memory power savings are
>>>>>> content-preserving,
>>>>>> so likely a whole chunk of these patches is not actually needed on
>>>>>> SNB
>>>>>> (or anything else Intel sells or sold)
>>>>>
>>>>> (head spinning a bit).  Could you please expand on this rather a lot?
>>>>
>>>> As far as I understand there is a range of aggressiveness. You could
>>>> just group memory a bit better (assuming you can sufficiently predict
>>>> the future or have some interface to let someone tell you about it).
>>>>
>>>> Or you can actually move memory around later to get as low footprint
>>>> as possible.
>>>>
>>>> This patchkit seems to do both, with the later parts being on the
>>>> aggressive side (move things around)
>>>>
>>>> If you had non content preserving memory saving you would
>>>> need to be aggressive as you couldn't afford any mistakes.
>>>>
>>>> If you had very slow wakeup you also couldn't afford mistakes,
>>>> as those could cost a lot of time.
>>>>
>>>> On SandyBridge is not slow and it's preserving, so some mistakes are
>>>> ok.
>>>>
>>>> But being aggressive (so move things around) may still help you saving
>>>> more power -- i guess only benchmarks can tell. It's a trade off
>>>> between
>>>> potential gain and potential worse case performance regression.
>>>> It may also depend on the workload.
>>>>
>>>> At least right now the numbers seem to be positive.
>>>
>>> OK.  But why are "a whole chunk of these patches not actually needed
>>> on SNB
>>> (or anything else Intel sells or sold)"?  What's the difference between
>>> Intel products and whatever-it-is-this-patchset-was-designed-for?
>>>
>>
>> Arjan, are you referring to the fact that Intel/SNB systems can exploit
>> memory self-refresh only when the entire system goes idle? Is that why
>> this
>> patchset won't turn out to be that useful on those platforms?
> 
> no we can use other things (CKE and co) all the time.
> 

Ah, ok..

> just that we found that statistical grouping gave 95%+ of the benefit,
> without the cost of being aggressive on going to a 100.00% grouping
> 

And how do you do that statistical grouping? Don't you need patches similar
to those in this patchset? Or are you saying that the existing vanilla
kernel itself does statistical grouping somehow?

Also, I didn't fully understand how NUMA policy will help in this case..
If you want to group memory allocations/references into fewer memory regions
_within_ a node, will NUMA policy really help? For example, in this patchset,
everything (all the allocation/reference shaping) is done _within_ the
NUMA boundary, assuming that the memory regions are subsets of a NUMA node.

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
