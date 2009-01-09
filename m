Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A40B86B0044
	for <linux-mm@kvack.org>; Fri,  9 Jan 2009 00:35:03 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id n095Yw81017054
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 11:04:58 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n095XHPt4346072
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 11:03:17 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n095Ytl1030957
	for <linux-mm@kvack.org>; Fri, 9 Jan 2009 16:34:57 +1100
Date: Fri, 9 Jan 2009 11:04:58 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 3/4] memcg: fix for mem_cgroup_hierarchical_reclaim
Message-ID: <20090109053458.GE9737@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090108190818.b663ce20.nishimura@mxp.nes.nec.co.jp> <20090108191501.dc469a51.nishimura@mxp.nes.nec.co.jp> <39822.10.75.179.62.1231412881.squirrel@webmail-b.css.fujitsu.com> <20090109100830.3e9c90e0.kamezawa.hiroyu@jp.fujitsu.com> <20090109115103.e17b18f2.nishimura@mxp.nes.nec.co.jp> <20090109120950.09f55ce5.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090109120950.09f55ce5.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, menage@google.com
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-09 12:09:50]:

> Ok, please go ahead.
> 
> Maybe create a patch agains "rc1" is better for all your fixes.
> And please ask Andrew to "This is a bugfix and please put into fast-path" 
> 
> -Kame 
>

Agreed and we'll test it thoroughly meanwhile! 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
