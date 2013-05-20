Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 24ED86B0033
	for <linux-mm@kvack.org>; Mon, 20 May 2013 19:41:55 -0400 (EDT)
Message-ID: <519AB4EA.60905@parallels.com>
Date: Tue, 21 May 2013 03:42:34 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v7 18/34] fs: convert fs shrinkers to new scan/count API
References: <1368994047-5997-1-git-send-email-glommer@openvz.org> <1368994047-5997-19-git-send-email-glommer@openvz.org> <1369038304.2728.37.camel@menhir> <519A2951.9040908@parallels.com> <519A407B.9030205@parallels.com> <20130520233807.GD24543@dastard>
In-Reply-To: <20130520233807.GD24543@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Steven Whitehouse <swhiteho@redhat.com>, Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, hughd@google.com, Dave Chinner <dchinner@redhat.com>, Adrian Hunter <adrian.hunter@intel.com>

On 05/21/2013 03:38 AM, Dave Chinner wrote:
>> If you for any reason wanted nr_to_scan to mean # of objects *scanned*,
>> > not freed, IOW, if this is not a mistake, please say so and justify.
> Justification presented. nr_to_scan has *always* meant "# of objects
> *scanned*", and this patchset does not change that.
> 
> Cheers,
> 
> Dave.
Good.

Thanks Dave, it makes sense.

I proactively changed this, but I will revert the changes tomorrow - and
just to be sure, audit again, but this time looking for the right thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
