Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A79406B00A6
	for <linux-mm@kvack.org>; Wed, 27 Oct 2010 20:17:34 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9S0HWRT014285
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 28 Oct 2010 09:17:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D29EC45DE79
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 09:17:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 945FE45DE60
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 09:17:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C98C1DB803F
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 09:17:31 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 095611DB803B
	for <linux-mm@kvack.org>; Thu, 28 Oct 2010 09:17:31 +0900 (JST)
Date: Thu, 28 Oct 2010 09:11:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: don't flush TLB when propagate PTE access bit to
 struct page.
Message-Id: <20101028091158.4de545e9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTim9NBXrAWkMW7C5C6=1sh52OJm=u5HT7ShyC7hv@mail.gmail.com>
References: <1288200090-23554-1-git-send-email-yinghan@google.com>
	<4CC869F5.2070405@redhat.com>
	<AANLkTikL+v6uzkXg-7J2FGVz-7kc0Myw_cO5s_wYfHHm@mail.gmail.com>
	<AANLkTimLBO7mJugVXH0S=QSnwQ+NDcz3zxmcHmPRjngd@mail.gmail.com>
	<alpine.LSU.2.00.1010271144540.5039@tigran.mtv.corp.google.com>
	<AANLkTim9NBXrAWkMW7C5C6=1sh52OJm=u5HT7ShyC7hv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, Rik van Riel <riel@redhat.com>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 27 Oct 2010 13:35:02 -0700
Ying Han <yinghan@google.com> wrote:
> >
> > > I had a vague memory of this problem biting someone when this flush
> > wasn't
> > > actually done properly... maybe powerpc.
> > >
> > > But anyway, same solution could be possible, by flushing every N pages
> > scanned.
> >
> > Yes, batching seems safer.
> >
> 
> I might be able to take a look at it.
> 

I'd like to vote for batching.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
