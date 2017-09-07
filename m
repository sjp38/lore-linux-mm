Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 28F6C6B0273
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 12:43:22 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y15so136103lfd.6
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 09:43:22 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 86si14080lja.480.2017.09.07.09.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Sep 2017 09:43:20 -0700 (PDT)
Date: Thu, 7 Sep 2017 17:42:45 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
Message-ID: <20170907164245.GA21177@castle.DHCP.thefacebook.com>
References: <20170905134412.qdvqcfhvbdzmarna@dhcp22.suse.cz>
 <20170905143021.GA28599@castle.dhcp.TheFacebook.com>
 <20170905151251.luh4wogjd3msfqgf@dhcp22.suse.cz>
 <20170905191609.GA19687@castle.dhcp.TheFacebook.com>
 <20170906084242.l4rcx6n3hdzxvil6@dhcp22.suse.cz>
 <20170906174043.GA12579@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.10.1709061355001.70553@chino.kir.corp.google.com>
 <alpine.DEB.2.20.1709070939340.19539@nuc-kabylake>
 <20170907145239.GA19022@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.20.1709071001580.19736@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1709071001580.19736@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, nzimmer@sgi.com, holt@sgi.com, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sivanich@sgi.com

On Thu, Sep 07, 2017 at 10:03:24AM -0500, Christopher Lameter wrote:
> On Thu, 7 Sep 2017, Roman Gushchin wrote:
> 
> > > Really? From what I know and worked on way back when: The reason was to be
> > > able to contain the affected application in a cpuset. Multiple apps may
> > > have been running in multiple cpusets on a large NUMA machine and the OOM
> > > condition in one cpuset should not affect the other. It also helped to
> > > isolate the application behavior causing the oom in numerous cases.
> > >
> > > Doesnt this requirement transfer to cgroups in the same way?
> >
> > We have per-node memory stats and plan to use them during the OOM victim
> > selection. Hopefully it can help.
> 
> One of the OOM causes could be that memory was restricted to a certain
> node set. Killing the allocating task is (was?) default behavior in that
> case so that the task that has the restrictions is killed. Not any task
> that may not have the restrictions and woiuld not experience OOM.

As I can see, it's not the default behavior these days. If we have a way
to select a victim between memcgs/tasks which are actually using
the corresponding type of memory, it's much better than to kill
an allocating task.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
