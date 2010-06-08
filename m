Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E9C326B01C4
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 15:09:27 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o58J9OYA018633
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 12:09:24 -0700
Received: from pwi4 (pwi4.prod.google.com [10.241.219.4])
	by wpaz33.hot.corp.google.com with ESMTP id o58J9MGv003779
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 12:09:23 -0700
Received: by pwi4 with SMTP id 4so316938pwi.1
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 12:09:22 -0700 (PDT)
Date: Tue, 8 Jun 2010 12:09:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 03/10] oom: rename badness() to oom_badness()
In-Reply-To: <20100608205536.7683.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081208010.23776@chino.kir.corp.google.com>
References: <20100608204621.767A.A69D9226@jp.fujitsu.com> <20100608205536.7683.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

> badness() is wrong name because it's too generic name.
> 
> rename it.
> 

This is already renamed in my heuristic rewrite which we all agree, in 
principle, is needed.  I'm really confused that you're trying to take 
little bits and pieces of my work like this, using my name for the 
function in this case, for example, and not working with other developers 
in reviewing their work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
