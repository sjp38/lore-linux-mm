Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 10B376B003D
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 07:38:49 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id o07CcjBn013433
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 18:08:45 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o07CcjF63543186
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 18:08:45 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o07Cci99020420
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 23:38:44 +1100
Date: Thu, 7 Jan 2010 18:08:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: How should we handle CONFIG_CGROUP_MEM_RES_CTRL_SWAP (Re: [PATCH
 -mmotm] build fix for memcg-move-charges-of-anonymous-swap.patch)
Message-ID: <20100107123841.GX3059@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100106171058.f1d6f393.randy.dunlap@oracle.com>
 <20100107111319.7d95fe86.nishimura@mxp.nes.nec.co.jp>
 <20100107112150.2e585f1c.kamezawa.hiroyu@jp.fujitsu.com>
 <20100107115901.594330d0.nishimura@mxp.nes.nec.co.jp>
 <20100107120233.f244d4b7.kamezawa.hiroyu@jp.fujitsu.com>
 <20100107130609.31fe83dc.nishimura@mxp.nes.nec.co.jp>
 <20100107133026.6350bd9d.kamezawa.hiroyu@jp.fujitsu.com>
 <20100107141401.6a182085.nishimura@mxp.nes.nec.co.jp>
 <20100107145223.a73e2be9.kamezawa.hiroyu@jp.fujitsu.com>
 <20100107202335.c18b728b.d-nishimura@mtf.biglobe.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100107202335.c18b728b.d-nishimura@mtf.biglobe.ne.jp>
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> [2010-01-07 20:23:35]:

> (Changed the subject and Cc list)
> 
> On Thu, 7 Jan 2010 14:52:23 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > BTW, maybe it's time to
> >   - remove EXPERIMENTAL from CONFIG_CGROUP_MEM_RES_CTRL_SWAP
> > and more,
> >   - remove CONFIG_CGROUP_MEM_RES_CTRL_SWAP
> >     (to reduce complicated #ifdefs and replace them with CONFIG_SWAP.)
> > 
> > It's very stable as far as I test.
> > 
> I agree on both.
> 
> Balbir-san, What do you think ?
>

I agree, the experimental marking can go and CONFIG_SWAP can replace
the current config option. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
