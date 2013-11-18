Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0DF516B0037
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 18:15:33 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id up15so2736632pbc.10
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 15:15:33 -0800 (PST)
Received: from psmtp.com ([74.125.245.132])
        by mx.google.com with SMTP id yj7si4494796pab.83.2013.11.18.15.15.28
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 15:15:30 -0800 (PST)
Date: Mon, 18 Nov 2013 23:15:06 +0000
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [patch] mm, memcg: add memory.oom_control notification for
 system oom
Message-ID: <20131118231506.32ec2467@alan.etchedpixels.co.uk>
In-Reply-To: <20131118155450.GB3556@cmpxchg.org>
References: <alpine.DEB.2.02.1310301838300.13556@chino.kir.corp.google.com>
	<20131031054942.GA26301@cmpxchg.org>
	<alpine.DEB.2.02.1311131416460.23211@chino.kir.corp.google.com>
	<20131113233419.GJ707@cmpxchg.org>
	<alpine.DEB.2.02.1311131649110.6735@chino.kir.corp.google.com>
	<20131114032508.GL707@cmpxchg.org>
	<alpine.DEB.2.02.1311141447160.21413@chino.kir.corp.google.com>
	<20131118155450.GB3556@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

> And accessing the emergency reserves means we are definitely no longer
> A-OK, this is not comparable to the first direct reclaim invocation.
> 
> We exhausted our options and we got really lucky.  It should not be
> considered the baseline and a user listening for "OOM conditions"
> should be informed about this.

Definitely concur - there are loading tuning cases where you want to
drive the box to the point it starts whining and then scale back a touch.

It's an API change in effect, and while I can believe there are good
arguments for both any API change ought to be a new API for listening
only to serious OOM cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
