Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m561udDQ010573
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 07:26:39 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m561u68b872466
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 07:26:06 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m561ucnD029095
	for <linux-mm@kvack.org>; Fri, 6 Jun 2008 07:26:38 +0530
Message-ID: <484898FF.4040701@linux.vnet.ibm.com>
Date: Fri, 06 Jun 2008 07:25:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: clean up checking of  the disabled flag
References: <4848955D.2020302@cn.fujitsu.com>
In-Reply-To: <4848955D.2020302@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Li Zefan wrote:
> Those checks are unnecessary, because when the subsystem is disabled
> it can't be mounted, so those functions won't get called.
> 
> The check is needed in functions which will be called in other places
> except cgroup.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Yep, that should work

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

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
