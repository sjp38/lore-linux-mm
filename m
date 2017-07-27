Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B54766B04CB
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 16:43:28 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v102so36450800wrb.2
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 13:43:28 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u198si2286929wmu.214.2017.07.27.13.43.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 13:43:27 -0700 (PDT)
Date: Thu, 27 Jul 2017 13:43:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] memdelay: memory health metric for systems and
 workloads
Message-Id: <20170727134325.2c8cff2a6dc84e34ae6dc8ab@linux-foundation.org>
In-Reply-To: <20170727153010.23347-1-hannes@cmpxchg.org>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, 27 Jul 2017 11:30:07 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> This patch series implements a fine-grained metric for memory
> health.

I assume some Documentation/ is forthcoming.

Consuming another page flag hurts.  What's our current status there?

I'd be interested in seeing some usage examples.  Perhaps anecdotes
where "we observed problem X so we used memdelay in manner Y and saw
result Z".

I assume that some userspace code which utilizes this interface exists
already.  What's the long-term plan here?  systemd changes?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
