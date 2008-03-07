Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id m27CQuqE017000
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 04:26:56 -0800
Received: from py-out-1112.google.com (pygy77.prod.google.com [10.34.226.77])
	by zps18.corp.google.com with ESMTP id m27CQtBq000468
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 04:26:56 -0800
Received: by py-out-1112.google.com with SMTP id y77so585701pyg.28
        for <linux-mm@kvack.org>; Fri, 07 Mar 2008 04:26:55 -0800 (PST)
Message-ID: <6599ad830803070426l22d78446t588691dedeeb490b@mail.gmail.com>
Date: Fri, 7 Mar 2008 04:26:53 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] Add cgroup support for enabling controllers at boot time (v2)
In-Reply-To: <6599ad830803070125o1ebfd7d1r728cdadf726ecbe2@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080307085735.25567.314.sendpatchset@localhost.localdomain>
	 <6599ad830803070125o1ebfd7d1r728cdadf726ecbe2@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 7, 2008 at 1:25 AM, Paul Menage <menage@google.com> wrote:
>
>  Doesn't this mean that cgroup_disable=cpu will disable whichever comes
>  first out of cpuset, cpuacct or cpu in the subsystem list?

Or rather, it's the other way around - cgroup_disable=cpuset will
instead disable the "cpu" subsystem if "cpu" comes before "cpuset" in
the subsystem list.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
