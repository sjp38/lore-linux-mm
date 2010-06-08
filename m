Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 594FF6B01D7
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 14:57:54 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id o58IvlUg019520
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:57:47 -0700
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by hpaq13.eem.corp.google.com with ESMTP id o58IvjdL007721
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 11:57:46 -0700
Received: by pxi10 with SMTP id 10so2742822pxi.7
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 11:57:45 -0700 (PDT)
Date: Tue, 8 Jun 2010 11:57:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 13/18] oom: remove special handling for pagefault ooms
In-Reply-To: <20100608203659.7675.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006081157050.18848@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com> <alpine.DEB.2.00.1006061526120.32225@chino.kir.corp.google.com> <20100608203659.7675.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010, KOSAKI Motohiro wrote:

> this one is already there in my patch kit.
> 

I think you need a reality check in your position as a kernel hacker and 
not a kernel maintainer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
