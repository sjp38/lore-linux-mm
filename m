Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 306FF6B0269
	for <linux-mm@kvack.org>; Thu,  2 May 2013 13:23:33 -0400 (EDT)
Date: Thu, 2 May 2013 19:20:22 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom: add pending SIGKILL check for chosen victim
Message-ID: <20130502172022.GA8557@redhat.com>
References: <20130422195138.GB31098@dhcp22.suse.cz> <20130423192614.c8621a7fe1b5b3e0a2ebf74a@gmail.com> <20130423155638.GJ8001@dhcp22.suse.cz> <20130424145514.GA24997@redhat.com> <20130424152236.GB7600@dhcp22.suse.cz> <20130424154216.GA27929@redhat.com> <20130424123311.79614649c6a7951d9f8a39fe@linux-foundation.org> <20130425144955.GA26368@redhat.com> <20130425194118.51996d11baa4ed6b18e40e71@gmail.com> <20130425162237.GA31671@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130425162237.GA31671@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Dyasly <dserrg@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Sha Zhengju <handai.szj@taobao.com>

Just to let you know that this time I didn't forget about this problem ;)

On 04/25, Oleg Nesterov wrote:
>
> On 04/25, Sergey Dyasly wrote:
> >
> > But in general case there is still a race,
>
> Yes. Every while_each_thread() in oom-kill is wrong, and I am still not
> sure what should/can we do. Will try to think more.

And I still can't find a simple/clean solution.

OK. I am starting to think we should probably switch to Plan B. We can add
thread_head into task_struct->signal and convert while_each_thread() into
list_for_each_rcu(). This should work, but this is really painful and I was
going to avoid this as much as possible...

I'll try to do something once I return from vacation (May 9). Heh, See also
http://marc.info/?l=linux-kernel&m=127688978121665 and the whole thread.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
