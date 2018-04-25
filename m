Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6F14B6B000A
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 11:24:25 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s7so2563059pgp.15
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 08:24:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d10si15024997pfn.84.2018.04.25.08.24.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 25 Apr 2018 08:24:24 -0700 (PDT)
Date: Wed, 25 Apr 2018 08:24:22 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH net-next 1/2] tcp: add TCP_ZEROCOPY_RECEIVE support for
 zerocopy receive
Message-ID: <20180425152422.GB27076@infradead.org>
References: <20180425052722.73022-1-edumazet@google.com>
 <20180425052722.73022-2-edumazet@google.com>
 <20180425062859.GA23914@infradead.org>
 <5cd31eba-63b5-9160-0a2e-f441340df0d3@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5cd31eba-63b5-9160-0a2e-f441340df0d3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Eric Dumazet <edumazet@google.com>, "David S . Miller" <davem@davemloft.net>, netdev <netdev@vger.kernel.org>, Andy Lutomirski <luto@kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Soheil Hassas Yeganeh <soheil@google.com>

On Wed, Apr 25, 2018 at 06:01:02AM -0700, Eric Dumazet wrote:
> Thanks Christoph
> 
> Note the high cost of zap_page_range(), needed to avoid -EBUSY being returned
> from vm_insert_page() the second time TCP_ZEROCOPY_RECEIVE is used on one VMA.
> 
> Ideally a vm_replace_page() would avoid this cost ?

No my area of expertise, I'll defer to the MM folks..
