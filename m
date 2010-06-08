Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id DEB0E6B01DE
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 15:07:32 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id o58J7UF6007459
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 12:07:30 -0700
Received: from pwj5 (pwj5.prod.google.com [10.241.219.69])
	by hpaq1.eem.corp.google.com with ESMTP id o58J7Skq016650
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 12:07:29 -0700
Received: by pwj5 with SMTP id 5so3391857pwj.5
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 12:07:28 -0700 (PDT)
Date: Tue, 8 Jun 2010 12:07:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 06/10] oom: cleanup has_intersects_mems_allowed()
In-Reply-To: <20100608205829.768C.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081206090.23776@chino.kir.corp.google.com>
References: <20100608204621.767A.A69D9226@jp.fujitsu.com> <20100608205829.768C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

> Now has_intersects_mems_allowed() has own thread iterate logic, but
> it should use while_each_thread().
> 
> It slightly improve the code readability.
> 

These cleanups should be done on top of my oom killer rewrite instead, 
please work with others in their work instead of getting in the way of it 
time and time again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
