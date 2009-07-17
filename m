Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C2E886B004F
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 19:14:01 -0400 (EDT)
Date: Fri, 17 Jul 2009 16:13:58 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUGFIX][PATCH] cgroup avoid permanent sleep at rmdir v7
Message-Id: <20090717161358.d6deea38.akpm@linux-foundation.org>
In-Reply-To: <20090717023519.GG3576@balbir.in.ibm.com>
References: <20090703093154.5f6e910a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090716145534.07511d67.kamezawa.hiroyu@jp.fujitsu.com>
	<20090717023519.GG3576@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp, menage@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 17 Jul 2009 08:05:19 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-07-16 14:55:34]:
> 
> > Rebased onto mm-of-the-moment snapshot 2009-07-15-20-57.
> > passed fundamental tests.
> 
> Andrew could you please pick this up, it is an important bugfix and if
> possible needs to go into 2.6.31-rcX. Does anybody object to that or
> should we wait till 2.6.32-rc1?

I marked this as for-2.6.31-rc4.  Unless someone stops me, that's when
I shall send it upwards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
