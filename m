Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 456308D0039
	for <linux-mm@kvack.org>; Sat, 19 Feb 2011 20:51:43 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p1K1pdaA006062
	for <linux-mm@kvack.org>; Sat, 19 Feb 2011 17:51:40 -0800
Received: from pvg2 (pvg2.prod.google.com [10.241.210.130])
	by wpaz9.hot.corp.google.com with ESMTP id p1K1ou8L020739
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 19 Feb 2011 17:51:38 -0800
Received: by pvg2 with SMTP id 2so173742pvg.39
        for <linux-mm@kvack.org>; Sat, 19 Feb 2011 17:51:38 -0800 (PST)
Date: Sat, 19 Feb 2011 17:51:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/4] cpuset: Hold callback_mutex in cpuset_clone()
In-Reply-To: <4D5C7F00.2050802@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1102191748400.27722@chino.kir.corp.google.com>
References: <4D5C7EA7.1030409@cn.fujitsu.com> <4D5C7F00.2050802@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, miaox@cn.fujitsu.com, linux-mm@kvack.org

On Thu, 17 Feb 2011, Li Zefan wrote:

> Chaning cpuset->mems/cpuset->cpus should be protected under
> callback_mutex.
> 
> cpuset_clone() doesn't follow this rule. It's ok because it's
> called when creating and initializing a cgroup, but we'd better
> hold the lock to avoid subtil break in the future.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
