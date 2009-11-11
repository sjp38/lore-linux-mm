Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8063D6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 23:25:50 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp06.au.ibm.com (8.14.3/8.13.1) with ESMTP id nAB4ObXI027007
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 15:24:37 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAB4LgtT1662978
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 15:21:42 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAB4Ooex006340
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 15:24:50 +1100
Date: Wed, 11 Nov 2009 09:54:48 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 1/3] memcg: add mem_cgroup_cancel_charge()
Message-ID: <20091111042448.GG3314@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
 <20091111103533.c634ff8d.nishimura@mxp.nes.nec.co.jp>
 <20091111103649.e40e0e60.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091111103649.e40e0e60.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2009-11-11 10:36:49]:

> There are some places calling both res_counter_uncharge() and css_put()
> to cancel the charge and the refcnt we have got by mem_cgroup_tyr_charge().
> 
> This patch introduces mem_cgroup_cancel_charge() and call it in those places.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>


Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 
-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
