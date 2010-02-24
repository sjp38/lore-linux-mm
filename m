Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EED9B6B0047
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 07:17:23 -0500 (EST)
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp07.in.ibm.com (8.14.3/8.13.1) with ESMTP id o1OCHGYm028718
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 17:47:16 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1OCHGEp2785320
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 17:47:16 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1OCHFlo030193
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 23:17:16 +1100
Date: Wed, 24 Feb 2010 17:47:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 -mmotm 2/4] cgroups: remove events before destroying
 subsystem state objects
Message-ID: <20100224121711.GD2310@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1f8bd63acb6485c88f8539e009459a28fb6ad55b.1266853233.git.kirill@shutemov.name>
 <690745ebd257c74a1c47d552fec7fbb0b5efb7d0.1266853233.git.kirill@shutemov.name>
 <20100224084005.GC2310@balbir.in.ibm.com>
 <cc557aab1002240342u1b0223a4td8269d727b004621@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <cc557aab1002240342u1b0223a4td8269d727b004621@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* Kirill A. Shutemov <kirill@shutemov.name> [2010-02-24 13:42:15]:

> On Wed, Feb 24, 2010 at 10:40 AM, Balbir Singh
> <balbir@linux.vnet.ibm.com> wrote:
> > * Kirill A. Shutemov <kirill@shutemov.name> [2010-02-22 17:43:40]:
> >
> >> Events should be removed after rmdir of cgroup directory, but before
> >> destroying subsystem state objects. Let's take reference to cgroup
> >> directory dentry to do that.
> >>
> >> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> >> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hioryu@jp.fujitsu.com>
> >
> > Looks good, but remember the mem_cgroup data structure will can
> > disappear after the rmdir
> 
> IIUC, struct mem_cgroup can be freed only after ->destroy(), which can
> be called only if there is no references to cgroup directory dentry.
>

No.. You've got it right, it disappears after the last dput(). 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
