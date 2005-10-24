Date: Mon, 24 Oct 2005 14:52:58 +0900 (JST)
Message-Id: <20051024.145258.98349934.taka@valinux.co.jp>
Subject: Re: [PATCH] cpuset confine pdflush to its cpuset
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20051024001913.7030.71597.sendpatchset@jackhammer.engr.sgi.com>
References: <20051024001913.7030.71597.sendpatchset@jackhammer.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pj@sgi.com
Cc: akpm@osdl.org, Simon.Derr@bull.net, linux-kernel@vger.kernel.org, clameter@sgi.com, torvalds@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Paul,

I realized CPUSETS has another problem around pdflush.

Some cpuset may make most of pages in it dirty, while the others don't.
In this case, pdflush may not start since the ratio of the dirty pages
in the box may be less than the watermark, which is defined globally.
This may probably make it hard to allocate pages from the cpuset
or the nodes it depends on. This wouldn't be good for NUMA machine
without cpusets either.

Do you have any plans about it?

> This patch keeps pdflush daemons on the same cpuset as their
> parent, the kthread daemon.
> 
> Some large NUMA configurations put as much as they can of
> kernel threads and other classic Unix load in what's called a
> bootcpuset, keeping the rest of the system free for dedicated
> jobs.
> 
> This effort is thwarted by pdflush, which dynamically destroys
> and recreates pdflush daemons depending on load.


Thanks,
Hirokazu Takahashi.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
