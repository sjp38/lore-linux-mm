Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 69DF48D0039
	for <linux-mm@kvack.org>; Sat, 19 Feb 2011 20:51:34 -0500 (EST)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p1K1pSRQ006073
	for <linux-mm@kvack.org>; Sat, 19 Feb 2011 17:51:28 -0800
Received: from pxi17 (pxi17.prod.google.com [10.243.27.17])
	by wpaz29.hot.corp.google.com with ESMTP id p1K1pQxt014389
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 19 Feb 2011 17:51:27 -0800
Received: by pxi17 with SMTP id 17so699903pxi.39
        for <linux-mm@kvack.org>; Sat, 19 Feb 2011 17:51:26 -0800 (PST)
Date: Sat, 19 Feb 2011 17:51:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/4] cpuset: Remove unneeded NODEMASK_ALLOC() in
 cpuset_sprintf_memlist()
In-Reply-To: <4D5C7EA7.1030409@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1102191739200.27722@chino.kir.corp.google.com>
References: <4D5C7EA7.1030409@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, miaox@cn.fujitsu.com, linux-mm@kvack.org

On Thu, 17 Feb 2011, Li Zefan wrote:

> It's not necessary to copy cpuset->mems_allowed to a buffer
> allocated by NODEMASK_ALLOC(). Just pass it to nodelist_scnprintf().
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
