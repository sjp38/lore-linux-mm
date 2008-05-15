Message-ID: <482C7F70.2020102@qumranet.com>
Date: Thu, 15 May 2008 21:22:40 +0300
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 1/4] Add memrlimit controller documentation (v4)
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain> <20080514130915.24440.56106.sendpatchset@localhost.localdomain>
In-Reply-To: <20080514130915.24440.56106.sendpatchset@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> +
> +Advantages of providing this feature
> +
> +1. Control over virtual address space allows for a cgroup to fail gracefully
> +   i.e., via a malloc or mmap failure as compared to OOM kill when no
> +   pages can be reclaimed.
>   

Do you mean by this, limiting the number of pagetable pages (that are 
pinned in memory), this preventing oom by a cgroup that instantiates 
many pagetables?


-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
