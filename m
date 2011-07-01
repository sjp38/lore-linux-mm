Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F2FC76B004A
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 20:28:05 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9A24C3EE0BD
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 09:28:02 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7978845DEAD
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 09:28:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EEDB45DEA6
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 09:28:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 507821DB8043
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 09:28:02 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 049AB1DB803C
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 09:28:02 +0900 (JST)
Date: Fri, 1 Jul 2011 09:20:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [Cleanup] memcg: export memory cgroup's swappiness v2
Message-Id: <20110701092059.be4400f7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110701085013.4e8cbb02.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110629190325.28aa2dc6.kamezawa.hiroyu@jp.fujitsu.com>
	<20110630130134.63a1dd37.akpm@linux-foundation.org>
	<20110701085013.4e8cbb02.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>

On Fri, 1 Jul 2011 08:50:13 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 30 Jun 2011 13:01:34 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:

> Ok, I'll check it. Maybe I miss !CONFIG_SWAP...
> 

v4 here. Thank you for pointing out. I could think of several ways but
maybe this one is good because using vm_swappines with !CONFIG_SWAP seems
to be a bug.
tested with allyesconfig/allnoconfig.
==
