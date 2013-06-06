Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id DB3D56B0033
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 05:02:45 -0400 (EDT)
Message-ID: <51B05069.5070404@parallels.com>
Date: Thu, 6 Jun 2013 13:03:37 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 08/35] list: add a new LRU list type
References: <1370287804-3481-1-git-send-email-glommer@openvz.org> <1370287804-3481-9-git-send-email-glommer@openvz.org> <20130605160758.19e854a6995e3c2a1f5260bf@linux-foundation.org> <20130606024909.GP29338@dastard> <20130605200554.d4dae16f.akpm@linux-foundation.org> <20130606044426.GX29338@dastard> <20130606000409.e4333f7c.akpm@linux-foundation.org>
In-Reply-To: <20130606000409.e4333f7c.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>

On 06/06/2013 11:04 AM, Andrew Morton wrote:
> But anyone who just wants a queue doesn't want their queue_lru_del()
> calling into memcg code(!).

It won't call any relevant memcg code unless the list_lru (or queue, or
whatever) is explicitly marked as memcg-aware.


 I do think it would be more appropriate to
> discard the lib/ idea and move it all into fs/ or mm/.
I have no particular love for this in lib/

Most of the users are in fs/, so I see no point in mm/
So for me, if you are really not happy about lib, I would suggest moving
this to fs/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
