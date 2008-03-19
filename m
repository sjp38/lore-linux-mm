Date: Wed, 19 Mar 2008 12:24:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/7] radix-tree page cgroup
Message-Id: <20080319122420.e5a13ed4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080319031445.GF24473@balbir.in.ibm.com>
References: <20080314185954.5cd51ff6.kamezawa.hiroyu@jp.fujitsu.com>
	<20080314191733.eff648f8.kamezawa.hiroyu@jp.fujitsu.com>
	<20080319031445.GF24473@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, xemul@openvz.org, "hugh@veritas.com" <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Mar 2008 08:44:45 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-03-14 19:17:33]:
> 
> > +		if (node_state(nid, N_NORMAL_MEMORY)
> 
> Small Typo - missing parenthesis
> 
ok...maybe magically fixed in my set...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
