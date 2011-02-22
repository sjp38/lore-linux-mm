Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7D7548D0048
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 17:31:35 -0500 (EST)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p1MMVXqs012131
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 14:31:33 -0800
Received: from pxi19 (pxi19.prod.google.com [10.243.27.19])
	by hpaq1.eem.corp.google.com with ESMTP id p1MMUqZf003050
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 14:31:31 -0800
Received: by pxi19 with SMTP id 19so424928pxi.15
        for <linux-mm@kvack.org>; Tue, 22 Feb 2011 14:31:24 -0800 (PST)
Date: Tue, 22 Feb 2011 14:31:17 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [0/7, v9] NUMA Hotplug Emulator (v9)
In-Reply-To: <20101210073119.156388875@intel.com>
Message-ID: <alpine.DEB.2.00.1102221429030.31758@chino.kir.corp.google.com>
References: <20101210073119.156388875@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, Andi Kleen <ak@linux.intel.com>, dave@linux.vnet.ibm.com, Greg Kroah-Hartman <gregkh@suse.de>

On Fri, 10 Dec 2010, shaohui.zheng@intel.com wrote:

> v9:
> 
> Solve the bug reported by Eric B Munson, check the return value of cpu_down when do
>  CPU release.
> 
> Solve the conflicts with Tejun Heo' Unificaton NUMA code, re-work patch 5 based on his
> patch.
> 
> Some small changes on debugfs per-node add_memory interface.
> 

Hi Shaohui,

Tejun's NUMA unification work has been merged into x86/mm, so I think it 
would possible to rebase your hotplug emulator patchset on top of it 
without too many conflicts now.

It should probably be based on x86/mm from 
http://git.kernel.org/?p=linux/kernel/git/mingo/linux-2.6-x86.git

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
