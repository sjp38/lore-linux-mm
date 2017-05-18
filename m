Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id BBC0E831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 11:29:14 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id 25so15701218qtx.11
        for <linux-mm@kvack.org>; Thu, 18 May 2017 08:29:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d85si5676143qkb.251.2017.05.18.08.29.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 08:29:13 -0700 (PDT)
Subject: Re: [RFC PATCH v2 08/17] cgroup: Move debug cgroup to its own file
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-9-git-send-email-longman@redhat.com>
 <20170517213603.GE942@htj.duckdns.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <03fe182f-92d5-0996-2d9c-d92c878dce35@redhat.com>
Date: Thu, 18 May 2017 11:29:10 -0400
MIME-Version: 1.0
In-Reply-To: <20170517213603.GE942@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On 05/17/2017 05:36 PM, Tejun Heo wrote:
> Hello, Waiman.
>
> On Mon, May 15, 2017 at 09:34:07AM -0400, Waiman Long wrote:
>> The debug cgroup currently resides within cgroup-v1.c and is enabled
>> only for v1 cgroup. To enable the debug cgroup also for v2, it
>> makes sense to put the code into its own file as it will no longer
>> be v1 specific. The only change in this patch is the expansion of
>> cgroup_task_count() within the debug_taskcount_read() function.
>>
>> Signed-off-by: Waiman Long <longman@redhat.com>
> I don't mind enabling the debug controller for v2 but let's please
> hide it behind an unwieldy boot param / controller name so that it's
> clear that its interface isn't expected to be stable.
>
> Thanks.
>
The controller name is "debug". So it is pretty obvious what it is for.
However, the config prompt of "Example controller" is indeed a bit
vague. So I think we can make the prompt more descriptive here. As for
boot param, are you saying something like "cgroup_debug" has to be
specified in the command line also to have this controller activated
even if the CGROUP_DEBUG config parameter is specified? I am fine with
that if you think it is necessary.

Regards,
Longman


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
