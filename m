Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 728606B0002
	for <linux-mm@kvack.org>; Mon, 13 May 2013 02:09:40 -0400 (EDT)
Message-ID: <1368425530.3208.13.camel@sauron.fi.intel.com>
Subject: Re: [PATCH v6 15/31] fs: convert fs shrinkers to new scan/count API
From: Artem Bityutskiy <dedekind1@gmail.com>
Reply-To: dedekind1@gmail.com
Date: Mon, 13 May 2013 09:12:10 +0300
In-Reply-To: <1368382432-25462-16-git-send-email-glommer@openvz.org>
References: <1368382432-25462-1-git-send-email-glommer@openvz.org>
	 <1368382432-25462-16-git-send-email-glommer@openvz.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>, Dave Chinner <dchinner@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, Adrian Hunter <adrian.hunter@intel.com>, Jan Kara <jack@suse.cz>

On Sun, 2013-05-12 at 22:13 +0400, Glauber Costa wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Convert the filesystem shrinkers to use the new API, and standardise
> some of the behaviours of the shrinkers at the same time. For
> example, nr_to_scan means the number of objects to scan, not the
> number of objects to free.
> 
> I refactored the CIFS idmap shrinker a little - it really needs to
> be broken up into a shrinker per tree and keep an item count with
> the tree root so that we don't need to walk the tree every time the
> shrinker needs to count the number of objects in the tree (i.e.
> all the time under memory pressure).

UBIFS part looks OK.

-- 
Best Regards,
Artem Bityutskiy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
