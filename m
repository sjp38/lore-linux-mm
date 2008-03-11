Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2B59ZJq007327
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 16:09:35 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2B5BMmn130012
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 16:11:22 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2B57jFi001223
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 16:07:46 +1100
Message-ID: <47D61395.1010801@linux.vnet.ibm.com>
Date: Tue, 11 Mar 2008 10:37:33 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: +
References: <20080311043149.20251.50059.sendpatchset@localhost.localdomain> <20080311135933.8937.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080311135933.8937.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Hi
> 
>> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>> ---
>>
>>  linux/memcontrol.h |    0 
> 
> ???
> unnecessary hunk?
> or diff comannd bug?

I use Andrew Morton's patchutils and specified both include/linux/memcontrol.h
and mm/memcontrol.c

$ cat pc/memory-controller-move-to-own-slab.pc
mm/memcontrol.c
include/linux/memcontrol.h

But refpatch generates linux/memcontrol.h. I am using diffstat v1.41. I'll
reboot to FC8 and see if that makes any difference.


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
