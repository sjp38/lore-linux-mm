Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 2FBD16B0034
	for <linux-mm@kvack.org>; Fri, 10 May 2013 05:00:35 -0400 (EDT)
Date: Fri, 10 May 2013 10:00:26 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v5 17/31] drivers: convert shrinkers to new count/scan API
Message-ID: <20130510090026.GJ11497@suse.de>
References: <1368079608-5611-1-git-send-email-glommer@openvz.org>
 <1368079608-5611-18-git-send-email-glommer@openvz.org>
 <20130509135209.GZ11497@suse.de>
 <518C12D6.4060003@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <518C12D6.4060003@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, hughd@google.com, Greg Thelen <gthelen@google.com>, linux-fsdevel@vger.kernel.org, Dave Chinner <dchinner@redhat.com>, Daniel Vetter <daniel.vetter@ffwll.ch>, Kent Overstreet <koverstreet@google.com>, Arve Hj?nnev?g <arve@android.com>, John Stultz <john.stultz@linaro.org>, David Rientjes <rientjes@google.com>, Jerome Glisse <jglisse@redhat.com>, Thomas Hellstrom <thellstrom@vmware.com>

On Fri, May 10, 2013 at 01:19:18AM +0400, Glauber Costa wrote:
> > 
> > Last time I complained about some of the shrinker implementations but
> > I'm not expecting them to be fixed in this series. However I still have
> > questions about where -1 should be returned that I don't think were
> > addressed so I'll repeat them.
> > 
> 
> Note that the series try to keep the same behavior as we had before.
> (modulo mistakes, spotting them are mostly welcome)
> 
> So if we are changing any of this, maybe better done in a separate patch?
> 

Ok, that's fair enough and a separate patch does make sense. I thought
it was an oversight when the -1 return value was documented but not all
callers were updated even though it looked appropriate. Slap a comment
above the highlighted places suggesting that a return value of -1 be used
instead so it does not get lost maybe?

Whether you do that or not

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
