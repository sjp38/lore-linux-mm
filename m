Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2BAEiPQ013857
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 21:14:44 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2BAIdCC040810
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 21:18:39 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2BAEv2r012570
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 21:14:57 +1100
Message-ID: <47D65B99.3070208@linux.vnet.ibm.com>
Date: Tue, 11 Mar 2008 15:44:49 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] memcgoup: allow memory.failcnt to be reset
References: <47D65A3E.100@cn.fujitsu.com> <20080311191649.32a2cbae.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080311191649.32a2cbae.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux Containers <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Tue, 11 Mar 2008 19:09:02 +0900
> Li Zefan <lizf@cn.fujitsu.com> wrote:
> 
>> Allow memory.failcnt to be reset to 0:
>>
>>         echo 0 > memory.failcnt
>>
>> And '0' is the only valid value.
>>
> Can't this be generic resource counter function ?
> 

I was about to suggest a generic cgroup option, since we do reset values even
for the cpu accounting subsystem.

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
