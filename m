Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 442DF6B0062
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 00:46:07 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6G4k8Se014913
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Jul 2009 13:46:08 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7ED8B45DE57
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 13:46:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4789D45DE4E
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 13:46:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2243DE38004
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 13:46:08 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B6BA21DB803B
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 13:46:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/3] Rename pgmoved variable in shrink_active_list()
In-Reply-To: <20090716133622.9D34.A69D9226@jp.fujitsu.com>
References: <20090715213516.9b47ad16.akpm@linux-foundation.org> <20090716133622.9D34.A69D9226@jp.fujitsu.com>
Message-Id: <20090716134535.9D37.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Jul 2009 13:46:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > On Thu, 16 Jul 2009 13:22:30 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > -#define __add_zone_page_state(__z, __i, __d)	\
> > > -		__mod_zone_page_state(__z, __i, __d)
> > > -#define __sub_zone_page_state(__z, __i, __d)	\
> > > -		__mod_zone_page_state(__z, __i,-(__d))
> > > -
> > 
> > yeah, whatever, I don't think they add a lot of value personally.
> > 
> > I guess they're a _bit_ clearer than doing __sub_zone_page_state() with
> > a negated argument.  Shrug.
> 
> OK, I've catched your point.
> I'll make all caller replacing patches.

Please drop last mail. I was confused ;-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
