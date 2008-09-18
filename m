Date: Thu, 18 Sep 2008 15:13:26 +0900 (JST)
Message-Id: <20080918.151326.98179387.taka@valinux.co.jp>
Subject: Re: [RFC][PATCH] Remove cgroup member from struct page (v3)
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20080918135023.99cac1d0.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080917184008.92b7fc4c.akpm@linux-foundation.org>
	<20080918.132613.74431429.taka@valinux.co.jp>
	<20080918135023.99cac1d0.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, dave@linux.vnet.ibm.com, nickpiggin@yahoo.com.au, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

> > But I think each memory model type should have its own way of managing
> > its page_cgroup arrays as doing for its struct page arrays.
> > It would be better rather than the sparsemem approach he said.
> > 
> My patch adds an interface. Then...
> FLATMEM support will be very easy.

Yes, that is true, it is really easy.

> I'll ignore DISCONTIGMEM and SPARSEMEM (they will use my 'hash')

What part of this do you think is the problem to implement it in the
straight way for this model?
I think it won't be difficult to implement it since each pgdat can have
its page_cgroup array, which can care about holes in the node as well as
doing it for its struct page array.

> SPARSEMEM_VMEMMAP support will took some amount of time. It will need
> per-arch patches.

Yes, each of ia64, powerpc and x86_64 use this memory model.

We should also care about the regular SPARSEMEM case as you mentioned.

> Thanks,
> -Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
