Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 986588D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 01:20:07 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp04.au.ibm.com (8.14.4/8.13.1) with ESMTP id p1O6EZR7006790
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 17:14:35 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1O6K4Ba651438
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 17:20:04 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1O6K3xx008280
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 17:20:03 +1100
Date: Thu, 24 Feb 2011 11:49:31 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: more mem_cgroup_uncharge batching
Message-ID: <20110224061931.GO3379@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <alpine.LSU.2.00.1102232139560.2239@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1102232139560.2239@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishmura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

* Hugh Dickins <hughd@google.com> [2011-02-23 21:44:33]:

> It seems odd that truncate_inode_pages_range(), called not only when
> truncating but also when evicting inodes, has mem_cgroup_uncharge_start
> and _end() batching in its second loop to clear up a few leftovers, but
> not in its first loop that does almost all the work: add them there too.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---


Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
