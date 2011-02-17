Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6A1CE8D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 15:53:07 -0500 (EST)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH v3 0/2] memcg: variable type fixes
Date: Thu, 17 Feb 2011 12:52:46 -0800
Message-Id: <1297975968-19672-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>

Changes since -v2:
- Reworded patch 1 commit message.

This is a two part series that is a cleanup of memcg internal
counters.  These two patches were originally proposed by Johannes
Weiner [1].  The original series was based on an older mmotm, so I had
to massage the patches a little.  The patches are based on
mmotm-2011-02-10-16-26.

Patch 1 implements the idea that memcg only has to use signed types
for some of the counters, but not for the constant monotonically
increasing event counters where the sign-bit is a waste.
Originally proposed in [2].

Patch 2 converts the memcg fundamental page statistics counters to
native words as they should be wide enough for the expected values.
Originally proposed in [3].

References:
 [1] https://lkml.org/lkml/2010/11/7/170
 [2] https://lkml.org/lkml/2010/11/7/174
 [3] https://lkml.org/lkml/2010/11/7/171

Johannes Weiner (2):
  memcg: break out event counters from other stats
  memcg: use native word page statistics counters

 mm/memcontrol.c |   78 ++++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 51 insertions(+), 27 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
