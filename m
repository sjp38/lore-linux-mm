Date: Fri, 27 May 2005 07:09:19 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: Virtual NUMA machine and CKRM
Message-ID: <223620000.1117202959@[10.10.2.4]>
In-Reply-To: <20050527.221613.78716667.taka@valinux.co.jp>
References: <20050519003008.GC25076@chandralinux.beaverton.ibm.com> <20050527.221613.78716667.taka@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>, sekharan@us.ibm.com
Cc: ckrm-tech@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Why don't you implement CKRM memory controller as virtual NUMA
> node.
> 
> I think what you want do is almost what NUMA code does, which
> restricts resources to use. If you define virtual NUMA node with
> some memory and some virtual CPUs, you can just assign target jobs
> to them.
> 
> What do you think of my idea?

Please don't do that. For one, it'll make a mess of the NUMA code.
For another, it'll get really complicated once you have CKRM on top
of a NUMA system. Don't confuse the physical aspects of the machines
(its NUMA topology) with virtual resource limits.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
