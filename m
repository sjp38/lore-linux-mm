Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DDE6B6B00C8
	for <linux-mm@kvack.org>; Sat,  9 May 2009 12:55:23 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n49GwPMp023658
	for <linux-mm@kvack.org>; Sat, 9 May 2009 12:58:25 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n49GuDKq147314
	for <linux-mm@kvack.org>; Sat, 9 May 2009 12:56:13 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n49GuDwY009037
	for <linux-mm@kvack.org>; Sat, 9 May 2009 12:56:13 -0400
Date: Fri, 8 May 2009 20:16:25 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] add mem cgroup is activated check
Message-ID: <20090508144625.GB4630@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090508140528.c34ae712.kamezawa.hiroyu@jp.fujitsu.com> <20090508140713.e08827d8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090508140713.e08827d8.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-05-08 14:07:13]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> There is a function "mem_cgroup_disabled()" which returns
>   - memcg is configured ?
>   - disabled by boot option ?
> This is check is useful to confirm whether we have to call memcg's hook or not.
> 
> But, even when memcg is configured (and not disabled), it's not really used
> until mounted. This patch adds mem_cgroup_activated() to check memcg is
> mounted or not at least once.
> (Will be used in later patch.)
> 
> IIUC, only very careful users set boot option of memcg to be disabled and
> most of people will not be aware of that memcg is enabled at default.
> So, if memcg wants to affect to global VM behavior or to add some overheads,
> there are cases that this check is better than mem_cgroup_disabled().
>

Agreed
 
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
