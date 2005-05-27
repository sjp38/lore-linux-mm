Date: Fri, 27 May 2005 22:16:13 +0900 (JST)
Message-Id: <20050527.221613.78716667.taka@valinux.co.jp>
Subject: Virtual NUMA machine and CKRM
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20050519003008.GC25076@chandralinux.beaverton.ibm.com>
References: <20050519003008.GC25076@chandralinux.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sekharan@us.ibm.com
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Chandra,

Why don't you implement CKRM memory controller as virtual NUMA
node.

I think what you want do is almost what NUMA code does, which
restricts resources to use. If you define virtual NUMA node with
some memory and some virtual CPUs, you can just assign target jobs
to them.

What do you think of my idea?

Thanks,
Hirokazu Takahashi.

> I am looking for improvement suggestions
>         - to not have a field in the page data structure for the mem
>           controller
> 	- to make vmscan.c cleaner.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
