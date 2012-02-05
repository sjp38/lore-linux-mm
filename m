Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id AB98A6B002C
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 10:11:15 -0500 (EST)
Date: Sun, 5 Feb 2012 23:00:59 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [LSF/MM][ATTEND] readahead and writeback
Message-ID: <20120205150059.GA32739@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

I would like to attend to participate in the readahead and writeback
discussions. My questions are

- readahead size and alignment, hope that we can reach some general
  agreements on the policy stuff

- async write I/O bandwidth controller, will it be a good complement
  feature to the current blk-cgroup I/O controller? Each seem to have
  its own strong areas and weak points.

- per-memcg dirty pages control, to be frank, it's non-trivial to
  implement and I'm not sure it will perform well in some cases.
  Before following that direction, I'm curious whether the much more
  simple scheme of moving dirty pages to the global LRU can magically
  satisfy the main user demands.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
