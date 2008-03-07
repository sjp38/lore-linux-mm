Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id m27DUpBI029341
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 19:00:51 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m27DUo4v1048758
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 19:00:50 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id m27DUoiC019582
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 13:30:50 GMT
Message-ID: <47D1431C.6060107@linux.vnet.ibm.com>
Date: Fri, 07 Mar 2008 18:59:00 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Add cgroup support for enabling controllers at boot time
 (v2)
References: <20080307085735.25567.314.sendpatchset@localhost.localdomain> <6599ad830803070125o1ebfd7d1r728cdadf726ecbe2@mail.gmail.com> <6599ad830803070426l22d78446t588691dedeeb490b@mail.gmail.com> <47D13BF1.1060009@linux.vnet.ibm.com> <6599ad830803070509v1ec83aeet9f63bfd61a00ef19@mail.gmail.com>
In-Reply-To: <6599ad830803070509v1ec83aeet9f63bfd61a00ef19@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Fri, Mar 7, 2008 at 4:58 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>  > Or rather, it's the other way around - cgroup_disable=cpuset will
>>  > instead disable the "cpu" subsystem if "cpu" comes before "cpuset" in
>>  > the subsystem list.
>>  >
>>
>>  Would it? I must be missing something, since we do a strncmp with ss->name.
>>  I would expect that to match whole strings.
>>
> 
> No, strncmp only checks the first n characters - so in that case,
> you'd be checking for !strncmp("cpuset", "cpu", 3), which will return
> true

Aaah.. I see the problem now.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
