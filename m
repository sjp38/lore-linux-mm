From: Christopher Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
Date: Thu, 7 Sep 2017 10:03:24 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1709071001580.19736@nuc-kabylake>
References: <20170904142108.7165-1-guro@fb.com> <20170904142108.7165-6-guro@fb.com> <20170905134412.qdvqcfhvbdzmarna@dhcp22.suse.cz> <20170905143021.GA28599@castle.dhcp.TheFacebook.com> <20170905151251.luh4wogjd3msfqgf@dhcp22.suse.cz>
 <20170905191609.GA19687@castle.dhcp.TheFacebook.com> <20170906084242.l4rcx6n3hdzxvil6@dhcp22.suse.cz> <20170906174043.GA12579@castle.DHCP.thefacebook.com> <alpine.DEB.2.10.1709061355001.70553@chino.kir.corp.google.com> <alpine.DEB.2.20.1709070939340.19539@nuc-kabylake>
 <20170907145239.GA19022@castle.DHCP.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170907145239.GA19022-B3w7+ongkCiLfgCeKHXN1g2O0Ztt9esIQQ4Iyu8u01E@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Roman Gushchin <guro-b10kYP2dOMg@public.gmane.org>
Cc: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, nzimmer-sJ/iWh9BUns@public.gmane.org, holt-sJ/iWh9BUns@public.gmane.org, Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Vladimir Davydov <vdavydov.dev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, kernel-team-b10kYP2dOMg@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sivanich-sJ/iWh9BUns@public.gmane.org
List-Id: linux-mm.kvack.org

On Thu, 7 Sep 2017, Roman Gushchin wrote:

> > Really? From what I know and worked on way back when: The reason was to be
> > able to contain the affected application in a cpuset. Multiple apps may
> > have been running in multiple cpusets on a large NUMA machine and the OOM
> > condition in one cpuset should not affect the other. It also helped to
> > isolate the application behavior causing the oom in numerous cases.
> >
> > Doesnt this requirement transfer to cgroups in the same way?
>
> We have per-node memory stats and plan to use them during the OOM victim
> selection. Hopefully it can help.

One of the OOM causes could be that memory was restricted to a certain
node set. Killing the allocating task is (was?) default behavior in that
case so that the task that has the restrictions is killed. Not any task
that may not have the restrictions and woiuld not experience OOM.
