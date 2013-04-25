Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 7B4C46B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 12:25:37 -0400 (EDT)
Date: Thu, 25 Apr 2013 18:22:37 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom: add pending SIGKILL check for chosen victim
Message-ID: <20130425162237.GA31671@redhat.com>
References: <1366643184-3627-1-git-send-email-dserrg@gmail.com> <20130422195138.GB31098@dhcp22.suse.cz> <20130423192614.c8621a7fe1b5b3e0a2ebf74a@gmail.com> <20130423155638.GJ8001@dhcp22.suse.cz> <20130424145514.GA24997@redhat.com> <20130424152236.GB7600@dhcp22.suse.cz> <20130424154216.GA27929@redhat.com> <20130424123311.79614649c6a7951d9f8a39fe@linux-foundation.org> <20130425144955.GA26368@redhat.com> <20130425194118.51996d11baa4ed6b18e40e71@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130425194118.51996d11baa4ed6b18e40e71@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Dyasly <dserrg@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Sha Zhengju <handai.szj@taobao.com>

On 04/25, Sergey Dyasly wrote:
>
> But in general case there is still a race,

Yes. Every while_each_thread() in oom-kill is wrong, and I am still not
sure what should/can we do. Will try to think more.

You know, partly this is the known problem. while_each_thread(g,t) is not
safe lockless unless g is the main thread. And another bug is that even
if it is the main thread it can race with exec. The 2nd problem should be
fixed, but when we discussed this previously we were going to disallow
the lockless while_each_thread(sub_thread)...

And yes, I missed these problems when we discussed 6b0c81b3 :/


> Still, I think that fatal_signal_pending() is a sensible check, since the one
> for current task is already there, and there is a patch from David Rientjes
> that does almost the same [1].

Oh, I can't comment this. I leave this to you and David.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
