Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 0407A6B0062
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 22:48:38 -0500 (EST)
Received: by qcsd17 with SMTP id d17so965582qcs.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 19:48:37 -0800 (PST)
Message-ID: <4F0E5813.2090708@gmail.com>
Date: Wed, 11 Jan 2012 22:48:35 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch 2/3] mm, oom: fold oom_kill_task into oom_kill_process
References: <alpine.DEB.2.00.1201111922500.3982@chino.kir.corp.google.com> <alpine.DEB.2.00.1201111923490.3982@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1201111923490.3982@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

(1/11/12 10:24 PM), David Rientjes wrote:
> oom_kill_task() has a single caller, so fold it into its parent function,
> oom_kill_process().  Slightly reduces the number of lines in the oom
> killer.
>
> Signed-off-by: David Rientjes<rientjes@google.com>

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
