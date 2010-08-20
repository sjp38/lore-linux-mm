Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 360196B02BA
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 00:13:33 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7K4DUKT016309
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 20 Aug 2010 13:13:30 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 678ED45DE4F
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 13:13:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4BB2345DD71
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 13:13:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3100B1DB8012
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 13:13:30 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C92D31DB8014
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 13:13:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] writeback: remove the internal 5% low bound on dirty_ratio
In-Reply-To: <20100820032506.GA6662@localhost>
References: <20100820032506.GA6662@localhost>
Message-Id: <20100820131249.5FF4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 20 Aug 2010 13:13:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, david@fromorbit.com, hch@lst.de, axboe@kernel.dk, Michael Rubin <mrubin@google.com>, Jan Kara <jack@suse.cz>, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

> The dirty_ratio was silently limited to >= 5%. This is not a user
> expected behavior. Let's rip it.
> 
> It's not likely the user space will depend on the old behavior.
> So the risk of breaking user space is very low.
> 
> CC: Jan Kara <jack@suse.cz>
> CC: Neil Brown <neilb@suse.de>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Thank you.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
