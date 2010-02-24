Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AD6CE6B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 03:40:15 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp08.in.ibm.com (8.14.3/8.13.1) with ESMTP id o1O7vqaQ017739
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 13:27:52 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1O8e9Qf3133692
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 14:10:10 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1O8e8pJ014948
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 19:40:09 +1100
Date: Wed, 24 Feb 2010 14:10:05 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 -mmotm 2/4] cgroups: remove events before destroying
 subsystem state objects
Message-ID: <20100224084005.GC2310@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name>
 <690745ebd257c74a1c47d552fec7fbb0b5efb7d0.1266853233.git.kirill@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <690745ebd257c74a1c47d552fec7fbb0b5efb7d0.1266853233.git.kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* Kirill A. Shutemov <kirill@shutemov.name> [2010-02-22 17:43:40]:

> Events should be removed after rmdir of cgroup directory, but before
> destroying subsystem state objects. Let's take reference to cgroup
> directory dentry to do that.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>

Looks good, but remember the mem_cgroup data structure will can
disappear after the rmdir

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
