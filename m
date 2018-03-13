Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id E5B8F6B026F
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 10:31:04 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id v89so14903875qte.21
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 07:31:04 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id c25si279211qkm.448.2018.03.13.07.31.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 07:31:04 -0700 (PDT)
Date: Tue, 13 Mar 2018 10:31:00 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC PATCH 00/13] SVM (share virtual memory) with HMM in nouveau
Message-ID: <20180313143100.GC3828@redhat.com>
References: <20180310032141.6096-1-jglisse@redhat.com>
 <cae53b72-f99c-7641-8cb9-5cbe0a29b585@gmail.com>
 <20180312173009.GN8589@phenom.ffwll.local>
 <20180312175057.GC4214@redhat.com>
 <39139ff7-76ad-960c-53f6-46b57525b733@nvidia.com>
 <20180313132940.GB3304@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180313132940.GB3304@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: John Hubbard <jhubbard@nvidia.com>, christian.koenig@amd.com, dri-devel@lists.freedesktop.org, nouveau@lists.freedesktop.org, Evgeny Baskakov <ebaskakov@nvidia.com>, linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>, Felix Kuehling <felix.kuehling@amd.com>, "Bridgman, John" <John.Bridgman@amd.com>

On Tue, Mar 13, 2018 at 06:29:40AM -0700, Matthew Wilcox wrote:
> On Mon, Mar 12, 2018 at 11:14:47PM -0700, John Hubbard wrote:
> > Yes, on NVIDIA GPUs, the Host/FIFO unit is limited to 40-bit addresses, so
> > things such as the following need to be below (1 << 40), and also accessible 
> > to both CPU (user space) and GPU hardware. 
> >     -- command buffers (CPU user space driver fills them, GPU consumes them), 
> >     -- semaphores (here, a GPU-centric term, rather than OS-type: these are
> >        memory locations that, for example, the GPU hardware might write to, in
> >        order to indicate work completion; there are other uses as well), 
> >     -- a few other things most likely (this is not a complete list).
> 
> Is that a 40-bit virtual address limit or physical address limit?  I'm
> no longer sure who is addressing what memory through what mechanism ;-)
> 

Virtual address limit, those object get mapped into GPU page table but
the register/structure fields where you program those object's address
only are 32bits (the virtual address is shifted by 8bits for alignment).

Cheers,
Jerome
