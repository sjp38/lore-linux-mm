Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 60B1E6B004A
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 10:07:14 -0400 (EDT)
Message-ID: <1335535630.28106.209.camel@gandalf.stny.rr.com>
Subject: Re: [PATCH v4 1/3] make jump_labels wait while updates are in place
From: Steven Rostedt <rostedt@goodmis.org>
Date: Fri, 27 Apr 2012 10:07:10 -0400
In-Reply-To: <20120427135320.GA13762@redhat.com>
References: <1335480667-8301-1-git-send-email-glommer@parallels.com>
	 <1335480667-8301-2-git-send-email-glommer@parallels.com>
	 <20120427004305.GC23877@home.goodmis.org>
	 <20120427135320.GA13762@redhat.com>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Baron <jbaron@redhat.com>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Tejun Heo <tj@kernel.org>, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Ingo Molnar <mingo@elte.hu>

On Fri, 2012-04-27 at 09:53 -0400, Jason Baron wrote:

> Right, for x86 which uses stop_machine currently, we guarantee that all
> cpus are going to see the updated code, before the inc of key->enabled.
> However, other arches (sparc, mips, powerpc, for example), seem to be
> using much lighter weight updates, which I hope are ok :)

And x86 will soon be removing stop_machine() from its path too. But all
archs should perform some kind of memory sync after patching code. Thus
the update should be treated as if a memory barrier was added after it,
and before the inc.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
