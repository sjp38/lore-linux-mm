Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id D0E9C6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 02:46:13 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id va8so125875obc.0
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 23:46:13 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id s138si2720937ois.16.2015.01.21.23.46.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 21 Jan 2015 23:46:12 -0800 (PST)
Message-ID: <1421912761.4903.22.camel@stgolabs.net>
Subject: Re: [PATCH] mm, vmacache: Add kconfig VMACACHE_SHIFT
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Wed, 21 Jan 2015 23:46:01 -0800
In-Reply-To: <1421908189-18938-1-git-send-email-chaowang@redhat.com>
References: <1421908189-18938-1-git-send-email-chaowang@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: WANG Chao <chaowang@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2015-01-22 at 14:29 +0800, WANG Chao wrote:
> Add a new kconfig option VMACACHE_SHIFT (as a power of 2) to specify the
> number of slots vma cache has for each thread. Range is chosen 0-4 (1-16
> slots) to consider both overhead and performance penalty. Default is 2
> (4 slots) as it originally is, which provides good enough balance.
> 

Nack. I don't feel comfortable making scalability features of core code
configurable.

Thanks,
Davidlohr



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
