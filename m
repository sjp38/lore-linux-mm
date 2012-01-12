Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 2319C6B0068
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 22:48:58 -0500 (EST)
Received: by mail-qy0-f169.google.com with SMTP id d17so965582qcs.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 19:48:57 -0800 (PST)
Message-ID: <4F0E5827.7090603@gmail.com>
Date: Wed, 11 Jan 2012 22:48:55 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch 3/3] mm, oom: do not emit oom killer warning if chosen
 thread is already exiting
References: <alpine.DEB.2.00.1201111922500.3982@chino.kir.corp.google.com> <alpine.DEB.2.00.1201111924050.3982@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1201111924050.3982@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

(1/11/12 10:24 PM), David Rientjes wrote:
> If a thread is chosen for oom kill and is already PF_EXITING, then the
> oom killer simply sets TIF_MEMDIE and returns.  This allows the thread to
> have access to memory reserves so that it may quickly exit.  This logic
> is preceeded with a comment saying there's no need to alarm the sysadmin.
> This patch adds truth to that statement.
>
> There's no need to emit any warning about the oom condition if the thread
> is already exiting since it will not be killed.  In this condition, just
> silently return the oom killer since its only giving access to memory
> reserves and is otherwise a no-op.
>
> Signed-off-by: David Rientjes<rientjes@google.com>
> ---


Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
