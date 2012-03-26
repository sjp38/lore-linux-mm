Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 6917A6B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 17:40:18 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so8013372pbc.14
        for <linux-mm@kvack.org>; Mon, 26 Mar 2012 14:40:17 -0700 (PDT)
Date: Mon, 26 Mar 2012 14:39:49 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v6 1/7] mm/memcg: scanning_global_lru means
 mem_cgroup_disabled
In-Reply-To: <20120326153131.GA22715@tiehlicka.suse.cz>
Message-ID: <alpine.LSU.2.00.1203261435110.3550@eggly.anvils>
References: <20120322214944.27814.42039.stgit@zurg> <20120322215616.27814.40563.stgit@zurg> <20120326150429.GA22754@tiehlicka.suse.cz> <20120326151815.GA1820@cmpxchg.org> <20120326153131.GA22715@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Glauber Costa <glommer@parallels.com>

On Mon, 26 Mar 2012, Michal Hocko wrote:
> 
> I guess that a note about changed ratio calculation should be added to
> the changelog.

To the changelog of a patch which changes the ratio calculation, yes; but
not to the changelog of this patch, which changes only the name of the test.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
