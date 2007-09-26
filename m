Date: Wed, 26 Sep 2007 13:06:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm 5/5] oom: add sysctl to dump tasks memory state
Message-Id: <20070926130616.f16446fd.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.0.9999.0709212313140.13727@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709212311130.13727@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709212312160.13727@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709212312400.13727@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709212312560.13727@chino.kir.corp.google.com>
	<alpine.DEB.0.9999.0709212313140.13727@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: andrea@suse.de, clameter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 22 Sep 2007 10:47:13 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> Adds a new sysctl, 'oom_dump_tasks', that dumps a list of all system tasks
> (excluding kernel threads) and their pid, uid, tgid, vm size, rss cpu,
> oom_adj score, and name.
> 
> Helpful for determining why an OOM condition occurred and what rogue task
> caused it.
> 
> It is configurable so that large systems, such as those with several
> thousand tasks, do not incur a performance penalty associated with data
> they may not desire.
> 
> There currently do not appear to be any other generic kernel callers that
> dump all this information.  Perhaps in the future it will be worthwhile
> to construct a generic task dump interface based on passing a set of
> flags that specify what per-task information shall be shown.

It isn't obvious to me why this has "oom" in its name.  It is just a
general display-stuff-about-task-memory handler, isn't it?

Nor is it obvious why we need it at all.  This sort of information can
already be gathered from /proc/pid/whatever.  If the system is all wedged
and you can't get console control then this info dump doesn't provide you
with info which you're interested in anyway - you want to see the global
(or per-cgroup) info, not the per-task info.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
