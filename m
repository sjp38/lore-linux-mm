Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id ECA366B01F0
	for <linux-mm@kvack.org>; Mon, 30 Aug 2010 21:07:35 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7V17Yks022564
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 31 Aug 2010 10:07:34 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 60CF045DE50
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:07:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CAE245DE4E
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:07:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2557A1DB804B
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:07:34 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CF9071DB8047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:07:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] writeback: Reporting dirty thresholds in /proc/vmstat
In-Reply-To: <AANLkTimLwv04pvuz_AtSK3ASr-epD0PeA-vOCigFH8+0@mail.gmail.com>
References: <20100830092446.524B.A69D9226@jp.fujitsu.com> <AANLkTimLwv04pvuz_AtSK3ASr-epD0PeA-vOCigFH8+0@mail.gmail.com>
Message-Id: <20100831095932.87CD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 31 Aug 2010 10:07:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Michael Rubin <mrubin@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, jack@suse.cz, riel@redhat.com, akpm@linux-foundation.org, david@fromorbit.com, npiggin@kernel.dk, hch@lst.de, axboe@kernel.dk
List-ID: <linux-mm.kvack.org>

> On Sun, Aug 29, 2010 at 5:28 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> > afaict, you and wu agreed /debug/bdi/default/stats is enough good.
> > why do you change your mention?
> 
> I commented on this in the 0/4 email of the bug. I think these belong
> in /proc/vmstat but I saw they exist in /debug/bdi/default/stats. I
> figure they will probably not be accepted but I thought it was worth
> attaching for consideration of upgrading from debugfs to /proc.

For reviewers view, we are reviewing your patch to merge immediately if all issue are fixed.
Then, I'm unhappy if you don't drop merge blocker item even though you merely want asking.
At least, you can make separate thread, no?

Of cource, wen other user also want to expose via /proc interface, we are resume
this discusstion gradly.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
