Date: Wed, 9 Apr 2008 09:42:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v8)
Message-Id: <20080409094246.f9a2a901.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080404080544.26313.38199.sendpatchset@localhost.localdomain>
References: <20080404080544.26313.38199.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 04 Apr 2008 13:35:44 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> +	/*
> +	 * Search through everything else. We should not get
> +	 * here often
> +	 */
> +	do_each_thread(g, c) {
> +		if (c->mm == mm)
> +			goto assign_new_owner;
> +	} while_each_thread(g, c);
> +
I'm sorry for my laziness.

Why do_each_thread() ? for_each_process() is not enough ?
(because of delay_group_leader().)

And what we have to test for the worst case is following, right ?
==
 1. create a tons of threads.
 2. create a process which calls vfork().
 3. keep child alive and vfork() caller exits
==

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
