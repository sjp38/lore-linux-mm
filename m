Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 495316B02AC
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 09:29:44 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s25so7455582pfh.9
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 06:29:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u191si117955pgc.725.2018.03.13.06.29.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Mar 2018 06:29:43 -0700 (PDT)
Date: Tue, 13 Mar 2018 06:29:40 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC PATCH 00/13] SVM (share virtual memory) with HMM in nouveau
Message-ID: <20180313132940.GB3304@bombadil.infradead.org>
References: <20180310032141.6096-1-jglisse@redhat.com>
 <cae53b72-f99c-7641-8cb9-5cbe0a29b585@gmail.com>
 <20180312173009.GN8589@phenom.ffwll.local>
 <20180312175057.GC4214@redhat.com>
 <39139ff7-76ad-960c-53f6-46b57525b733@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39139ff7-76ad-960c-53f6-46b57525b733@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, christian.koenig@amd.com, dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org, Evgeny Baskakov <ebaskakov@nvidia.com>, linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>, Felix Kuehling <felix.kuehling@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>

On Mon, Mar 12, 2018 at 11:14:47PM -0700, John Hubbard wrote:
> Yes, on NVIDIA GPUs, the Host/FIFO unit is limited to 40-bit addresses, so
> things such as the following need to be below (1 << 40), and also accessible 
> to both CPU (user space) and GPU hardware. 
>     -- command buffers (CPU user space driver fills them, GPU consumes them), 
>     -- semaphores (here, a GPU-centric term, rather than OS-type: these are
>        memory locations that, for example, the GPU hardware might write to, in
>        order to indicate work completion; there are other uses as well), 
>     -- a few other things most likely (this is not a complete list).

Is that a 40-bit virtual address limit or physical address limit?  I'm
no longer sure who is addressing what memory through what mechanism ;-)
