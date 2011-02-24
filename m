Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 58CD08D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 02:06:07 -0500 (EST)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p1O765MH024497
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 23:06:05 -0800
Received: from pzk12 (pzk12.prod.google.com [10.243.19.140])
	by wpaz5.hot.corp.google.com with ESMTP id p1O763gD015805
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 23:06:04 -0800
Received: by pzk12 with SMTP id 12so56794pzk.1
        for <linux-mm@kvack.org>; Wed, 23 Feb 2011 23:06:03 -0800 (PST)
Date: Wed, 23 Feb 2011 23:05:59 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] cpuset: Add a missing unlock in cpuset_write_resmask()
In-Reply-To: <4D6601B2.1090207@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1102232305360.5816@chino.kir.corp.google.com>
References: <4D6601B2.1090207@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Menage <menage@google.com>, miaox@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 24 Feb 2011, Li Zefan wrote:

> Don't forget to release cgroup_mutex if alloc_trial_cpuset() fails.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
