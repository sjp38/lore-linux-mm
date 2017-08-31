Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2AE6B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 13:52:40 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id x29so911847qtc.6
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 10:52:40 -0700 (PDT)
Received: from mail-qk0-x22f.google.com (mail-qk0-x22f.google.com. [2607:f8b0:400d:c09::22f])
        by mx.google.com with ESMTPS id m124si8069666qkf.48.2017.08.31.10.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Aug 2017 10:52:39 -0700 (PDT)
Received: by mail-qk0-x22f.google.com with SMTP id l65so1662604qkc.0
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 10:52:39 -0700 (PDT)
Date: Thu, 31 Aug 2017 13:52:35 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH v3 4/5] cramfs: add mmap support
In-Reply-To: <20170831092338.GA8196@infradead.org>
Message-ID: <nycvar.YSQ.7.76.1708311343060.2606@knanqh.ubzr>
References: <20170831030932.26979-1-nicolas.pitre@linaro.org> <20170831030932.26979-5-nicolas.pitre@linaro.org> <20170831092338.GA8196@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>, linux-mm@kvack.org

On Thu, 31 Aug 2017, Christoph Hellwig wrote:

> The whole VMA games here look entirely bogus  you can't just drop
> and reacquire mmap_sem for example.
> And splitting vmas looks just
> as promblematic.

I didn't just decide to do that on a whim. I spent quite some time 
looking at page fault code paths and make sure it is fine to reaquire 
the lock. There are existing code paths that drop the lock entirely and 
return with no locks so this is already expected by the core code.

> As a minimum you really must see the linux-mm list can get some
> feedback there.

Good point. You added linux-mm to CC so I'll wait for their comments.


Nicolas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
