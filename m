Subject: Re: [RFC][PATCH] another swap controller for cgroup
In-Reply-To: Your message of "Thu, 15 May 2008 21:01:53 +0900"
	<482C2631.1030600@mxp.nes.nec.co.jp>
References: <482C2631.1030600@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080519041457.980625A07@siro.lan>
Date: Mon, 19 May 2008 13:14:57 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nishimura@mxp.nes.nec.co.jp
Cc: minoura@valinux.co.jp, linux-mm@kvack.org, containers@lists.osdl.org, hugh@veritas.com, menage@google.com, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

> > deterministic in the sense that, even when two or more processes
> > from different cgroups are sharing a page, both of them, rather than
> > only unlucky one, are always charged.
> > 
> 
> I'm not sure whether this behavior itself is good or bad,
> but I think it's not good idea to make memory controller,
> which charges only one process for a shared page,
> and swap controller behave differently.
> I think it will be confusing for users. At least,
> I would feel it strange.

i agree that yours can be better integrated with the memory controller. 

unlike yours, mine was designed to be independent from
the memory controller as far as possible.
(i don't want to complicate the memory controller.)

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
