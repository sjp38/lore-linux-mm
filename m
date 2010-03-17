Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B275B600363
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 19:52:28 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2HNqO3q024576
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 18 Mar 2010 08:52:24 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F56445DE51
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 08:52:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F08A45DE50
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 08:52:24 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E016E38002
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 08:52:24 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 072071DB8046
	for <linux-mm@kvack.org>; Thu, 18 Mar 2010 08:52:24 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] tmpfs: handle MPOL_LOCAL mount option properly
In-Reply-To: <alpine.LSU.2.00.1003171619410.29003@sister.anvils>
References: <20100316145022.4C4E.A69D9226@jp.fujitsu.com> <alpine.LSU.2.00.1003171619410.29003@sister.anvils>
Message-Id: <20100318084915.8723.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 18 Mar 2010 08:52:23 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>, lee.schermerhorn@hp.com
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, kiran@scalex86.org, cl@linux-foundation.org, mel@csn.ul.ie, stable@kernel.org, linux-mm <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> On Tue, 16 Mar 2010, KOSAKI Motohiro wrote:
> 
> > commit 71fe804b6d5 (mempolicy: use struct mempolicy pointer in
> > shmem_sb_info) added mpol=local mount option. but its feature is
> > broken since it was born. because such code always return 1 (i.e.
> > mount failure).
> > 
> > This patch fixes it.
> > 
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > Cc: Ravikiran Thirumalai <kiran@scalex86.org>
> 
> Thank you both for finding and fixing these mpol embarrassments.
> 
> But if this "mpol=local" feature was never documented (not even in the
> commit log), has been broken since birth 20 months ago, and nobody has
> noticed: wouldn't it be better to save a little bloat and just rip it out?

I have no objection if lee agreed, lee?
Of cource, if we agree it, we can make the new patch soon :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
