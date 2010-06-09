Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4A7A06B01B0
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 23:59:15 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o593x9oB012270
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 20:59:10 -0700
Received: from pwi1 (pwi1.prod.google.com [10.241.219.1])
	by kpbe11.cbf.corp.google.com with ESMTP id o593x7TY006293
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 20:59:07 -0700
Received: by pwi1 with SMTP id 1so1036004pwi.23
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 20:59:07 -0700 (PDT)
Date: Tue, 8 Jun 2010 20:59:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 0/6] oom: various tiny cleanups and fixes
Message-ID: <alpine.DEB.2.00.1006082053130.6219@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patchset contains some various tiny cleanups and fixes that were all 
identified by akpm during his review of the oom killer rewrite patches 
that he's merged thus far.

A few of them are fixes intended to be folded into the patch that 
introduced the code (those that are of the same name and suffixed with 
"fix" :) and a few of them are standalone improvements.

Based on mmotm-2010-06-03-16-36 with the oom patches merged on June 8.  
Since these patches only touch mm/oom_kill.c, no conflicts are expected in 
the actual "mm of the moment".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
