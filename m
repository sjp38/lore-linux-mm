From: Christopher Lameter <cl@linux.com>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
Date: Thu, 7 Sep 2017 12:03:08 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1709071202290.20569@nuc-kabylake>
References: <20170905134412.qdvqcfhvbdzmarna@dhcp22.suse.cz> <20170905143021.GA28599@castle.dhcp.TheFacebook.com> <20170905151251.luh4wogjd3msfqgf@dhcp22.suse.cz> <20170905191609.GA19687@castle.dhcp.TheFacebook.com> <20170906084242.l4rcx6n3hdzxvil6@dhcp22.suse.cz>
 <20170906174043.GA12579@castle.DHCP.thefacebook.com> <alpine.DEB.2.10.1709061355001.70553@chino.kir.corp.google.com> <alpine.DEB.2.20.1709070939340.19539@nuc-kabylake> <20170907145239.GA19022@castle.DHCP.thefacebook.com> <alpine.DEB.2.20.1709071001580.19736@nuc-kabylake>
 <20170907164245.GA21177@castle.DHCP.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170907164245.GA21177@castle.DHCP.thefacebook.com>
Sender: linux-doc-owner@vger.kernel.org
To: Roman Gushchin <guro@fb.com>
Cc: David Rientjes <rientjes@google.com>, nzimmer@sgi.com, holt@sgi.com, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, sivanich@sgi.com
List-Id: linux-mm.kvack.org

On Thu, 7 Sep 2017, Roman Gushchin wrote:

> On Thu, Sep 07, 2017 at 10:03:24AM -0500, Christopher Lameter wrote:
> > On Thu, 7 Sep 2017, Roman Gushchin wrote:
> >
> > > > Really? From what I know and worked on way back when: The reason was to be
> > > > able to contain the affected application in a cpuset. Multiple apps may
> > > > have been running in multiple cpusets on a large NUMA machine and the OOM
> > > > condition in one cpuset should not affect the other. It also helped to
> > > > isolate the application behavior causing the oom in numerous cases.
> > > >
> > > > Doesnt this requirement transfer to cgroups in the same way?
> > >
> > > We have per-node memory stats and plan to use them during the OOM victim
> > > selection. Hopefully it can help.
> >
> > One of the OOM causes could be that memory was restricted to a certain
> > node set. Killing the allocating task is (was?) default behavior in that
> > case so that the task that has the restrictions is killed. Not any task
> > that may not have the restrictions and woiuld not experience OOM.
>
> As I can see, it's not the default behavior these days. If we have a way
> to select a victim between memcgs/tasks which are actually using
> the corresponding type of memory, it's much better than to kill
> an allocating task.

Kill the whole set of processes constituting an app in a cgroup or so
sounds good to me.
