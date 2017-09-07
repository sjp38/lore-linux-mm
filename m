Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 410606B0320
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 17:56:00 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 6so1576225pgh.0
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 14:56:00 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u205sor337257pgb.145.2017.09.07.14.55.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Sep 2017 14:55:58 -0700 (PDT)
Date: Thu, 7 Sep 2017 14:55:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
In-Reply-To: <alpine.DEB.2.20.1709070939340.19539@nuc-kabylake>
Message-ID: <alpine.DEB.2.10.1709071454220.141461@chino.kir.corp.google.com>
References: <20170904142108.7165-1-guro@fb.com> <20170904142108.7165-6-guro@fb.com> <20170905134412.qdvqcfhvbdzmarna@dhcp22.suse.cz> <20170905143021.GA28599@castle.dhcp.TheFacebook.com> <20170905151251.luh4wogjd3msfqgf@dhcp22.suse.cz>
 <20170905191609.GA19687@castle.dhcp.TheFacebook.com> <20170906084242.l4rcx6n3hdzxvil6@dhcp22.suse.cz> <20170906174043.GA12579@castle.DHCP.thefacebook.com> <alpine.DEB.2.10.1709061355001.70553@chino.kir.corp.google.com>
 <alpine.DEB.2.20.1709070939340.19539@nuc-kabylake>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Roman Gushchin <guro@fb.com>, nzimmer@sgi.com, holt@sgi.com, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sivanich@sgi.com

On Thu, 7 Sep 2017, Christopher Lameter wrote:

> > SGI required it when it was introduced simply to avoid the very expensive
> > tasklist scan.  Adding Christoph Lameter to the cc since he was involved
> > back then.
> 
> Really? From what I know and worked on way back when: The reason was to be
> able to contain the affected application in a cpuset. Multiple apps may
> have been running in multiple cpusets on a large NUMA machine and the OOM
> condition in one cpuset should not affect the other. It also helped to
> isolate the application behavior causing the oom in numerous cases.
> 
> Doesnt this requirement transfer to cgroups in the same way?
> 
> Left SGI in 2008 so adding Dimitri who may know about the current
> situation. Robin Holt also left SGI as far as I know.
> 

It may have been Paul Jackson, but I remember the oom_kill_allocating_task 
knob being required due to very slow oom killer due to the very lengthy 
iteration of the tasklist.  It would be helpful if someone from SGI could 
confirm whether or not they actively use this sysctl.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
