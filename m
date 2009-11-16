Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E8BC56B004D
	for <linux-mm@kvack.org>; Mon, 16 Nov 2009 18:34:52 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAGNYowA017435
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 17 Nov 2009 08:34:50 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 00E9B45DE53
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 08:34:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CF1C245DE4D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 08:34:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B6B0BE38006
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 08:34:49 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 62E2FE38008
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 08:34:49 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/6] mm: mlocking in try_to_unmap_one
In-Reply-To: <Pine.LNX.4.64.0911152209350.29917@sister.anvils>
References: <20091113151554.33C2.A69D9226@jp.fujitsu.com> <Pine.LNX.4.64.0911152209350.29917@sister.anvils>
Message-Id: <20091117083403.3DAE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 17 Nov 2009 08:34:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Fri, 13 Nov 2009, KOSAKI Motohiro wrote:
> > 
> > Very small nit. How about this?
> 
> Yes, that takes it a stage further, I prefer that, thanks: but better
> redo against mmotm, I removed the "MLOCK_PAGES && " in a later patch.

Ah, yes.
thanks.

I'll redo.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
