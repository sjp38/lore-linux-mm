Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 80F968D0048
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 18:21:51 -0500 (EST)
Date: Tue, 22 Feb 2011 16:21:47 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 3/5] page_cgroup: make page tracking available for blkio
Message-ID: <20110222162147.02e772b3@bike.lwn.net>
In-Reply-To: <20110222230630.GL28269@redhat.com>
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
	<1298394776-9957-4-git-send-email-arighi@develer.com>
	<20110222130145.37cb151e@bike.lwn.net>
	<20110222230146.GB23723@linux.develer.com>
	<20110222230630.GL28269@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Gui Jianfeng <guijianfeng@cn.fujitsu.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Jens Axboe <axboe@kernel.dk>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 22 Feb 2011 18:06:30 -0500
Vivek Goyal <vgoyal@redhat.com> wrote:

> I think John suggested replacing mem_cgroup pointer with css_set so that
> size of the strcuture does not increase but it leads extra level of 
> indirection.

That is what I was thinking.  But I did also say it's probably premature
generalization at this point, especially given that there'd be a runtime
cost.

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
