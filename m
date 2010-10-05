Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 590226B0047
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 03:35:22 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o957ZJ1o011648
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 5 Oct 2010 16:35:19 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E562445DE54
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 17:15:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E562445DE4F
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 17:15:00 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A29C51DB805D
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 16:35:18 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 51E031DB8038
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 16:35:18 +0900 (JST)
Date: Tue, 5 Oct 2010 16:29:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 10/10] memcg: check memcg dirty limits in page writeback
Message-Id: <20101005162958.07de9781.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1286175485-30643-11-git-send-email-gthelen@google.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-11-git-send-email-gthelen@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sun,  3 Oct 2010 23:58:05 -0700
Greg Thelen <gthelen@google.com> wrote:

> If the current process is in a non-root memcg, then
> global_dirty_limits() will consider the memcg dirty limit.
> This allows different cgroups to have distinct dirty limits
> which trigger direct and background writeback at different
> levels.
> 
> Signed-off-by: Andrea Righi <arighi@develer.com>
> Signed-off-by: Greg Thelen <gthelen@google.com>

This patch seems good because of straightforward implementation.
I think worth to be tested in -mm tree.

Thank you very much.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
