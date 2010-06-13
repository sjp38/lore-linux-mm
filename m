Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E86DD6B01BE
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 07:25:02 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5DBP0xD021786
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 13 Jun 2010 20:25:00 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9225C45DE4D
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:25:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F34045DE4E
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:25:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5AA0C1DB8038
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:25:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BB441DB803B
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:57 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 05/18] oom: give current access to memory reserves if it has been killed
In-Reply-To: <20100608131211.e769e3a1.akpm@linux-foundation.org>
References: <20100608203216.765D.A69D9226@jp.fujitsu.com> <20100608131211.e769e3a1.akpm@linux-foundation.org>
Message-Id: <20100613202009.619F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Sun, 13 Jun 2010 20:24:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue,  8 Jun 2010 20:41:57 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > +
> > >  	if (sysctl_panic_on_oom == 2) {
> > >  		dump_header(NULL, gfp_mask, order, NULL);
> > >  		panic("out of memory. Compulsory panic_on_oom is selected.\n");
> > 
> > Sorry, I had found this patch works incorrect. I don't pulled.
> 
> Saying "it doesn't work and I'm not telling you why" is unhelpful.  In
> fact it's the opposite of helpful because it blocks merging of the fix
> and doesn't give us any way to move forward.
> 
> So what can I do?  Hard.
> 
> What I shall do is to merge the patch in the hope that someone else will
> discover the undescribed problem and we will fix it then.  That's very
> inefficient.

Please see 5 minute before positng e-mail. thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
