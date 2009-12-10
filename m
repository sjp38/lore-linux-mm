Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 0286960021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 21:21:26 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp02.au.ibm.com (8.14.3/8.13.1) with ESMTP id nBA2Idsv000888
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 13:18:39 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBA2HaeW1724470
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 13:17:36 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBA2LKbT020968
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 13:21:21 +1100
Date: Thu, 10 Dec 2009 07:51:13 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] [23/31] HWPOISON: add memory cgroup filter
Message-ID: <20091210022113.GJ3722@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <200912081016.198135742@firstfloor.org>
 <20091208211639.8499FB151F@basil.firstfloor.org>
 <6599ad830912091247v1270a86er45ea8ceeff28e727@mail.gmail.com>
 <20091210014212.GI18989@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091210014212.GI18989@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Paul Menage <menage@google.com>, kosaki.motohiro@jp.fujitsu.com, hugh.dickins@tiscali.co.uk, nishimura@mxp.nes.nec.co.jp, kamezawa.hiroyu@jp.fujitsu.com, lizf@cn.fujitsu.com, npiggin@suse.de, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Andi Kleen <andi@firstfloor.org> [2009-12-10 02:42:12]:

> > While the functionality sounds useful, the interface (passing an inode
> > number) feels a bit ugly to me. Also, if that group is deleted and a
> > new cgroup created, you could end up reusing the inode number.
> 
> Please note this is just a testing interface, doesn't need to be
> 100% fool-proof. It'll never be used in production.
> 
> > 
> > How about an approach where you write either the cgroup path (relative
> > to the memcg mount) or an fd open on the desired cgroup? Then you
> > could store a (counted) css reference rather than an inode number,
> > which would make the filter function cleaner too, since it would just
> > need to compare css objects.
> 
> Sounds complicated, I assume it would be much more code?
> I would prefer to keep the testing interfaces as simple as possible.
>

We do this for cgroupstats and the code is not very complicated. In
case you want to look, the user space code is at
Documentation/accounting/getdelays.c and the kernel code is in
kernel/taskstats.c 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
