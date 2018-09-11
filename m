Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id ADB858E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 13:56:13 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id v9-v6so11879603ply.13
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 10:56:13 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id v6-v6si16245096plp.434.2018.09.11.10.55.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 10:55:58 -0700 (PDT)
Date: Tue, 11 Sep 2018 11:55:55 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v3 3/3] docs: core-api: add memory allocation guide
Message-ID: <20180911115555.5fce5631@lwn.net>
In-Reply-To: <1534517236-16762-4-git-send-email-rppt@linux.vnet.ibm.com>
References: <1534517236-16762-1-git-send-email-rppt@linux.vnet.ibm.com>
	<1534517236-16762-4-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

Sorry for being so slow to get to this...it fell into a dark crack in my
rickety email folder hierarchy.  I do have one question...

On Fri, 17 Aug 2018 17:47:16 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> +    ``GFP_HIGHUSER_MOVABLE`` does not require that allocated memory
> +    will be directly accessible by the kernel or the hardware and
> +    implies that the data is movable.
> +
> +    ``GFP_HIGHUSER`` means that the allocated memory is not movable,
> +    but it is not required to be directly accessible by the kernel or
> +    the hardware. An example may be a hardware allocation that maps
> +    data directly into userspace but has no addressing limitations.
> +
> +    ``GFP_USER`` means that the allocated memory is not movable and it
> +    must be directly accessible by the kernel or the hardware. It is
> +    typically used by hardware for buffers that are mapped to
> +    userspace (e.g. graphics) that hardware still must DMA to.

I realize that this is copied from elsewhere, but still...as I understand
it, the "HIGH" part means that the allocation can be satisfied from high
memory, nothing more.  So...it's irrelevant on 64-bit machines to start
with, right?  And it has nothing to do with DMA, I would think.  That would
be handled by the DMA infrastructure and, perhaps, the DMA* zones.  Right?

I ask because high memory is an artifact of how things are laid out on
32-bit systems; hardware can often DMA quite easily into memory that the
kernel sees as "high".  So, to me, this description seems kind of
confusing; I wouldn't mention hardware at all.  But maybe I'm missing
something?

Thanks,

jon
