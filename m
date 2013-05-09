Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 72F316B0038
	for <linux-mm@kvack.org>; Thu,  9 May 2013 17:04:53 -0400 (EDT)
Message-ID: <518C0FA5.3070904@parallels.com>
Date: Fri, 10 May 2013 01:05:41 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 11/31] list_lru: per-node list infrastructure
References: <1368079608-5611-1-git-send-email-glommer@openvz.org> <1368079608-5611-12-git-send-email-glommer@openvz.org> <20130509134246.GX11497@suse.de>
In-Reply-To: <20130509134246.GX11497@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>

On 05/09/2013 05:42 PM, Mel Gorman wrote:
> It would still be nice though if the size problem was highlighted with
> either a comment and/or a changelog entry describing the problem and how
> you plan to address it in case it takes a long time to get fixed. If the
> problem persists and we get a bug report about allocation warnings at
> mount time then the notes will be available.

done.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
