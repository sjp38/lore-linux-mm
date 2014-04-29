Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9FFD16B0035
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 09:57:48 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so367370eek.20
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 06:57:47 -0700 (PDT)
Received: from BlackPearl.yuhu.biz (mail.bgservers.net. [85.14.7.126])
        by mx.google.com with ESMTP id 45si27142984eeh.3.2014.04.29.06.57.45
        for <linux-mm@kvack.org>;
        Tue, 29 Apr 2014 06:57:46 -0700 (PDT)
Message-ID: <535FAFD8.1040402@yuhu.biz>
Date: Tue, 29 Apr 2014 16:57:44 +0300
From: Marian Marinov <mm@yuhu.biz>
MIME-Version: 1.0
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
References: <20140416154650.GA3034@alpha.arachsys.com> <20140418155939.GE4523@dhcp22.suse.cz> <5351679F.5040908@parallels.com> <20140420142830.GC22077@alpha.arachsys.com> <20140422143943.20609800@oracle.com> <20140422200531.GA19334@alpha.arachsys.com> <535758A0.5000500@yuhu.biz> <20140423084942.560ae837@oracle.com> <20140428180025.GC25689@ubuntumail> <20140429072515.GB15058@dhcp22.suse.cz> <20140429130353.GA27354@ubuntumail>
In-Reply-To: <20140429130353.GA27354@ubuntumail>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Serge Hallyn <serge.hallyn@ubuntu.com>, Michal Hocko <mhocko@suse.cz>
Cc: Richard Davies <richard@arachsys.com>, Vladimir Davydov <vdavydov@parallels.com>, Max Kellermann <mk@cm4all.com>, Tim Hockin <thockin@hockin.org>, Frederic Weisbecker <fweisbec@gmail.com>, containers@lists.linux-foundation.org, Daniel Walsh <dwalsh@redhat.com>, cgroups@vger.kernel.org, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, David Rientjes <rientjes@google.com>

On 04/29/2014 04:03 PM, Serge Hallyn wrote:
> Quoting Michal Hocko (mhocko@suse.cz):
>> On Mon 28-04-14 18:00:25, Serge Hallyn wrote:
>>> Quoting Dwight Engen (dwight.engen@oracle.com):
>>>> On Wed, 23 Apr 2014 09:07:28 +0300
>>>> Marian Marinov <mm@yuhu.biz> wrote:
>>>>
>>>>> On 04/22/2014 11:05 PM, Richard Davies wrote:
>>>>>> Dwight Engen wrote:
>>>>>>> Richard Davies wrote:
>>>>>>>> Vladimir Davydov wrote:
>>>>>>>>> In short, kmem limiting for memory cgroups is currently broken.
>>>>>>>>> Do not use it. We are working on making it usable though.
>>>>>> ...
>>>>>>>> What is the best mechanism available today, until kmem limits
>>>>>>>> mature?
>>>>>>>>
>>>>>>>> RLIMIT_NPROC exists but is per-user, not per-container.
>>>>>>>>
>>>>>>>> Perhaps there is an up-to-date task counter patchset or similar?
>>>>>>>
>>>>>>> I updated Frederic's task counter patches and included Max
>>>>>>> Kellermann's fork limiter here:
>>>>>>>
>>>>>>> http://thread.gmane.org/gmane.linux.kernel.containers/27212
>>>>>>>
>>>>>>> I can send you a more recent patchset (against 3.13.10) if you
>>>>>>> would find it useful.
>>>>>>
>>>>>> Yes please, I would be interested in that. Ideally even against
>>>>>> 3.14.1 if you have that too.
>>>>>
>>>>> Dwight, do you have these patches in any public repo?
>>>>>
>>>>> I would like to test them also.
>>>>
>>>> Hi Marian, I put the patches against 3.13.11 and 3.14.1 up at:
>>>>
>>>> git://github.com/dwengen/linux.git cpuacct-task-limit-3.13
>>>> git://github.com/dwengen/linux.git cpuacct-task-limit-3.14
>>>
>>> Thanks, Dwight.  FWIW I'm agreed with Tim, Dwight, Richard, and Marian
>>> that a task limit would be a proper cgroup extension, and specifically
>>> that approximating that with a kmem limit is not a reasonable substitute.
>>
>> The current state of the kmem limit, which is improving a lot thanks to
>> Vladimir, is not a reason for a new extension/controller. We are just
>> not yet there.
>
> It has nothing to do with the state of the limit.  I simply don't
> believe that emulating RLIMIT_NPROC by controlling stack size is a
> good idea.
>
> -serge

I think that having a limit on the number of processes allowed in a cgroup is a lot better then relaying on the kmem limit.
The problem that task-limit tries to solve is degradation of system performance caused by too many processes in a 
certain cgroup. I'm currently testing the patches with 3.12.16.

-hackman


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
