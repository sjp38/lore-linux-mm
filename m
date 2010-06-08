Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 26F4C6B01CA
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 15:10:07 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o58JA1np027650
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 12:10:02 -0700
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by kpbe11.cbf.corp.google.com with ESMTP id o58JA0xP015106
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 12:10:01 -0700
Received: by pwi10 with SMTP id 10so2092790pwi.39
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 12:10:00 -0700 (PDT)
Date: Tue, 8 Jun 2010 12:09:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 02/10] oom: remove verbose argument from
 __oom_kill_process()
In-Reply-To: <20100608205454.7680.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081209330.23776@chino.kir.corp.google.com>
References: <20100608204621.767A.A69D9226@jp.fujitsu.com> <20100608205454.7680.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

> Now, verbose argument is unused. This patch remove it.
> 

This is already done in my oom killer rewrite, please work with other 
developers in developing their work instead of acting as a maintainer, 
which you aren't.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
