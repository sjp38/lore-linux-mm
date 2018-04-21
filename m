Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5EA736B0005
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 05:07:31 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z20so5961195pfn.11
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 02:07:31 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c2-v6si3961915plb.77.2018.04.21.02.07.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 21 Apr 2018 02:07:27 -0700 (PDT)
Date: Sat, 21 Apr 2018 02:07:22 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH net-next 0/4] mm,tcp: provide mmap_hook to solve lockdep
 issue
Message-ID: <20180421090722.GA11998@infradead.org>
References: <20180420155542.122183-1-edumazet@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180420155542.122183-1-edumazet@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>
Cc: "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Soheil Hassas Yeganeh <soheil@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri, Apr 20, 2018 at 08:55:38AM -0700, Eric Dumazet wrote:
> This patch series provide a new mmap_hook to fs willing to grab
> a mutex before mm->mmap_sem is taken, to ensure lockdep sanity.
> 
> This hook allows us to shorten tcp_mmap() execution time (while mmap_sem
> is held), and improve multi-threading scalability. 

Missing CC to linu-fsdevel and linux-mm that will have to decide.

We've rejected this approach multiple times before, so you better
make a really good argument for it.

introducing a multiplexer that overloads a single method certainly
doesn't help making that case.
