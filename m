Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m4EJe5Ox019082
	for <linux-mm@kvack.org>; Thu, 15 May 2008 01:10:06 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4EJdtAB1204310
	for <linux-mm@kvack.org>; Thu, 15 May 2008 01:09:55 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m4EJe5MR030313
	for <linux-mm@kvack.org>; Thu, 15 May 2008 01:10:05 +0530
Date: Thu, 15 May 2008 01:09:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm][PATCH 4/4] Add memrlimit controller accounting and
	control (v4)
Message-ID: <20080514193946.GA31115@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain> <20080514130951.24440.73671.sendpatchset@localhost.localdomain> <482AE9FA.4080004@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <482AE9FA.4080004@openvz.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* Pavel Emelyanov <xemul@openvz.org> [2008-05-14 17:32:42]:

> 
> AFAIS you didn't cover all the cases when VM expands. At least all
> the arch/ia64/ia32/binfmt_elf32.c is missed.
> 
> I'd insert this charge into insert_vm_struct. This would a) cover
> all of the missed cases and b) reduce the amount of places to patch.
>

I thought I have those covered. insert_vm_struct() is called from
places that we have covered in this patch. As far as
arch/ia64/ia32/binfmt_elf32.c is concerned, it inserts a GDT, LDT
and does not change total_vm. Having said that, I am not against
putting the hooks in insert_vm_struct().
 

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
