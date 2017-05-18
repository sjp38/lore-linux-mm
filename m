Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 21233831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 11:58:45 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j13so15928551qta.13
        for <linux-mm@kvack.org>; Thu, 18 May 2017 08:58:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e30si5966612qtf.272.2017.05.18.08.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 08:58:44 -0700 (PDT)
Subject: Re: [RFC PATCH v2 10/17] cgroup: Make debug cgroup support v2 and
 thread mode
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-11-git-send-email-longman@redhat.com>
 <20170517214338.GG942@htj.duckdns.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <3cb18ea6-fcc1-af92-3926-d65ae0a30b97@redhat.com>
Date: Thu, 18 May 2017 11:58:41 -0400
MIME-Version: 1.0
In-Reply-To: <20170517214338.GG942@htj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On 05/17/2017 05:43 PM, Tejun Heo wrote:
> Hello,
>
> On Mon, May 15, 2017 at 09:34:09AM -0400, Waiman Long wrote:
>> Besides supporting cgroup v2 and thread mode, the following changes
>> are also made:
>>  1) current_* cgroup files now resides only at the root as we don't
>>     need duplicated files of the same function all over the cgroup
>>     hierarchy.
>>  2) The cgroup_css_links_read() function is modified to report
>>     the number of tasks that are skipped because of overflow.
>>  3) The relationship between proc_cset and threaded_csets are displayed.
>>  4) The number of extra unaccounted references are displayed.
>>  5) The status of being a thread root or threaded cgroup is displayed.
>>  6) The current_css_set_read() function now prints out the addresses of
>>     the css'es associated with the current css_set.
>>  7) A new cgroup_subsys_states file is added to display the css objects
>>     associated with a cgroup.
>>  8) A new cgroup_masks file is added to display the various controller
>>     bit masks in the cgroup.
>>
>> Signed-off-by: Waiman Long <longman@redhat.com>
> As noted before, please make it clear that this is a debug feature and
> not expected to be stable.  Also, I don't see why this and the
> previous two patches are in this series.  Can you please split these
> out to a separate patchset?
>
> Thanks.
>
Sure. I can separate out the debug code into a separate patchset. It is
just easier to manage as a single patchset than 2 separate ones.

Regards,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
