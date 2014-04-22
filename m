Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f181.google.com (mail-ve0-f181.google.com [209.85.128.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1A7086B006E
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 16:13:21 -0400 (EDT)
Received: by mail-ve0-f181.google.com with SMTP id oy12so10426989veb.12
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 13:13:20 -0700 (PDT)
Received: from mail-ve0-x229.google.com (mail-ve0-x229.google.com [2607:f8b0:400c:c01::229])
        by mx.google.com with ESMTPS id vb6si7082381vec.20.2014.04.22.13.13.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 13:13:20 -0700 (PDT)
Received: by mail-ve0-f169.google.com with SMTP id pa12so10182640veb.14
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 13:13:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140422200531.GA19334@alpha.arachsys.com>
References: <20140416154650.GA3034@alpha.arachsys.com> <20140418155939.GE4523@dhcp22.suse.cz>
 <5351679F.5040908@parallels.com> <20140420142830.GC22077@alpha.arachsys.com>
 <20140422143943.20609800@oracle.com> <20140422200531.GA19334@alpha.arachsys.com>
From: Tim Hockin <thockin@google.com>
Date: Tue, 22 Apr 2014 13:13:00 -0700
Message-ID: <CAO_RewZki4qihUTab+g-N_dpGnmH2kJ3nYhV2pjR2QfWNW6CnQ@mail.gmail.com>
Subject: Re: Protection against container fork bombs [WAS: Re: memcg with kmem
 limit doesn't recover after disk i/o causes limit to be hit]
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: Dwight Engen <dwight.engen@oracle.com>, Vladimir Davydov <vdavydov@parallels.com>, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, Max Kellermann <mk@cm4all.com>, Johannes Weiner <hannes@cmpxchg.org>, William Dauchy <wdauchy@gmail.com>, Tim Hockin <thockin@hockin.org>, Michal Hocko <mhocko@suse.cz>, Daniel Walsh <dwalsh@redhat.com>, Daniel Berrange <berrange@redhat.com>, cgroups@vger.kernel.org, containers@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

Who in kernel-land still needs to be convinced of the utility of this idea?

On Tue, Apr 22, 2014 at 1:05 PM, Richard Davies <richard@arachsys.com> wrote:
> Dwight Engen wrote:
>> Richard Davies wrote:
>> > Vladimir Davydov wrote:
>> > > In short, kmem limiting for memory cgroups is currently broken. Do
>> > > not use it. We are working on making it usable though.
> ...
>> > What is the best mechanism available today, until kmem limits mature?
>> >
>> > RLIMIT_NPROC exists but is per-user, not per-container.
>> >
>> > Perhaps there is an up-to-date task counter patchset or similar?
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
>
> Thanks,
>
> Richard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
