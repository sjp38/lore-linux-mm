Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id E6E7E6B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 16:36:03 -0500 (EST)
Received: by iacb35 with SMTP id b35so11735117iac.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 13:36:03 -0800 (PST)
Date: Tue, 20 Dec 2011 13:36:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Android low memory killer vs. memory pressure notifications
In-Reply-To: <20111220145654.GA26881@oksana.dev.rtsoft.ru>
Message-ID: <alpine.DEB.2.00.1112201322170.22077@chino.kir.corp.google.com>
References: <20111219025328.GA26249@oksana.dev.rtsoft.ru> <20111219121255.GA2086@tiehlicka.suse.cz> <alpine.DEB.2.00.1112191110060.19949@chino.kir.corp.google.com> <20111220145654.GA26881@oksana.dev.rtsoft.ru>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton.vorontsov@linaro.org>
Cc: Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, =?UTF-8?Q?Arve_Hj=C3=B8nnev=C3=A5g?= <arve@android.com>, Rik van Riel <riel@redhat.com>, Pavel Machek <pavel@ucw.cz>, Greg Kroah-Hartman <gregkh@suse.de>, Andrew Morton <akpm@linux-foundation.org>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Tue, 20 Dec 2011, Anton Vorontsov wrote:

> Hm, assuming that metadata is no longer an issue, why do you think avoiding
> cgroups would be a good idea?
> 

It's helpful for certain end users, particularly those in the embedded 
world, to be able to disable as many config options as possible to reduce 
the size of kernel image as much as possible, so they'll want a minimal 
amount of kernel functionality that allows such notifications.  Keep in 
mind that CONFIG_CGROUP_MEM_RES_CTLR is not enabled by default because of 
this (enabling it, CONFIG_RESOURCE_COUNTERS, and CONFIG_CGROUPS increases 
the size of the kernel text by ~1%), and it's becoming increasingly 
important for certain workloads to be notified of low memory conditions 
without any restriction on its usage other than the amount of RAM that the 
system has so that they can trigger internal memory freeing, explicit 
memory compaction from the command line, drop caches, reducing scheduling 
priority, etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
