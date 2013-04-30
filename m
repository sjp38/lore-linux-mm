Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id DCE1B6B0101
	for <linux-mm@kvack.org>; Tue, 30 Apr 2013 12:12:33 -0400 (EDT)
Message-ID: <517FED9E.9020906@parallels.com>
Date: Tue, 30 Apr 2013 20:13:18 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 10/31] dcache: convert to use new lru list infrastructure
References: <1367018367-11278-1-git-send-email-glommer@openvz.org> <1367018367-11278-11-git-send-email-glommer@openvz.org> <20130430160411.GJ6415@suse.de>
In-Reply-To: <20130430160411.GJ6415@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Glauber Costa <glommer@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Dave Chinner <dchinner@redhat.com>


> 
> To save wasting space you could also put them each beside otherwise
> read-mostly data, before s_mounts (per-cpu data before it should be
> cache-aligned) and anywhere near the end of the structure without the
> cache alignment directives.
> 
> Otherwise nothing jumped at me.
> 
I will add:

Nothing-jumped-at: Mel Gorman <mgorman@suse.de>

=)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
