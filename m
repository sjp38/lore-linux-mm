Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BF42E6B0003
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 20:41:37 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w17so7106217pfn.17
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 17:41:37 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n3-v6si8947489pld.172.2018.04.14.17.41.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 14 Apr 2018 17:41:36 -0700 (PDT)
Date: Sat, 14 Apr 2018 17:41:34 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: repeatable boot randomness inside KVM guest
Message-ID: <20180415004134.GB15294@bombadil.infradead.org>
References: <20180414195921.GA10437@avx2>
 <20180414224419.GA21830@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180414224419.GA21830@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Theodore Y. Ts'o" <tytso@mit.edu>, Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Apr 14, 2018 at 06:44:19PM -0400, Theodore Y. Ts'o wrote:
> What needs to happen is freelist should get randomized much later in
> the boot sequence.  Doing it later will require locking; I don't know
> enough about the slab/slub code to know whether the slab_mutex would
> be sufficient, or some other lock might need to be added.

Could we have the bootloader pass in some initial randomness?
