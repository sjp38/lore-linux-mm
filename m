From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <4937651.1222104886847.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 23 Sep 2008 02:34:46 +0900 (JST)
Subject: Re: Re: Re: Re: [PATCH 9/13] memcg: lookup page cgroup (and remove pointer from struct page)
In-Reply-To: <1222099850.8533.60.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <1222099850.8533.60.camel@nimitz>
 <1222098450.8533.41.camel@nimitz>
	 <1222095177.8533.14.camel@nimitz>
	 <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080922201206.e73d9ce6.kamezawa.hiroyu@jp.fujitsu.com>
	 <31600854.1222096483210.kamezawa.hiroyu@jp.fujitsu.com>
	 <32459434.1222099038142.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, xemul@openvz.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

>On Tue, 2008-09-23 at 00:57 +0900, kamezawa.hiroyu@jp.fujitsu.com wrote:
>> I'll add FLATMEM/SPARSEMEM support later. Could you wait for a while ?
>> Because we have lookup_page_cgroup() after this, we can do anything.
>
>OK, I'll stop harassing for the moment, and take a look at the cache. :)
>
Why I don't say "optimize this! now! more!" is where this is called is
limited now. only at charge/uncharge. This is not memmap.

 charge     ...the first page fault to the page
                  add to radix-tree
 uncharge   ...the last unmap aginst the page
                  remove from radix-tree.

I can make this faster by using charactoristics of FLATMEM and others.
(with more #ifdefs and codes.)
But would like to start from generic one because adding interface is
the first thing I have to do here.

BTW, to be honest, I don't like 2-level-table-lookup like
SPARSEMEM_EXTREME, here. A style like SPARSEMEM_VMEMMAP...using 
linear virtual address map will be goal of mine.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
