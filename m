Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 055286B0078
	for <linux-mm@kvack.org>; Wed,  8 Jun 2011 21:49:16 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4B0373EE0AE
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 10:49:13 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3550B45DE68
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 10:49:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E51F45DE61
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 10:49:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 12C9EE08002
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 10:49:13 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C685FE08001
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 10:49:12 +0900 (JST)
Date: Thu, 9 Jun 2011 10:42:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] [BUGFIX] Avoid getting nid from invalid struct page at
 page_cgroup allocation (as Re: [Bugme-new] [Bug 36192] New: Kernel panic
 when boot the 2.6.39+ kernel based off of 2.6.32 kernel
Message-Id: <20110609104213.ac276d04.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110609100434.64898575.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110607084530.8ee571aa.kamezawa.hiroyu@jp.fujitsu.com>
	<20110607084530.GI5247@suse.de>
	<20110607174355.fde99297.kamezawa.hiroyu@jp.fujitsu.com>
	<20110607090900.GK5247@suse.de>
	<20110607183302.666115f1.kamezawa.hiroyu@jp.fujitsu.com>
	<20110607101857.GM5247@suse.de>
	<20110608084034.29f25764.kamezawa.hiroyu@jp.fujitsu.com>
	<20110608094219.823c24f7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110608074350.GP5247@suse.de>
	<20110608174505.e4be46d6.kamezawa.hiroyu@jp.fujitsu.com>
	<20110608101511.GD17886@cmpxchg.org>
	<20110609100434.64898575.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, qcui@redhat.com, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Li Zefan <lizf@cn.fujitsu.com>

On Thu, 9 Jun 2011 10:04:34 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 8 Jun 2011 12:15:11 +0200
> Johannes Weiner <hannes@cmpxchg.org> wrote:

> Thank you for review.

updated.
==
