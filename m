Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m27D1PA3030730
	for <linux-mm@kvack.org>; Sat, 8 Mar 2008 00:01:25 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m27D42wI260906
	for <linux-mm@kvack.org>; Sat, 8 Mar 2008 00:04:02 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m27D0OCx022779
	for <linux-mm@kvack.org>; Sat, 8 Mar 2008 00:00:27 +1100
Message-ID: <47D13BF1.1060009@linux.vnet.ibm.com>
Date: Fri, 07 Mar 2008 18:28:25 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Add cgroup support for enabling controllers at boot time
 (v2)
References: <20080307085735.25567.314.sendpatchset@localhost.localdomain> <6599ad830803070125o1ebfd7d1r728cdadf726ecbe2@mail.gmail.com> <6599ad830803070426l22d78446t588691dedeeb490b@mail.gmail.com>
In-Reply-To: <6599ad830803070426l22d78446t588691dedeeb490b@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Fri, Mar 7, 2008 at 1:25 AM, Paul Menage <menage@google.com> wrote:
>>  Doesn't this mean that cgroup_disable=cpu will disable whichever comes
>>  first out of cpuset, cpuacct or cpu in the subsystem list?
> 
> Or rather, it's the other way around - cgroup_disable=cpuset will
> instead disable the "cpu" subsystem if "cpu" comes before "cpuset" in
> the subsystem list.
> 

Would it? I must be missing something, since we do a strncmp with ss->name.
I would expect that to match whole strings.

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
