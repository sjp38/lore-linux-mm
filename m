Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 163036B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 14:21:51 -0400 (EDT)
Message-ID: <4E32FA3D.5060100@draigBrady.com>
Date: Fri, 29 Jul 2011 19:21:49 +0100
From: =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: [PATCH] kswapd: avoid unnecessary rebalance after an unsuccessful
 balancing
References: <1311952990-3844-1-git-send-email-alex.shi@intel.com>
In-Reply-To: <1311952990-3844-1-git-send-email-alex.shi@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@intel.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, linux-kernel@vger.kernel.org, andrea@cpushare.com, tim.c.chen@intel.com, shaohua.li@intel.com, akpm@linux-foundation.org, riel@redhat.com, luto@mit.edu

On 07/29/2011 04:23 PM, Alex Shi wrote:
> In commit 215ddd66, Mel Gorman said kswapd is better to sleep after a
> unsuccessful balancing if there is tighter reclaim request pending in
> the balancing. In this scenario, the 'order' and 'classzone_idx'
> that are checked for tighter request judgment is incorrect, since they
> aren't the one kswapd should read from new pgdat, but the last time pgdat
> value for just now balancing. Then kswapd will skip try_to_sleep func
> and rebalance the last pgdat request. It's not our expected behavior.
> 
> So, I added new variables to distinguish the returned order/classzone_idx
> from last balancing, that can resolved above issue in that scenario.
> 
> I tested the patch on our LKP system with swap-cp/fio mmap randrw
> benchmarks. The performance has no change.
> 
> Padraig Brady, would you like to test this patch for your scenario.

This
+ your previous 2 line patch
+ Mel's 3 patches
+ 2.6.38.4

still works fine for me.

cheers,
Padraig.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
