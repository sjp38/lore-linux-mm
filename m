Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 221CA6B0044
	for <linux-mm@kvack.org>; Wed,  7 Nov 2012 02:10:20 -0500 (EST)
Date: Tue, 6 Nov 2012 23:10:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v6 18/29] Allocate memory for memcg caches whenever a
 new memcg appears
Message-Id: <20121106231017.faf424b8.akpm@linux-foundation.org>
In-Reply-To: <509A0826.1030708@parallels.com>
References: <1351771665-11076-1-git-send-email-glommer@parallels.com>
	<1351771665-11076-19-git-send-email-glommer@parallels.com>
	<20121105162330.4aa629f8.akpm@linux-foundation.org>
	<509A0826.1030708@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On Wed, 7 Nov 2012 08:05:10 +0100 Glauber Costa <glommer@parallels.com> wrote:

> Since you have already included this in mm, would you like me to
> resubmit the series changing things according to your feedback, or
> should I send incremental patches?

I normally don't care.  I do turn replacements into incrementals so
that I and others can see what changed, but that's all scripted.

However in this case the patches have been changed somewhat (mainly
because of sched/numa getting in the way) so incrementals would be nice
if convenient, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
