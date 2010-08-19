Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 15B746B0204
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 16:35:57 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id o7JKZxaG007302
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 13:35:59 -0700
Received: from pzk3 (pzk3.prod.google.com [10.243.19.131])
	by hpaq13.eem.corp.google.com with ESMTP id o7JKZqSX025076
	for <linux-mm@kvack.org>; Thu, 19 Aug 2010 13:35:58 -0700
Received: by pzk3 with SMTP id 3so1042760pzk.36
        for <linux-mm@kvack.org>; Thu, 19 Aug 2010 13:35:58 -0700 (PDT)
Date: Thu, 19 Aug 2010 13:35:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] oom: fix NULL pointer dereference
In-Reply-To: <20100819195310.5FC7.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1008191335370.18994@chino.kir.corp.google.com>
References: <20100819194707.5FC4.A69D9226@jp.fujitsu.com> <20100819195310.5FC7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 19 Aug 2010, KOSAKI Motohiro wrote:

> commit b940fd7035 (oom: remove unnecessary code and cleanup) added
> unnecessary NULL pointer dereference. remove it.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
