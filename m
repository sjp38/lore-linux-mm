Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B1AFE6B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 02:13:39 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp09.au.ibm.com (8.14.3/8.13.1) with ESMTP id o1OID2tI006400
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 05:13:02 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1O77bJc1667178
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 18:07:37 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1O7D1kj000977
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 18:13:02 +1100
Date: Wed, 24 Feb 2010 12:42:58 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 -mmotm 1/4] cgroups: Fix race between userspace and
 kernelspace
Message-ID: <20100224071258.GB2310@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* Kirill A. Shutemov <kirill@shutemov.name> [2010-02-22 17:43:39]:

> eventfd are used to notify about two types of event:
>  - control file-specific, like crossing memory threshold;
>  - cgroup removing.
> 
> To understand what really happen, userspace can check if the cgroup
> still exists. To avoid race beetween userspace and kernelspace we have
> to notify userspace about cgroup removing only after rmdir of cgroup
> directory.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

That does make sense, looks good to me. You've already got the
necessary acks.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
