Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD7F6B0095
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 18:16:43 -0500 (EST)
Date: Tue, 26 Jan 2010 15:16:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
Message-Id: <20100126151606.54764be2.akpm@linux-foundation.org>
In-Reply-To: <20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Jan 2010 15:15:03 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> -unsigned long badness(struct task_struct *p, unsigned long uptime)
> +unsigned long badness(struct task_struct *p, unsigned long uptime,
> +			int constraint)

And badness() should be renamed to something better (eg, oom_badness), and
the declaration should be placed in a mm-specific header file.

Yes, the code was already like that.  But please don't leave crappiness in
place when you come across it - take the opportunity to fix it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
