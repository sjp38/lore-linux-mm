Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 75C396B0037
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 14:06:40 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so1659346pad.0
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 11:06:40 -0700 (PDT)
Message-ID: <524477AC.9090400@linux.intel.com>
Date: Thu, 26 Sep 2013 11:06:36 -0700
From: Arjan van de Ven <arjan@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [Results] [RFC PATCH v4 00/40] mm: Memory Power Management
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com> <52437128.7030402@linux.vnet.ibm.com> <20130925164057.6bbaf23bdc5057c42b2ab010@linux-foundation.org> <20130925234734.GK18242@two.firstfloor.org> <52438AA9.3020809@linux.intel.com> <20130925182129.a7db6a0fd2c7cc3b43fda92d@linux-foundation.org> <20130926015016.GM18242@two.firstfloor.org> <20130925195953.826a9f7d.akpm@linux-foundation.org> <524439D5.8020306@linux.vnet.ibm.com> <52445993.7050608@linux.intel.com> <52446841.2030301@linux.vnet.ibm.com>
In-Reply-To: <52446841.2030301@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, thomas.abraham@linaro.org, amit.kachhap@linaro.org

>>>>
>>>
>>> Arjan, are you referring to the fact that Intel/SNB systems can exploit
>>> memory self-refresh only when the entire system goes idle? Is that why
>>> this
>>> patchset won't turn out to be that useful on those platforms?
>>
>> no we can use other things (CKE and co) all the time.
>>
>
> Ah, ok..
>
>> just that we found that statistical grouping gave 95%+ of the benefit,
>> without the cost of being aggressive on going to a 100.00% grouping
>>
>
> And how do you do that statistical grouping? Don't you need patches similar
> to those in this patchset? Or are you saying that the existing vanilla
> kernel itself does statistical grouping somehow?

so the way I scanned your patchset.. half of it is about grouping,
the other half (roughly) is about moving stuff.

the grouping makes total sense to me.
actively moving is the part that I am very worried about; that part burns power to do
(and performance).... for which the ROI is somewhat unclear to me
(but... data speaks. I can easily be convinced with data that proves one way or the other)

is moving stuff around the 95%-of-the-work-for-the-last-5%-of-the-theoretical-gain
or is statistical grouping enough to get > 95% of the gain... without the cost of moving.


>
> Also, I didn't fully understand how NUMA policy will help in this case..
> If you want to group memory allocations/references into fewer memory regions
> _within_ a node, will NUMA policy really help? For example, in this patchset,
> everything (all the allocation/reference shaping) is done _within_ the
> NUMA boundary, assuming that the memory regions are subsets of a NUMA node.
>
> Regards,
> Srivatsa S. Bhat
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
