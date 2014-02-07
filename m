Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9CF746B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 12:56:45 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id f8so1093144wiw.7
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 09:56:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id g15si1856353wiw.22.2014.02.07.09.56.43
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 09:56:44 -0800 (PST)
Message-ID: <52F51E19.9000406@redhat.com>
Date: Fri, 07 Feb 2014 12:55:37 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] drop_caches: add some documentation and info message
References: <1391794851-11412-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1391794851-11412-1-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave@sr71.net>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 02/07/2014 12:40 PM, Johannes Weiner wrote:

> @@ -59,6 +60,9 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
>   	if (ret)
>   		return ret;
>   	if (write) {
> +		printk_ratelimited(KERN_INFO "%s (%d): dropped kernel caches: %d\n",
> +				   current->comm, task_pid_nr(current),
> +				   sysctl_drop_caches);
>   		if (sysctl_drop_caches & 1)
>   			iterate_supers(drop_pagecache_sb, NULL);
>   		if (sysctl_drop_caches & 2)
>

Would it be better to print this after the operation
has completed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
