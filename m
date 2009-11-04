Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 62EF96B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 20:47:03 -0500 (EST)
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id nA41kshY003542
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 17:46:54 -0800
Received: from pxi36 (pxi36.prod.google.com [10.243.27.36])
	by zps36.corp.google.com with ESMTP id nA41kp7i011067
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 17:46:52 -0800
Received: by pxi36 with SMTP id 36so387296pxi.2
        for <linux-mm@kvack.org>; Tue, 03 Nov 2009 17:46:51 -0800 (PST)
Date: Tue, 3 Nov 2009 17:46:48 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] page allocator: Do not allow interrupts to use
 ALLOC_HARDER
In-Reply-To: <alpine.DEB.1.10.0911031208150.21943@V090114053VZO-1>
Message-ID: <alpine.DEB.2.00.0911031739380.1187@chino.kir.corp.google.com>
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <1256650833-15516-3-git-send-email-mel@csn.ul.ie> <20091027130924.fa903f5a.akpm@linux-foundation.org> <alpine.DEB.2.00.0910271411530.9183@chino.kir.corp.google.com> <20091031184054.GB1475@ucw.cz>
 <alpine.DEB.2.00.0910311248490.13829@chino.kir.corp.google.com> <20091031201158.GB29536@elf.ucw.cz> <4AECCF6A.4020206@redhat.com> <alpine.DEB.1.10.0911021139100.24535@V090114053VZO-1> <alpine.DEB.2.00.0911021249470.22525@chino.kir.corp.google.com>
 <alpine.DEB.1.10.0911031208150.21943@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Pavel Machek <pavel@ucw.cz>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Stephan von Krawczynski <skraw@ithnet.com>, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 3 Nov 2009, Christoph Lameter wrote:

> If you dont know what "realtime" is then we cannot really implement
> "realtime" behavior in the page allocator.
> 

It's not intended to implement realtime behavior!

This is a convenience given to rt_task() to reduce latency when possible 
by avoiding direct reclaim and allowing background reclaim to bring us 
back over the low watermark.

That's been in the page allocator for over four years and is not intended 
to implement realtime behavior.  These tasks do not rely on memory 
reserves being available.

Is it really hard to believe that tasks with such high priorities are 
given an exemption in the page allocator so that we reclaim in the 
background instead of directly?

I hope we can move this to another thread if people would like to remove 
this exemption completely instead of talking about this trivial fix, which 
I doubt there's any objection to.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
