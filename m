Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m56GOI1Q009567
	for <linux-mm@kvack.org>; Sat, 7 Jun 2008 02:24:18 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m56GOjmb4640924
	for <linux-mm@kvack.org>; Sat, 7 Jun 2008 02:24:46 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m56GP2I2007492
	for <linux-mm@kvack.org>; Sat, 7 Jun 2008 02:25:03 +1000
Message-ID: <484964D6.8060108@linux.vnet.ibm.com>
Date: Fri, 06 Jun 2008 21:54:54 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: memcg: bad page at page migration
References: <20080606221124.623847aa.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20080606221124.623847aa.nishimura@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, xemul@openvz.org, lizf@cn.fujitsu.com, yamamoto@valinux.co.jp, hugh@veritas.com, minchan.kim@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> 
> All the logs I've seen include the line "cgroup:*******", so it seems that
> page->page_cgroup is not cleared.
> 
> Do you have any ideas?
> 

As you've already mentioned, this problem is not reproducible in mainline (I
tried with 2.6.26-rc4). I should also try against mmotm

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
