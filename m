Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id CA5386B0078
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 06:11:22 -0400 (EDT)
Date: Wed, 20 Jun 2012 12:11:19 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH v2 -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120620101119.GC5541@tiehlicka.suse.cz>
References: <1340117404-30348-1-git-send-email-mhocko@suse.cz>
 <20120619150014.1ebc108c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120619150014.1ebc108c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Fengguang Wu <fengguang.wu@intel.com>

Hi Andrew,
here is an updated version if it is easier for you to drop the previous
one.
changes since v1
* added Mel's Reviewed-by
* updated changelog as per Andrew
* updated the condition to be optimized for no-memcg case
---
