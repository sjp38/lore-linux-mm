Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id BD19C6B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 11:56:24 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id l18so1384781wgh.14
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 08:56:24 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id by5si12043322wjc.114.2014.06.05.08.56.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 08:56:09 -0700 (PDT)
Message-ID: <5390930A.8050504@nod.at>
Date: Thu, 05 Jun 2014 17:55:54 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] oom: Be less verbose if the oom_control event fd
 has listeners
References: <1401976841-3899-1-git-send-email-richard@nod.at> <1401976841-3899-2-git-send-email-richard@nod.at> <20140605150025.GB15939@dhcp22.suse.cz>
In-Reply-To: <20140605150025.GB15939@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: hannes@cmpxchg.org, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, vdavydov@parallels.com, tj@kernel.org, handai.szj@taobao.com, rientjes@google.com, oleg@redhat.com, rusty@rustcorp.com.au, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

Am 05.06.2014 17:00, schrieb Michal Hocko:
> On Thu 05-06-14 16:00:41, Richard Weinberger wrote:
>> Don't spam the kernel logs if the oom_control event fd has listeners.
>> In this case there is no need to print that much lines as user space
>> will anyway notice that the memory cgroup has reached its limit.
> 
> But how do you debug why it is reaching the limit and why a particular
> process has been killed?

In my case it's always because customer's Java application gone nuts.
So I don't really have to debug a lot. ;-)
But I can understand your point.

> If we are printing too much then OK, let's remove those parts which are
> not that useful but hiding information which tells us more about the oom
> decision doesn't sound right to me.

What about adding a sysctl like "vm.oom_verbose"?
By default it would be 1.
If set to 0 the full OOM information is only printed out if nobody listens
to the event fd.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
