Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2BAF1YW014525
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 21:15:01 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2BAIu2v213664
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 21:18:57 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2BAFEKR013147
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 21:15:14 +1100
Message-ID: <47D65BAA.60908@linux.vnet.ibm.com>
Date: Tue, 11 Mar 2008 15:45:06 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] memcg: put a restriction on writing memory.force_empty
References: <47D65A36.4020008@cn.fujitsu.com>
In-Reply-To: <47D65A36.4020008@cn.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux Containers <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

Li Zefan wrote:
> We can write whatever to memory.force_empty:
> 
>         echo 999 > memory.force_empty
>         echo wow > memory.force_empty
> 
> This is odd, so let's make '1' to be the only valid value.

I suspect as long as there is no unreasonable side-effect, writing 999 or wow
should be OK.

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
