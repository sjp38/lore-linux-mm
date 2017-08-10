Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 30F436B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 04:26:25 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t25so250580pfg.15
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 01:26:25 -0700 (PDT)
Received: from mail-pg0-x22d.google.com (mail-pg0-x22d.google.com. [2607:f8b0:400e:c05::22d])
        by mx.google.com with ESMTPS id t202si3662573pgb.68.2017.08.10.01.26.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 01:26:24 -0700 (PDT)
Received: by mail-pg0-x22d.google.com with SMTP id u185so291067pgb.1
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 01:26:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170810081920.GG23863@dhcp22.suse.cz>
References: <CADK2BfzM9V=C3Kk6v714K3NVX58Q6pEaAMiHDGSyr6PakC2O=w@mail.gmail.com>
 <20170810071059.GC23863@dhcp22.suse.cz> <CADK2BfwC3WDGwoDPSjX1UpwP-4fDz5fSBjdENbxn5XQL8y3K3A@mail.gmail.com>
 <20170810081920.GG23863@dhcp22.suse.cz>
From: wang Yu <yuwang668899@gmail.com>
Date: Thu, 10 Aug 2017 16:26:23 +0800
Message-ID: <CADK2BfxJim8MvLPY497a+JAK2t9OTq+f1BY0o4qK0ihaWsoEMQ@mail.gmail.com>
Subject: Re: memcg Can't context between v1 and v2 because css->refcnt not released
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

2017-08-10 16:19 GMT+08:00 Michal Hocko <mhocko@kernel.org>:
> [Please do not top-post]
>
> On Thu 10-08-17 16:10:45, wang Yu wrote:
>> at first ,thanks for your reply.
>> but i also tested what you said, the problem is also.
>> force_empty only call try_to_free_pages, not all the pages remove
>> because mem_cgroup_reparent_charges moved
>
> Right. An alternative would be dropping the page cache globaly via
> /proc/sys/vm/drop_caches. Not an ideal solution but it should help.
> --
> Michal Hocko
> SUSE Labs

thanks again, but /proc/sys/vm/drop_caches can't solve it
you can try as follow

#cat /proc/cgroups

memory 11 2 1

#mkdir a

#echo 0 > a/cgroup.procs

#sleep 1

#echo 0 > cgroup.procs

#echo 1 > a/memory.force_empty

#echo 3 > /proc/sys/vm/drop_caches

#rmdir  a

#cat /proc/cgroups

memory 11 3 1
the  num_cgroups not decrease

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
