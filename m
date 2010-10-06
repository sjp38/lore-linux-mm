Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C21266B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 20:04:30 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9704Qhb010194
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 7 Oct 2010 09:04:26 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A73345DE57
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 09:04:26 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EE5F545DE53
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 09:04:25 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B22E8E38004
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 09:04:25 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FC8F1DB8040
	for <linux-mm@kvack.org>; Thu,  7 Oct 2010 09:04:25 +0900 (JST)
Date: Thu, 7 Oct 2010 08:58:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Restrict size of page_cgroup->flags
Message-Id: <20101007085858.0e07de59.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20101006142314.GG4195@balbir.in.ibm.com>
References: <20101006142314.GG4195@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: containers@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 6 Oct 2010 19:53:14 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> I propose restricting page_cgroup.flags to 16 bits. The patch for the
> same is below. Comments?
> 
> 
> Restrict the bits usage in page_cgroup.flags
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Restricting the flags helps control growth of the flags unbound.
> Restriciting it to 16 bits gives us the possibility of merging
> cgroup id with flags (atomicity permitting) and saving a whole
> long word in page_cgroup
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>

Doesn't make sense until you show the usage of existing bits.
And I guess 16bit may be too large on 32bit systems.

Nack for now.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
