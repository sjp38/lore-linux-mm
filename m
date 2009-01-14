Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 37B146B004F
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 03:38:43 -0500 (EST)
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id n0E8cQWq020754
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 19:38:26 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0E8caTg057670
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 19:38:36 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n0E8cZmo000749
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 19:38:36 +1100
Date: Wed, 14 Jan 2009 14:08:35 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: fix return value of mem_cgroup_hierarchy_write()
Message-ID: <20090114083835.GL27129@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <496D9E0C.4060806@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <496D9E0C.4060806@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* Li Zefan <lizf@cn.fujitsu.com> [2009-01-14 16:10:52]:

> When there are sub-dirs, writing to memory.use_hierarchy returns -EBUSY,
> this doesn't seem to fit the meaning of EBUSY, and is inconsistent with
> memory.swappiness, which returns -EINVAL in this case.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

The patch does much more than the changelog says. The reason for EBUSY
is that the group is in use due to children or existing references and
tasks. I think EBUSY is the correct error code to return.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
