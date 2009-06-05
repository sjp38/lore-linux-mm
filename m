Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 2B4816B004F
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 22:22:10 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n552M7KL028478
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Jun 2009 11:22:08 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 49BE945DD7E
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 11:22:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 22A3845DD7D
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 11:22:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 037331DB8041
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 11:22:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id ADFAF1DB803F
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 11:22:06 +0900 (JST)
Date: Fri, 5 Jun 2009 11:20:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] remove memory.limit v.s. memsw.limit comparison.
Message-Id: <20090605112036.2dd64ab1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090605093420.0b208c33.nishimura@mxp.nes.nec.co.jp>
References: <20090604141043.9a1064fd.kamezawa.hiroyu@jp.fujitsu.com>
	<20090604123625.GE7504@balbir.in.ibm.com>
	<0921392c77890fc84fa69653ae4f31d9.squirrel@webmail-b.css.fujitsu.com>
	<20090605093420.0b208c33.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 5 Jun 2009 09:34:20 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > Sorry, I don't push this patch as this is. But adding documentation about
> > "What happens when you set memory.limit == memsw.limit" will be necessary.
> > 
> I agree.
> 
I'd like to prepare some.

> > ...maybe give all jobs to user-land and keep the kernel as it is now
> > is a good choice.
> > 
> > BTW, I'd like to avoid useless swap-out in memory.limit == memsw.limit case.
> > If someone has good idea, please :(
> > 
> I think so too.
> 
> From my simple thoughts, how about changing __mem_cgroup_try_charge() like:
> 
> 1. initialize "noswap" as "bool noswap = !!(mem->res.limit == mem->memsw.limit)".
> 2. add check "if (mem->res.limit == mem->memsw.limit)" on charge failure to mem->res
>    and set "noswap" to true if needed. 
> 3. charge mem->memsw before mem->res.
> 
> There would be other ideas, but I prefer 1 among these choices.
> 
ok, thank you for advices.

Regards,
-Kame


> 
> Thanks,
> Daisuke Nishimura.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
