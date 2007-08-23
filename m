Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l7N8gZg1188534
	for <linux-mm@kvack.org>; Thu, 23 Aug 2007 18:42:38 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7N8gHDU200820
	for <linux-mm@kvack.org>; Thu, 23 Aug 2007 18:42:17 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7N8chqT014371
	for <linux-mm@kvack.org>; Thu, 23 Aug 2007 18:38:43 +1000
Message-ID: <46CD478D.5060603@linux.vnet.ibm.com>
Date: Thu, 23 Aug 2007 14:08:37 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Memory controller Add Documentation
References: <20070822130612.18981.58696.sendpatchset@balbir-laptop> <20070823173621.4539b376.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070823173621.4539b376.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>, Linux MM Mailing List <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Eric W Biederman <ebiederm@xmission.com>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Thank you for documentaion. How about adding following topics ?
> 
> - Benefit and Purpose. When this function help a user.
> - What is accounted as RSS.
> - What is accounted as page-cache.
> - What are not accoutned now.
> - When a page is accounted (charged.)
> - about mem_control_type
> - When a user can remove memory controller with no tasks (by rmdir)
>   and What happens if a user does.
> - What happens when a user migrates a task to other container.
> 

Thanks for your input. I'll try and incorporate your comments into
the documentation (I think it will help developers and users alike).

> Writing all above may be too much :)
> 
> I'm sorry if I say something pointless.
> 

No.. not at all! Thank you for reading the documentation and commenting
on it.

> Thanks,
> -Kame
> 
> 


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
