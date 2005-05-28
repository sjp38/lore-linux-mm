Date: Sat, 28 May 2005 16:40:32 +0900 (JST)
Message-Id: <20050528.164032.44791727.taka@valinux.co.jp>
Subject: Re: Virtual NUMA machine and CKRM
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <223620000.1117202959@[10.10.2.4]>
References: <20050519003008.GC25076@chandralinux.beaverton.ibm.com>
	<20050527.221613.78716667.taka@valinux.co.jp>
	<223620000.1117202959@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mbligh@mbligh.org
Cc: sekharan@us.ibm.com, ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> > Why don't you implement CKRM memory controller as virtual NUMA
> > node.
> > 
> > I think what you want do is almost what NUMA code does, which
> > restricts resources to use. If you define virtual NUMA node with
> > some memory and some virtual CPUs, you can just assign target jobs
> > to them.
> > 
> > What do you think of my idea?
> 
> Please don't do that. For one, it'll make a mess of the NUMA code.
> For another, it'll get really complicated once you have CKRM on top
> of a NUMA system. Don't confuse the physical aspects of the machines
> (its NUMA topology) with virtual resource limits.

I guessed you might say that.

But I feel the kernel would become much messier than that if CKRM is
implemented independently of the NUMA code, having the similar code
redundantly.

Though I'm not sure if it's the best way, it would be worth investigating.

> M.

Thanks,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
