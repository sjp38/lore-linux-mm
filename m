Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A190A6B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 05:31:55 -0400 (EDT)
Date: Tue, 9 Aug 2011 11:31:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH RFC] memcg: fix drain_all_stock crash
Message-ID: <20110809093150.GC7463@tiehlicka.suse.cz>
References: <cover.1311338634.git.mhocko@suse.cz>
 <a9244082ba28c4c2e4a6997311d5493bdaa117e9.1311338634.git.mhocko@suse.cz>
 <20110808184738.GA7749@redhat.com>
 <20110808214704.GA4396@tiehlicka.suse.cz>
 <20110808231912.GA29002@redhat.com>
 <20110809072615.GA7463@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110809072615.GA7463@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

What do you think about the half backed patch bellow? I didn't manage to
test it yet but I guess it should help. I hate asymmetry of drain_lock
locking (it is acquired somewhere else than it is released which is
not). I will think about a nicer way how to do it.
Maybe I should also split the rcu part in a separate patch.

What do you think?
---
