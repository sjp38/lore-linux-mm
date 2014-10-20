Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id D6ED96B0069
	for <linux-mm@kvack.org>; Mon, 20 Oct 2014 19:41:45 -0400 (EDT)
Received: by mail-yh0-f41.google.com with SMTP id i57so163452yha.0
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 16:41:45 -0700 (PDT)
Received: from mail-yh0-x22f.google.com (mail-yh0-x22f.google.com. [2607:f8b0:4002:c01::22f])
        by mx.google.com with ESMTPS id 23si20398955yhg.118.2014.10.20.16.41.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Oct 2014 16:41:45 -0700 (PDT)
Received: by mail-yh0-f47.google.com with SMTP id c41so140584yho.20
        for <linux-mm@kvack.org>; Mon, 20 Oct 2014 16:41:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141020222841.419869904@infradead.org>
References: <20141020215633.717315139@infradead.org>
	<20141020222841.419869904@infradead.org>
Date: Mon, 20 Oct 2014 16:41:45 -0700
Message-ID: <CA+55aFwd04q+O5ejbmDL-H7_GB6DEBMiiHkn+2R1u4uWxfDO9w@mail.gmail.com>
Subject: Re: [RFC][PATCH 4/6] SRCU free VMAs
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Minchan Kim <minchan@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Al Viro <viro@zeniv.linux.org.uk>, Lai Jiangshan <laijs@cn.fujitsu.com>, Davidlohr Bueso <dave@stgolabs.net>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Mon, Oct 20, 2014 at 2:56 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> Manage the VMAs with SRCU such that we can do a lockless VMA lookup.

Can you explain why srcu, and not plain regular rcu?

Especially as you then *note* some of the problems srcu can have.
Making it regular rcu would also seem to make it possible to make the
seqlock be just a seqcount, no?

                  Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
