Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF6B8D0039
	for <linux-mm@kvack.org>; Sat, 19 Feb 2011 20:51:41 -0500 (EST)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p1K1pV1J004062
	for <linux-mm@kvack.org>; Sat, 19 Feb 2011 17:51:32 -0800
Received: from pzk7 (pzk7.prod.google.com [10.243.19.135])
	by kpbe17.cbf.corp.google.com with ESMTP id p1K1pUpr023225
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 19 Feb 2011 17:51:30 -0800
Received: by pzk7 with SMTP id 7so174721pzk.22
        for <linux-mm@kvack.org>; Sat, 19 Feb 2011 17:51:30 -0800 (PST)
Date: Sat, 19 Feb 2011 17:51:27 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/4] cpuset: Remove unneeded NODEMASK_ALLOC() in
 cpuset_attch()
In-Reply-To: <4D5C7EBF.2070603@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1102191741270.27722@chino.kir.corp.google.com>
References: <4D5C7EA7.1030409@cn.fujitsu.com> <4D5C7EBF.2070603@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, miaox@cn.fujitsu.com, linux-mm@kvack.org

On Thu, 17 Feb 2011, Li Zefan wrote:

> oldcs->mems_allowed is not modified during cpuset_attch(), so
> we don't have to copy it to a buffer allocated by NODEMASK_ALLOC().
> Just pass it to cpuset_migrate_mm().
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
