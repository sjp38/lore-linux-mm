Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 51D176B00D8
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 11:44:45 -0500 (EST)
Message-ID: <4F15A570.8090604@redhat.com>
Date: Tue, 17 Jan 2012 11:44:32 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/3] low memory notify
References: <1326788038-29141-1-git-send-email-minchan@kernel.org> <1326811093.3467.41.camel@lenny>
In-Reply-To: <1326811093.3467.41.camel@lenny>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Walters <walters@verbum.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, leonid.moiseichuk@nokia.com, kamezawa.hiroyu@jp.fujitsu.com, penberg@kernel.org, mel@csn.ul.ie, rientjes@google.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Marcelo Tosatti <mtosatti@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Ronen Hod <rhod@redhat.com>

On 01/17/2012 09:38 AM, Colin Walters wrote:

> How does this relate to the existing cgroups memory notifications?  See
> Documentation/cgroups/memory.txt under "10. OOM Control"

> As far as the desktop goes, I want to get notified if we're going to hit
> swap, not if we're close to exhausting the total of RAM+swap.  While
> swap may make sense for servers that care about throughput mainly, I
> care a lot about latency.

You just answered your own question :)

This code is indeed meant to avoid/reduce swap use and
improve userspace latencies.

Minchan posted a very simple example patch set, so we
can get an idea in what direction people would want
the code to go.  This often beats working on complex
code for weeks, and then having people tell you they
wanted something else :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
