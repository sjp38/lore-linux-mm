Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE13B28070C
	for <linux-mm@kvack.org>; Fri, 19 May 2017 15:33:18 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id j22so21803963qtj.15
        for <linux-mm@kvack.org>; Fri, 19 May 2017 12:33:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s40si9143899qtg.293.2017.05.19.12.33.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 12:33:18 -0700 (PDT)
Subject: Re: [RFC PATCH v2 08/17] cgroup: Move debug cgroup to its own file
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-9-git-send-email-longman@redhat.com>
 <20170517213603.GE942@htj.duckdns.org>
 <ee36d4f8-9e9d-a5c7-2174-56c21aaf75af@redhat.com>
 <20170519192146.GA9741@wtj.duckdns.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <8d942ee6-ebf4-5ba5-5484-60762808f544@redhat.com>
Date: Fri, 19 May 2017 15:33:14 -0400
MIME-Version: 1.0
In-Reply-To: <20170519192146.GA9741@wtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On 05/19/2017 03:21 PM, Tejun Heo wrote:
> Hello, Waiman.
>
> On Thu, May 18, 2017 at 11:52:18AM -0400, Waiman Long wrote:
>> The controller name is "debug" and so it is obvious what this controll=
er
>> is for. However, the config prompt "Example controller" is indeed vagu=
e
> Yeah but it also shows up as an integral part of stable interface
> rather than e.g. /sys/kernel/debug.  This isn't of any interest to
> people who aren't developing cgroup core code.  There is no reason to
> risk growing dependencies on it.

The debug controller is used to show information relevant to the cgroup
its css'es are attached to. So it will be very hard to use if we
relocate to /sys/kernel/debug, for example. Currently, nothing in the
debug controller other than debug_cgrp_subsys are exported. I don't see
any risk of having dependency on that controller from other parts of the
kernel.

>> in meaning. So we can make the prompt more descriptive here. As for th=
e
>> boot param, are you saying something like "cgroup_debug" has to be
>> specified in the command line even if CGROUP_DEBUG config is there for=

>> the debug controller to be enabled? I am fine with that if you think i=
t
>> is necessary.
> Yeah, I think that'd be a good idea.  cgroup_debug should do.  While
> at it, can you also please make CGROUP_DEBUG depend on DEBUG_KERNEL?
>
> Thanks.
>
Sure. I will do that.

Cheers,
Longman


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
