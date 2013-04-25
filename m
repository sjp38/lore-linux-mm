Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id EA3F46B0002
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 11:41:23 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id fh20so2701561lab.24
        for <linux-mm@kvack.org>; Thu, 25 Apr 2013 08:41:22 -0700 (PDT)
Date: Thu, 25 Apr 2013 19:41:18 +0400
From: Sergey Dyasly <dserrg@gmail.com>
Subject: Re: [PATCH] oom: add pending SIGKILL check for chosen victim
Message-Id: <20130425194118.51996d11baa4ed6b18e40e71@gmail.com>
In-Reply-To: <20130425144955.GA26368@redhat.com>
References: <1366643184-3627-1-git-send-email-dserrg@gmail.com>
	<20130422195138.GB31098@dhcp22.suse.cz>
	<20130423192614.c8621a7fe1b5b3e0a2ebf74a@gmail.com>
	<20130423155638.GJ8001@dhcp22.suse.cz>
	<20130424145514.GA24997@redhat.com>
	<20130424152236.GB7600@dhcp22.suse.cz>
	<20130424154216.GA27929@redhat.com>
	<20130424123311.79614649c6a7951d9f8a39fe@linux-foundation.org>
	<20130425144955.GA26368@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Sha Zhengju <handai.szj@taobao.com>

On Thu, 25 Apr 2013 16:49:55 +0200
Oleg Nesterov <oleg@redhat.com> wrote:

> On 04/24, Andrew Morton wrote:
> >
> > Where does this leave us with Sergey's patch?  "Still good, but
> > requires new changelog"?
> 
> Sergey is certainly right, this needs the fixes (thanks Sergey!).
> 
> But afaics the patch can't help, we need another solution.
> 
> Oleg.
> 

Oleg, thanks for your comments!

Indeed, my patch is intended for one particular case (OOM killer and
threadgroups). But in general case there is still a race, so my patch
should be reworked.

Still, I think that fatal_signal_pending() is a sensible check, since the one
for current task is already there, and there is a patch from David Rientjes
that does almost the same [1]. So maybe it's a general condition for not
invoking OOM killer but just setting TIF_MEMDIE for a task?

[1] - http://www.spinics.net/lists/linux-mm/msg54662.html

-- 
Sergey Dyasly <dserrg@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
