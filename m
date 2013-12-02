Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f51.google.com (mail-vb0-f51.google.com [209.85.212.51])
	by kanga.kvack.org (Postfix) with ESMTP id 743BC6B0031
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 18:09:47 -0500 (EST)
Received: by mail-vb0-f51.google.com with SMTP id m10so8904246vbh.24
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 15:09:47 -0800 (PST)
Received: from mail-yh0-x235.google.com (mail-yh0-x235.google.com [2607:f8b0:4002:c01::235])
        by mx.google.com with ESMTPS id vi1si29422914vcb.94.2013.12.02.15.09.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 15:09:46 -0800 (PST)
Received: by mail-yh0-f53.google.com with SMTP id b20so9555372yha.12
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 15:09:46 -0800 (PST)
Date: Mon, 2 Dec 2013 15:09:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: user defined OOM policies
In-Reply-To: <20131128114214.GJ2761@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1312021508060.13465@chino.kir.corp.google.com>
References: <20131119131400.GC20655@dhcp22.suse.cz> <20131119134007.GD20655@dhcp22.suse.cz> <alpine.DEB.2.02.1311192352070.20752@chino.kir.corp.google.com> <20131120152251.GA18809@dhcp22.suse.cz> <CAA25o9S5EQBvyk=HP3obdCaXKjoUVtzeb4QsNmoLMq6NnOYifA@mail.gmail.com>
 <alpine.DEB.2.02.1311201933420.7167@chino.kir.corp.google.com> <CAA25o9Q64eK5LHhrRyVn73kFz=Z7Jji=rYWS=9jWL_4y9ZGbQA@mail.gmail.com> <alpine.DEB.2.02.1311251717370.27270@chino.kir.corp.google.com> <20131128114214.GJ2761@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Joern Engel <joern@logfs.org>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, 28 Nov 2013, Michal Hocko wrote:

> > We already have hooks in the kernel oom killer, things like 
> > /proc/sys/vm/oom_kill_allocating_task
> 
> How would you implement oom_kill_allocating_task in userspace? You do
> not have any context on who is currently allocating or would you rely on
> reading /proc/*/stack to grep for allocation functions?
> 

Not the exact behavior, sorry.  I implemented oom_kill_allocating_task at 
the request for SGI that simply wanted to avoid the lengthy tasklist scan, 
they don't actually care what is killed as long as something is killed.  
The actual allocating task is difficult to predict, especially in system 
oom conditions, and their motivation was to make it as quickly as 
possible.  Userspace could certainly kill a random eligible process :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
