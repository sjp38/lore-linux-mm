Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DE5536B00B4
	for <linux-mm@kvack.org>; Fri,  5 Nov 2010 21:04:23 -0400 (EDT)
Date: Sat, 6 Nov 2010 02:03:57 +0100
Subject: Re: [PATCH] memcg: use do_div to divide s64 in 32 bit machine.
Message-ID: <20101106010357.GD23393@cmpxchg.org>
References: <1288973333-7891-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1288973333-7891-1-git-send-email-minchan.kim@gmail.com>
From: hannes@cmpxchg.org
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Greg Thelen <gthelen@google.com>, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Nov 06, 2010 at 01:08:53AM +0900, Minchan Kim wrote:
> Use do_div to divide s64 value. Otherwise, build would be failed
> like Dave Young reported.

I thought about that too, but then I asked myself why you would want
to represent a number of pages as signed 64bit type, even on 32 bit?

Isn't the much better fix to get the types right instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
