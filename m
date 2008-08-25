Date: Mon, 25 Aug 2008 12:19:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/14] memcg: unlimted root cgroup
Message-Id: <20080825121931.2bd134b4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1409530.1219451890296.kamezawa.hiroyu@jp.fujitsu.com>
References: <48AF42DC.7020705@linux.vnet.ibm.com>
	<20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
	<20080822203025.eb4b2ec3.kamezawa.hiroyu@jp.fujitsu.com>
	<1409530.1219451890296.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Sat, 23 Aug 2008 09:38:10 +0900 (JST)
kamezawa.hiroyu@jp.fujitsu.com wrote:
> >Is this a generic implementation to support no limits? If not, why not store 
> the
> >root memory controller pointer and see if someone is trying to set a limit on
>  that?
> >
> Just because I designed this for supporting trash-box and changed my mind..
> Sorry. If pointer comparison is better, I'll do that.
> 
I decieded to use follwoing macro instead of memcg->no_limit.

#define is_root_cgroup(cgrp)	((cgrp) == &init_mem_cgroup)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
