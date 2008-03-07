Date: Thu, 6 Mar 2008 21:14:26 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Add cgroup support for enabling controllers at boot
 time
In-Reply-To: <47D0C76D.8050207@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.1.00.0803062111560.26462@chino.kir.corp.google.com>
References: <20080306185952.23290.49571.sendpatchset@localhost.localdomain> <alpine.DEB.1.00.0803061108370.13110@chino.kir.corp.google.com> <47D0C76D.8050207@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Paul Menage <menage@google.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Balbir Singh wrote:

> >> +static int __init cgroup_disable(char *str)
> >> +{
> >> +	int i;
> >> +	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
> >> +		struct cgroup_subsys *ss = subsys[i];
> >> +		if (!strcmp(str, ss->name)) {
> >> +			ss->disabled = 1;
> >> +			break;
> >> +		}
> >> +	}
> >> +}
> >> +__setup("cgroup_disable=", cgroup_disable);
> > 
> > This doesn't handle spaces very well, so isn't it possible for the name of 
> > a current or future cgroup subsystem to be specified after cgroup_disable= 
> > on the command line and have it disabled by accident?
> > 
> 
> How do you distinguish that from the user wanting to disable the controller on
> purpose? My understanding is that after parsing cgroup_disable=, the rest of the
> text is passed to cgroup_disable to process further. You'll find that all the
> __setup() code in the kernel is implemented this way.
> 

Since the command line is logically delimited by spaces, you can 
accidently disable a subsystem if its name appears in any of your kernel 
options following your cgroup_disable= option.  So if you're absolutely 
confident that it wouldn't happen (for instance, if there's no logical 
reason that a cgroup subsystem name should appear anywhere besides 
cgroup_disable on the command line), then there's no objection.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
