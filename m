Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 396CB6B021B
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 03:37:57 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o517btJB014113
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 1 Jun 2010 16:37:55 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E53E545DE50
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:37:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id C939645DE4E
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:37:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B135FE08005
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:37:54 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CE4BE08001
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 16:37:54 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 10/18] oom: deprecate oom_adj tunable
In-Reply-To: <alpine.DEB.2.00.1006010015350.29202@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com> <alpine.DEB.2.00.1006010015350.29202@chino.kir.corp.google.com>
Message-Id: <20100601163739.2463.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  1 Jun 2010 16:37:53 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> /proc/pid/oom_adj is now deprecated so that that it may eventually be
> removed.  The target date for removal is May 2012.
> 
> A warning will be printed to the kernel log if a task attempts to use this
> interface.  Future warning will be suppressed until the kernel is rebooted
> to prevent spamming the kernel log.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  Documentation/feature-removal-schedule.txt |   25 +++++++++++++++++++++++++
>  Documentation/filesystems/proc.txt         |    3 +++
>  fs/proc/base.c                             |    8 ++++++++
>  include/linux/oom.h                        |    3 +++
>  4 files changed, 39 insertions(+), 0 deletions(-)

nack



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
