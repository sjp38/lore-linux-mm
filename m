Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAH8Mjp6026604
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 17 Nov 2008 17:22:46 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A98A845DD7B
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 17:22:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8811A45DD78
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 17:22:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B1681DB8038
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 17:22:45 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2862C1DB8037
	for <linux-mm@kvack.org>; Mon, 17 Nov 2008 17:22:42 +0900 (JST)
Date: Mon, 17 Nov 2008 17:22:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: evict streaming IO cache first
Message-Id: <20081117172202.343e1b35.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <2f11576a0811162303t51609098o6cd765c04d791581@mail.gmail.com>
References: <20081115181748.3410.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081115210039.537f59f5.akpm@linux-foundation.org>
	<alpine.LFD.2.00.0811161013270.3468@nehalem.linux-foundation.org>
	<49208E9A.5080801@redhat.com>
	<20081116204720.1b8cbe18.akpm@linux-foundation.org>
	<20081117153012.51ece88f.kamezawa.hiroyu@jp.fujitsu.com>
	<2f11576a0811162239w58555c6dq8a61ec184b22bd52@mail.gmail.com>
	<20081117155417.5cc63907.kamezawa.hiroyu@jp.fujitsu.com>
	<2f11576a0811162303t51609098o6cd765c04d791581@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Gene Heskett <gene.heskett@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, 17 Nov 2008 16:03:48 +0900
"KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com> wrote:
> > How about resetting zone->recent_scanned/rotated to be some value calculated from
> > INACTIVE_ANON/INACTIVE_FILE at some time (when the system is enough idle) ?
> 
> in get_scan_ratio()
> 
But active/inactive ratio (and mapped_ratio) is not handled there.

Follwoing 2 will return the same scan ratio.
==case 1==
  active_anon = 480M
  inactive_anon = 32M
  active_file = 2M
  inactive_file = 510M

==case 2==
  active_anon = 480M
  inactive_anon = 32M
  active_file = 480M
  inactive_file = 32M
==



-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
