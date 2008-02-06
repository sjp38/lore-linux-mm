Date: Tue, 5 Feb 2008 18:05:46 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] badness() dramatically overcounts memory
In-Reply-To: <20080206105041.2717.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.00.0802051802460.18339@chino.kir.corp.google.com>
References: <1202252561.24634.64.camel@dogma.ljc.laika.com> <alpine.DEB.1.00.0802051507460.18347@chino.kir.corp.google.com> <20080206105041.2717.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Jeff Davis <linux@j-davis.com>, balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <andrea@qumranet.com>
List-ID: <linux-mm.kvack.org>

On Wed, 6 Feb 2008, KOSAKI Motohiro wrote:

> > Andrea Arcangeli has patches pending which change this to the RSS.  
> > Specifically:
> > 
> > 	http://marc.info/?l=linux-mm&m=119977937126925
> 
> I agreed with you that RSS is better :)
> 
> 
> 
> but..
> on many node numa, per zone rss is more better..
> 

It depends on how your applications are taking advantage of NUMA 
optimizations.  If they're constrained by mempolicies to a subset of nodes 
then the badness scoring isn't even used: the task that triggered the OOM 
condition is the one that is automatically killed.

At this point, I think you're going to need to present an actual case 
study where Andrea's patch isn't sufficient for selecting the appropriate 
task on large NUMA machines.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
