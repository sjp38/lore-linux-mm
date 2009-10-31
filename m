Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E4A546B004D
	for <linux-mm@kvack.org>; Sat, 31 Oct 2009 15:51:27 -0400 (EDT)
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id n9VJpK4t023048
	for <linux-mm@kvack.org>; Sat, 31 Oct 2009 19:51:21 GMT
Received: from pwj11 (pwj11.prod.google.com [10.241.219.75])
	by zps78.corp.google.com with ESMTP id n9VJpHaq018279
	for <linux-mm@kvack.org>; Sat, 31 Oct 2009 12:51:18 -0700
Received: by pwj11 with SMTP id 11so1216266pwj.0
        for <linux-mm@kvack.org>; Sat, 31 Oct 2009 12:51:17 -0700 (PDT)
Date: Sat, 31 Oct 2009 12:51:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] page allocator: Do not allow interrupts to use
 ALLOC_HARDER
In-Reply-To: <20091031184054.GB1475@ucw.cz>
Message-ID: <alpine.DEB.2.00.0910311248490.13829@chino.kir.corp.google.com>
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <1256650833-15516-3-git-send-email-mel@csn.ul.ie> <20091027130924.fa903f5a.akpm@linux-foundation.org> <alpine.DEB.2.00.0910271411530.9183@chino.kir.corp.google.com>
 <20091031184054.GB1475@ucw.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pavel Machek <pavel@ucw.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 31 Oct 2009, Pavel Machek wrote:

> > Giving rt tasks access to memory reserves is necessary to reduce latency, 
> > the privilege does not apply to interrupts that subsequently get run on 
> > the same cpu.
> 
> If rt task needs to allocate memory like that, then its broken,
> anyway...
> 

Um, no, it's a matter of the kernel implementation.  We allow such tasks 
to allocate deeper into reserves to avoid the page allocator from 
incurring a significant penalty when direct reclaim is required.  
Background reclaim has already commenced at this point in the slowpath.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
