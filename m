Subject: Re: [RFC][PATCH] another swap controller for cgroup
In-Reply-To: Your message of "Mon, 24 Mar 2008 21:10:14 +0900"
	<47E79A26.3070401@mxp.nes.nec.co.jp>
References: <47E79A26.3070401@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080325031039.549831E9292@siro.lan>
Date: Tue, 25 Mar 2008 12:10:39 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nishimura@mxp.nes.nec.co.jp
Cc: hugh@veritas.com, balbir@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, minoura@valinux.co.jp, containers@lists.osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi,

> Daisuke Nishimura wrote:
> > Hi, Yamamoto-san.
> > 
> > I'm reviewing and testing your patch now.
> > 
> 
> In building kernel infinitely(in a cgroup of
> memory.limit=64M and swap.limit=128M, with swappiness=100),
> almost all of the swap (1GB) is consumed as swap cache
> after a day or so.
> As a result, processes are occasionally OOM-killed even when
> the swap.usage of the group doesn't exceed the limit.
> 
> I don't know why the swap cache uses up swap space.
> I will test whether a similar issue happens without your patch.
> Do you have any thoughts?

my patch tends to yield more swap cache because it makes try_to_unmap
fail and shrink_page_list leaves swap cache in that case.
i'm not sure how it causes 1GB swap cache, tho.

YAMAMOTO Takashi

> 
> BTW, I think that it would be better, in the sence of
> isolating memory resource, if there is a framework
> to limit the usage of swap cache.
> 
> 
> Thanks,
> Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
