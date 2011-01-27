Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 36FEC8D0039
	for <linux-mm@kvack.org>; Thu, 27 Jan 2011 05:48:09 -0500 (EST)
Date: Thu, 27 Jan 2011 11:47:59 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] memsw: Deprecate noswapaccount kernel parameter and
 schedule it for removal
Message-ID: <20110127104759.GA4301@tiehlicka.suse.cz>
References: <20110126152158.GA4144@tiehlicka.suse.cz>
 <20110126140618.8e09cd23.akpm@linux-foundation.org>
 <20110127082320.GA15500@tiehlicka.suse.cz>
 <20110127180330.78585085.kamezawa.hiroyu@jp.fujitsu.com>
 <20110127092951.GA8036@tiehlicka.suse.cz>
 <20110127184827.a8927595.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110127184827.a8927595.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Thu 27-01-11 18:48:27, KAMEZAWA Hiroyuki wrote:
> Could you try to write a patch for feature-removal-schedule.txt
> and tries to remove noswapaccount and do clean up all ?
> (And add warning to noswapaccount will be removed.....in 2.6.40)

Sure, no problem. What do you think about the following patch?
---
