Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 285DE6B0257
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 10:45:02 -0500 (EST)
Received: by wmww144 with SMTP id w144so145823807wmw.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 07:45:01 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id b83si24390830wme.104.2015.12.07.07.45.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 07:45:01 -0800 (PST)
Date: Mon, 7 Dec 2015 16:44:59 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: kernel BUG at mm/filemap.c:238! (4.4.0-rc4)
Message-ID: <20151207154459.GC6356@twins.programming.kicks-ass.net>
References: <5665703F.4090302@redhat.com>
 <5665A346.4030403@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5665A346.4030403@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>

On Mon, Dec 07, 2015 at 04:18:30PM +0100, Jan Stancek wrote:
> So, according to bisect first bad commit is:
> 
> commit 68985633bccb6066bf1803e316fbc6c1f5b796d6
> Author: Peter Zijlstra <peterz@infradead.org>
> Date:   Tue Dec 1 14:04:04 2015 +0100
> 
>     sched/wait: Fix signal handling in bit wait helpers
> 
> which seems to me is only exposing problem elsewhere.
> 

Nope, I think I messed that up, just not sure how to fix it proper then.
Let me have a ponder.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
