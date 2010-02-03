Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B72806B004D
	for <linux-mm@kvack.org>; Tue,  2 Feb 2010 21:12:48 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id o132Ckhr023441
	for <linux-mm@kvack.org>; Tue, 2 Feb 2010 18:12:46 -0800
Received: from pzk38 (pzk38.prod.google.com [10.243.19.166])
	by kpbe20.cbf.corp.google.com with ESMTP id o132Ci2X021480
	for <linux-mm@kvack.org>; Tue, 2 Feb 2010 18:12:45 -0800
Received: by pzk38 with SMTP id 38so913926pzk.9
        for <linux-mm@kvack.org>; Tue, 02 Feb 2010 18:12:44 -0800 (PST)
Date: Tue, 2 Feb 2010 18:12:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Improving OOM killer
In-Reply-To: <20100203105236.b4a60754.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1002021809220.15327@chino.kir.corp.google.com>
References: <201002012302.37380.l.lunak@suse.cz> <alpine.DEB.2.00.1002011523280.19457@chino.kir.corp.google.com> <201002022210.06760.l.lunak@suse.cz> <alpine.DEB.2.00.1002021643240.3393@chino.kir.corp.google.com>
 <20100203105236.b4a60754.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Lubos Lunak <l.lunak@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Feb 2010, KAMEZAWA Hiroyuki wrote:

> I stopped that as I mentioned. I'm heavily disappointed with myself and
> would like not to touch oom-killer things for a while.
> 
> I'd like to conentrate on memcg for a while, which I've starved for these 3 months.
> 
> Then, you don't need to CC me.
> 

I'm disappointed to hear that, it would be helpful to get some consensus 
on the points that we can all agree on from different perspectives.  I'll 
try to find some time to develop a solution that people will see as a move 
in the positive direction.

On a seperate topic, do you have time to repost your sysctl cleanup for 
Andrew from http://marc.info/?l=linux-kernel&m=126457416729672 with the
#ifndef CONFIG_MMU fix I mentioned?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
