Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id AAE966B0007
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 13:32:58 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w1-v6so10215366plq.8
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 10:32:58 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id a24-v6si8352375pgv.527.2018.07.02.10.32.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 10:32:57 -0700 (PDT)
Date: Mon, 2 Jul 2018 11:32:55 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v2 00/11] docs/mm: add boot time memory management docs
Message-ID: <20180702113255.1f7504e2@lwn.net>
In-Reply-To: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Sat, 30 Jun 2018 17:54:55 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> Both bootmem and memblock have pretty good documentation coverage. With
> some fixups and additions we get a nice overall description.
> 
> v2 changes:
> * address Randy's comments
> 
> Mike Rapoport (11):
>   mm/bootmem: drop duplicated kernel-doc comments
>   docs/mm: nobootmem: fixup kernel-doc comments
>   docs/mm: bootmem: fix kernel-doc warnings
>   docs/mm: bootmem: add kernel-doc description of 'struct bootmem_data'
>   docs/mm: bootmem: add overview documentation
>   mm/memblock: add a name for memblock flags enumeration
>   docs/mm: memblock: update kernel-doc comments
>   docs/mm: memblock: add kernel-doc comments for memblock_add[_node]
>   docs/mm: memblock: add kernel-doc description for memblock types
>   docs/mm: memblock: add overview documentation
>   docs/mm: add description of boot time memory management

So this seems like good stuff overall.  It digs pretty deeply into the mm
code, though, so I'm a little reluctant to apply it without an ack from an
mm developer.  Alternatively, I'm happy to step back if Andrew wants to
pick the set up.

Thanks,

jon
