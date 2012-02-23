Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id A37F06B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 12:20:41 -0500 (EST)
Message-ID: <4F467579.3020509@jp.fujitsu.com>
Date: Thu, 23 Feb 2012 12:20:57 -0500
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, oom: force oom kill on sysrq+f
References: <alpine.DEB.2.00.1202221602380.5980@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1202221602380.5980@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org

On 2/22/2012 7:03 PM, David Rientjes wrote:
> The oom killer chooses not to kill a thread if:
> 
>  - an eligible thread has already been oom killed and has yet to exit,
>    and
> 
>  - an eligible thread is exiting but has yet to free all its memory and
>    is not the thread attempting to currently allocate memory.
> 
> SysRq+F manually invokes the global oom killer to kill a memory-hogging
> task.  This is normally done as a last resort to free memory when no
> progress is being made or to test the oom killer itself.
> 
> For both uses, we always want to kill a thread and never defer.  This
> patch causes SysRq+F to always kill an eligible thread and can be used to
> force a kill even if another oom killed thread has failed to exit.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

I have similar patch. This is very sane idea.
	Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
