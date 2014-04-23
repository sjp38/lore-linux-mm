Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id C2BF26B0070
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 02:07:33 -0400 (EDT)
Received: by mail-ee0-f52.google.com with SMTP id e49so324958eek.39
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 23:07:33 -0700 (PDT)
Received: from BlackPearl.yuhu.biz (mail.bgservers.net. [85.14.7.126])
        by mx.google.com with ESMTP id x47si1568479eel.43.2014.04.22.23.07.31
        for <linux-mm@kvack.org>;
        Tue, 22 Apr 2014 23:07:31 -0700 (PDT)
Message-ID: <535758A0.5000500@yuhu.biz>
Date: Wed, 23 Apr 2014 09:07:28 +0300
From: Marian Marinov <mm@yuhu.biz>
MIME-Version: 1.0
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
References: <20140416154650.GA3034@alpha.arachsys.com> <20140418155939.GE4523@dhcp22.suse.cz> <5351679F.5040908@parallels.com> <20140420142830.GC22077@alpha.arachsys.com> <20140422143943.20609800@oracle.com> <20140422200531.GA19334@alpha.arachsys.com>
In-Reply-To: <20140422200531.GA19334@alpha.arachsys.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>, Dwight Engen <dwight.engen@oracle.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, Max Kellermann <mk@cm4all.com>, Johannes Weiner <hannes@cmpxchg.org>, William Dauchy <wdauchy@gmail.com>, Tim Hockin <thockin@hockin.org>, Michal Hocko <mhocko@suse.cz>, Daniel Walsh <dwalsh@redhat.com>, Daniel Berrange <berrange@redhat.com>, cgroups@vger.kernel.org, containers@lists.linux-foundation.org, linux-mm@kvack.org

On 04/22/2014 11:05 PM, Richard Davies wrote:
> Dwight Engen wrote:
>> Richard Davies wrote:
>>> Vladimir Davydov wrote:
>>>> In short, kmem limiting for memory cgroups is currently broken. Do
>>>> not use it. We are working on making it usable though.
> ...
>>> What is the best mechanism available today, until kmem limits mature?
>>>
>>> RLIMIT_NPROC exists but is per-user, not per-container.
>>>
>>> Perhaps there is an up-to-date task counter patchset or similar?
>>
>> I updated Frederic's task counter patches and included Max Kellermann's
>> fork limiter here:
>>
>> http://thread.gmane.org/gmane.linux.kernel.containers/27212
>>
>> I can send you a more recent patchset (against 3.13.10) if you would
>> find it useful.
>
> Yes please, I would be interested in that. Ideally even against 3.14.1 if
> you have that too.

Dwight, do you have these patches in any public repo?

I would like to test them also.

Marian

>
> Thanks,
>
> Richard.
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
