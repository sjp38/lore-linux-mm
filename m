Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id AE1D66B00C5
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 08:20:07 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id q58so3697544wes.2
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 05:20:07 -0700 (PDT)
Received: from lon-b.elastichosts.com (old.lon-b.elastichosts.com. [84.45.121.3])
        by mx.google.com with ESMTPS id g8si22047997wjr.97.2014.06.10.05.20.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Jun 2014 05:20:06 -0700 (PDT)
Message-ID: <5396F77B.6040604@elastichosts.com>
Date: Tue, 10 Jun 2014 13:18:03 +0100
From: Alin Dobre <alin.dobre@elastichosts.com>
MIME-Version: 1.0
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with
 kmem limit doesn't recover after disk i/o causes limit to be hit]
References: <20140416154650.GA3034@alpha.arachsys.com> <20140418155939.GE4523@dhcp22.suse.cz> <5351679F.5040908@parallels.com> <20140420142830.GC22077@alpha.arachsys.com> <20140422143943.20609800@oracle.com> <20140422200531.GA19334@alpha.arachsys.com>
In-Reply-To: <20140422200531.GA19334@alpha.arachsys.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>, Dwight Engen <dwight.engen@oracle.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, Max Kellermann <mk@cm4all.com>, Johannes Weiner <hannes@cmpxchg.org>, William Dauchy <wdauchy@gmail.com>, Tim Hockin <thockin@hockin.org>, Michal Hocko <mhocko@suse.cz>, Daniel Walsh <dwalsh@redhat.com>, Daniel Berrange <berrange@redhat.com>, cgroups@vger.kernel.org, containers@lists.linux-foundation.org, linux-mm@kvack.org

On 22/04/14 21:05, Richard Davies wrote:
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

Any chance for a 3.15 rebase, since the changes from cgroup_fork() makes
the operation no longer trivial.

Cheers,
Alin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
