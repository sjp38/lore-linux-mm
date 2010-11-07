Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 732386B0087
	for <linux-mm@kvack.org>; Sun,  7 Nov 2010 17:15:08 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/4] memcg: variable type fixes
Date: Sun,  7 Nov 2010 23:14:35 +0100
Message-Id: <20101107215030.007259800@cmpxchg.org>
In-Reply-To: <AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com>
References: <1288973333-7891-1-git-send-email-minchan.kim@gmail.com> <20101106010357.GD23393@cmpxchg.org> <AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Greg,

it is not the res counter primitives, these are our own counters.  We
have to keep signed types for most counters, as the per-cpu counter
folding can race and we end up with negative values.

The fix for the original issue is in patch 1.  There are no casts
needed, the range is checked to be sane and then converted to the
unsigned type through assignment.

Patch 2, also a type fix, ensures we catch accounting races properly.
It is unrelated, but also important.

Patch 3 implements the idea that we only have to used signed types for
_some_ of the counters, but not for constant event counters where the
sign-bit would be a waste.

Patch 4 converts our fundamental page statistics counters to native
words as these should be wide enough for the expected values.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
