Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 31C006B0036
	for <linux-mm@kvack.org>; Mon, 27 May 2013 12:20:02 -0400 (EDT)
Date: Mon, 27 May 2013 18:16:18 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom: add pending SIGKILL check for chosen victim
Message-ID: <20130527161618.GA804@redhat.com>
References: <20130423155638.GJ8001@dhcp22.suse.cz> <20130424145514.GA24997@redhat.com> <20130424152236.GB7600@dhcp22.suse.cz> <20130424154216.GA27929@redhat.com> <20130424123311.79614649c6a7951d9f8a39fe@linux-foundation.org> <20130425144955.GA26368@redhat.com> <20130425194118.51996d11baa4ed6b18e40e71@gmail.com> <20130425162237.GA31671@redhat.com> <20130502172022.GA8557@redhat.com> <20130527194915.493c1bed1de8f62e7e382164@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130527194915.493c1bed1de8f62e7e382164@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Dyasly <dserrg@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Sha Zhengju <handai.szj@taobao.com>

Hi Sergey,

Cough... I hoped that I will send at least some changes before another
reminder, but I am late again ;)

On 05/27, Sergey Dyasly wrote:
>
> Adding thread_head into task_struct->signal would be the best solution imho.
> This way list will be properly protected by rcu_read_lock(). But you called it
> "really painful". I guess that's because all users of while_each_thread(g, t)
> must be modified with 'g' pointing to the new thread_head. And I've counted
> 50 usages of while_each_thread() across the kernel.

Plus sometimes we need to iterate the group starting from non-leader.
And we need to keep both old/new lists before we convert all users,
and some other complications.

I hope I'll send some preparational patches today, I have already started
this (today ;).

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
