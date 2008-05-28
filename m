Date: Wed, 28 May 2008 09:12:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC 1/4] memcg: drop pages at rmdir (v1)
Message-Id: <20080528091237.f6bf2745.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <483C32AE.1020908@linux.vnet.ibm.com>
References: <20080527140116.fb04b06b.kamezawa.hiroyu@jp.fujitsu.com>
	<20080527140533.b4b6f73f.kamezawa.hiroyu@jp.fujitsu.com>
	<483C32AE.1020908@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 27 May 2008 21:41:26 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > Now, when we remove memcg, we call force_empty().
> > This call drops all page_cgroup accounting in this mem_cgroup but doesn't
> > drop pages. So, some page caches can be remaind as "not accounted" memory
> > while they are alive. (because it's accounted only when add_to_page_cache())
> > If they are not used by other memcg, global LRU will drop them.
> > 
> > This patch tries to drop pages at removing memcg. Other memcg will
> > reload and re-account page caches. (but this will increase page-in
> > after rmdir().)
> > 
> 
> The approach seems fair, but I am not sure about the overhead of flushing out
> cached pages. Might well be worth it.
> 
> > Consideration: should we recharge all pages to the parent at last ?
> >                But it's not precise logic.
> > 
> 
> We should look into this - I should send out the multi-hierarchy patches soon.
Yes. I'll write my version (if I can). please pick it up if you like it.

> We should discuss this after that.
>
ok. I'd like to forget this patch for a while.

Thanks,
-Kame 






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
