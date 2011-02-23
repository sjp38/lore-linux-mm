Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 60D1C8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 22:29:38 -0500 (EST)
Message-ID: <4D647F1D.2000307@linux.intel.com>
Date: Wed, 23 Feb 2011 11:29:33 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [0/7, v9] NUMA Hotplug Emulator (v9)
References: <20101210073119.156388875@intel.com> <alpine.DEB.2.00.1102221429030.31758@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1102221429030.31758@chino.kir.corp.google.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Shaohui Zheng <shaohui.zheng@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lethal@linux-sh.org, Andi Kleen <ak@linux.intel.com>, dave@linux.vnet.ibm.com, Greg Kroah-Hartman <gregkh@suse.de>, yang.z.zhang@intel.com, "You, Yongkang" <yongkang.you@intel.com>

Shaohui is out of position recently. Include Yang Zhang and Yongkang You in 
this loop, who are Shaohui's backup.

David Rientjes wrote:
> On Fri, 10 Dec 2010, shaohui.zheng@intel.com wrote:
> 
>> v9:
>>
>> Solve the bug reported by Eric B Munson, check the return value of cpu_down when do
>>  CPU release.
>>
>> Solve the conflicts with Tejun Heo' Unificaton NUMA code, re-work patch 5 based on his
>> patch.
>>
>> Some small changes on debugfs per-node add_memory interface.
>>
> 
> Hi Shaohui,
> 
> Tejun's NUMA unification work has been merged into x86/mm, so I think it 
> would possible to rebase your hotplug emulator patchset on top of it 
> without too many conflicts now.
> 
> It should probably be based on x86/mm from 
> http://git.kernel.org/?p=linux/kernel/git/mingo/linux-2.6-x86.git
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
