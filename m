Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A7C056B01F1
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 10:25:31 -0400 (EDT)
Subject: Re: [RFC][PATCH] Per file dirty limit throttling
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20100818140856.GE28417@balbir.in.ibm.com>
References: <201008160949.51512.knikanth@suse.de>
	 <201008171039.23701.knikanth@suse.de> <1282033475.1926.2093.camel@laptop>
	 <201008181452.05047.knikanth@suse.de> <1282125536.1926.3675.camel@laptop>
	 <20100818140856.GE28417@balbir.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 18 Aug 2010 16:25:18 +0200
Message-ID: <1282141518.1926.4048.camel@laptop>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Nikanth Karthikesan <knikanth@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Bill Davidsen <davidsen@tmr.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-08-18 at 19:38 +0530, Balbir Singh wrote:

> There is an ongoing effort to look at per-cgroup dirty limits and I
> honestly think it would be nice to do it at that level first. We need
> it there as a part of the overall I/O controller. As a specialized
> need it could handle your case as well.=20

Well, it would be good to isolate that to the cgroup code. Also from
what I understood, the plan was to simply mark dirty inodes with a
cgroup and use that from writeout_inodes() to write out inodes
specifically used by that cgroup.

That is, on top of what Andrea Righi already proposed, which would
provide the actual per cgroup dirty limit (although the per-bdi
proportions applied to a cgroup limit aren't strictly correct, but that
seems to be something you'll have to live with, a per-bdi-per-cgroup
proportion would simply be accounting insanity).

That is a totally different thing than what was proposed.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
