Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 943056B02CF
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 19:14:46 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o7MNEh9g015910
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 16:14:43 -0700
Received: from pwj4 (pwj4.prod.google.com [10.241.219.68])
	by wpaz29.hot.corp.google.com with ESMTP id o7MNEPjZ014424
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 16:14:42 -0700
Received: by pwj4 with SMTP id 4so1107644pwj.7
        for <linux-mm@kvack.org>; Sun, 22 Aug 2010 16:14:42 -0700 (PDT)
Date: Sun, 22 Aug 2010 16:14:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/3 v3] oom: avoid killing a task if a thread sharing
 its mm cannot be killed
In-Reply-To: <20100822184526.600F.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008221613480.28207@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1008201539310.9201@chino.kir.corp.google.com> <alpine.DEB.2.00.1008201541000.9201@chino.kir.corp.google.com> <20100822184526.600F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 22 Aug 2010, KOSAKI Motohiro wrote:

> This seems significantly cleaner than previous. Of cource, even though I need 
> to review [1/3] carefully. Unfortunatelly I'm very busy in this week, then
> my responce might late a while. but it's not mean silinetly nak.
> 

I agree, it's much better than making select_bad_process() turn out to be 
O(n^2) when no threads are OOM_DISABLE.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
