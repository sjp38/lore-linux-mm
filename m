Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4191C6B01AF
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 19:18:24 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o53NIJso017597
	for <linux-mm@kvack.org>; Thu, 3 Jun 2010 16:18:19 -0700
Received: from pvf33 (pvf33.prod.google.com [10.241.210.97])
	by kpbe18.cbf.corp.google.com with ESMTP id o53NIHA9022922
	for <linux-mm@kvack.org>; Thu, 3 Jun 2010 16:18:17 -0700
Received: by pvf33 with SMTP id 33so343285pvf.31
        for <linux-mm@kvack.org>; Thu, 03 Jun 2010 16:18:16 -0700 (PDT)
Date: Thu, 3 Jun 2010 16:18:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 08/12] oom: dump_tasks() use find_lock_task_mm() too
In-Reply-To: <20100603220103.GA8511@redhat.com>
Message-ID: <alpine.DEB.2.00.1006031617070.30302@chino.kir.corp.google.com>
References: <20100603135106.7247.A69D9226@jp.fujitsu.com> <20100603152350.725F.A69D9226@jp.fujitsu.com> <20100603152652.GA8743@redhat.com> <alpine.DEB.2.00.1006031312130.10856@chino.kir.corp.google.com> <20100603220103.GA8511@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Fri, 4 Jun 2010, Oleg Nesterov wrote:

> On 06/03, David Rientjes wrote:
> >
> > On Thu, 3 Jun 2010, Oleg Nesterov wrote:
> >
> > > (off-topic)
> > >
> > > out_of_memory() calls dump_header()->dump_tasks() lockless, we
> > > need tasklist.
> 
> forgot to mention, __out_of_memory() too.
> 
> > Already fixed in my rewrite patchset, as most of these things are.  Sigh.
> 
> In 3/18, without any note in the changelog. Another minor thing
> which can be fixed before rewrite.
> 

It's _not_ rc material, we don't merge patches into rc kernels where the 
end result is panic() in all cases anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
