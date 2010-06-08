Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8D7026B01EF
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 07:53:37 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o58BrZSc017257
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Jun 2010 20:53:36 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8DFA445DE4F
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:53:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FEDB45DE4D
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:53:35 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 457F91DB803F
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:53:35 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 053D4E08001
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:53:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [0/10] 3rd pile of OOM patch series 
Message-Id: <20100608204621.767A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  8 Jun 2010 20:53:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

This is 3rd pile of collection of OOM patches.
I think they don't immix anyone objected patch. but please double check.


=====================================================================
 Documentation/sysctl/vm.txt |    2 +-
 fs/proc/base.c              |    4 +-
 include/linux/mempolicy.h   |   13 +++-
 include/linux/oom.h         |    8 ++
 kernel/sysctl.c             |    4 +-
 mm/mempolicy.c              |   44 ++++++++++++
 mm/oom_kill.c               |  156 ++++++++++++++++++++++---------------------
 7 files changed, 146 insertions(+), 85 deletions(-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
