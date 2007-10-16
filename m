Date: Tue, 16 Oct 2007 11:28:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memory cgroup enhancements [0/5] intro
Message-Id: <20071016112843.e4b8ebe3.akpm@linux-foundation.org>
In-Reply-To: <471500EC.1080502@linux.vnet.ibm.com>
References: <20071016191949.cd50f12f.kamezawa.hiroyu@jp.fujitsu.com>
	<471500EC.1080502@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, containers@lists.osdl.org, yamamoto@valinux.co.jp
List-ID: <linux-mm.kvack.org>

On Tue, 16 Oct 2007 23:50:28 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > [1/5] ... force_empty patch
> > [2/5] ... remember page is charged as page-cache patch
> > [3/5] ... remember page is on which list patch
> > [4/5] ... memory cgroup statistics patch
> > [5/5] ... show statistics patch
> > 
> > tested on x86-64/fake-NUMA + CONFIG_PREEMPT=y/n (for testing preempt_disable())
> > 
> > Any comments are welcome.
> > 
> 
> Hi, KAMEZAWA-San,
> 
> I would prefer these patches to go in once the fixes that you've posted
> earlier have gone in (the migration fix series). I am yet to test the
> migration fix per-se, but the series seemed quite fine to me. Andrew
> could you please pick it up.

It's in my backlog somewhere.  I'm not paying much attention to things
which don't look like 2.6.24 material at present...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
