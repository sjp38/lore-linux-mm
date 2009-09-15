Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CC6B96B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 19:49:57 -0400 (EDT)
Date: Wed, 16 Sep 2009 07:49:52 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Isolated(anon) and Isolated(file)
Message-ID: <20090915234951.GA6431@localhost>
References: <Pine.LNX.4.64.0909132011550.28745@sister.anvils> <20090915114742.DB79.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090915114742.DB79.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 15, 2009 at 10:56:27AM +0800, KOSAKI Motohiro wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Tue, 15 Sep 2009 10:16:51 +0900
> Subject: [PATCH] Kill Isolated field in /proc/meminfo
> 
> Hugh Dickins pointed out Isolated field dislpay 0kB at almost time.
> It is only increased at heavy memory pressure case.
> 
> So, if the system haven't get memory pressure, this field isn't useful.
> And now, we have two alternative way, /sys/device/system/node/node{n}/meminfo
> and /prov/vmstat. Then, it can be removed.
> 
> Reported-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
