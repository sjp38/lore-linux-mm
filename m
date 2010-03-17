Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id EA35162003F
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:27:03 -0400 (EDT)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o2HGQwYL029020
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 09:26:58 -0700
Received: from fxm8 (fxm8.prod.google.com [10.184.13.8])
	by wpaz13.hot.corp.google.com with ESMTP id o2HGQtOL009657
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 09:26:57 -0700
Received: by fxm8 with SMTP id 8so450728fxm.25
        for <linux-mm@kvack.org>; Wed, 17 Mar 2010 09:26:55 -0700 (PDT)
Date: Wed, 17 Mar 2010 16:26:41 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH 3/5] tmpfs: handle MPOL_LOCAL mount option properly
In-Reply-To: <20100316145022.4C4E.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1003171619410.29003@sister.anvils>
References: <201003122353.o2CNrC56015250@imap1.linux-foundation.org> <20100316143406.4C45.A69D9226@jp.fujitsu.com> <20100316145022.4C4E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, kiran@scalex86.org, cl@linux-foundation.org, lee.schermerhorn@hp.com, mel@csn.ul.ie, stable@kernel.org, linux-mm <linux-mm@kvack.org>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Mar 2010, KOSAKI Motohiro wrote:

> commit 71fe804b6d5 (mempolicy: use struct mempolicy pointer in
> shmem_sb_info) added mpol=local mount option. but its feature is
> broken since it was born. because such code always return 1 (i.e.
> mount failure).
> 
> This patch fixes it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Ravikiran Thirumalai <kiran@scalex86.org>

Thank you both for finding and fixing these mpol embarrassments.

But if this "mpol=local" feature was never documented (not even in the
commit log), has been broken since birth 20 months ago, and nobody has
noticed: wouldn't it be better to save a little bloat and just rip it out?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
