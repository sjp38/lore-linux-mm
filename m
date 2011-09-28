Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C2BC79000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 22:29:34 -0400 (EDT)
Received: by fxh17 with SMTP id 17so180172fxh.14
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 19:29:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <m24o01khcp.fsf@firstfloor.org>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
	<1316393805-3005-7-git-send-email-glommer@parallels.com>
	<m24o01khcp.fsf@firstfloor.org>
Date: Wed, 28 Sep 2011 07:59:31 +0530
Message-ID: <CAKTCnzm_BVOLK8c0rwYoDJCs+-920DWjwHFoQtgriRTEXrGiqw@mail.gmail.com>
Subject: Re: [PATCH v3 6/7] tcp buffer limitation: per-cgroup limit
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name

On Sat, Sep 24, 2011 at 10:28 PM, Andi Kleen <andi@firstfloor.org> wrote:
> Glauber Costa <glommer@parallels.com> writes:
>
>> This patch uses the "tcp_max_mem" field of the kmem_cgroup to
>> effectively control the amount of kernel memory pinned by a cgroup.
>>
>> We have to make sure that none of the memory pressure thresholds
>> specified in the namespace are bigger than the current cgroup.
>
> I noticed that some other OS known by bash seem to have a rlimit per
> process for this. Would that make sense too? Not sure how difficult
> your infrastructure would be to extend to that.

rlimit per process for tcp usage? Interesting, that reminds me, we
need to revisit rlimit (RSS) at some point

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
