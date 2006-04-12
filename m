Date: Tue, 11 Apr 2006 23:31:08 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC] [PATCH] support for oom_die
In-Reply-To: <20060412101154.019e9cb3.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.63.0604112330180.21892@cuia.boston.redhat.com>
References: <20060411142909.1899c4c4.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0604111025110.564@schroedinger.engr.sgi.com>
 <20060412101154.019e9cb3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 12 Apr 2006, KAMEZAWA Hiroyuki wrote:

> More description:
> Why they want panic at OOM ?

> Another is failover system. Because they can replace system immediately 
> at panic, they doesn't need oom_kill.

This makes perfect sense to me.  Of course, one of the guys
developing our cluster software sits in the cube next to me,
so I do get to see quite a bit of the cluster software ;)

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
