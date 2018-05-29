Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BAD476B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 08:19:00 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v12-v6so10477913wmc.1
        for <linux-mm@kvack.org>; Tue, 29 May 2018 05:19:00 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.187])
        by mx.google.com with ESMTPS id i25-v6si7697316wmb.67.2018.05.29.05.18.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 May 2018 05:18:59 -0700 (PDT)
Date: Tue, 29 May 2018 13:18:57 +0100 (BST)
From: Justin Skists <justin.skists@juzza.co.uk>
Message-ID: <1478759754.17398.1527596337445@email.1and1.co.uk>
In-Reply-To: <20180529113725.GB13092@rapoport-lnx>
References: <20180529113725.GB13092@rapoport-lnx>
Subject: Re: [PATCH] docs/admin-guide/mm: add high level concepts overview
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>, Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> On 29 May 2018 at 12:37 Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> 

> +=================
> +Concepts overview
> +=================
> +
> +The memory management in Linux is complex system that evolved over the
> +years and included more and more functionality to support variety of
> +systems from MMU-less microcontrollers to supercomputers. The memory
> +management for systems without MMU is called ``nommu`` and it
> +definitely deserves a dedicated document, which hopefully will be
> +eventually written. Yet, although some of the concepts are the same,
> +here we assume that MMU is available and CPU can translate a virtual
> +address to a physical address.
> +
> +.. contents:: :local:
> +
> +Virtual Memory Primer
> +=====================
> +
> +The physical memory in a computer system is a limited resource and
> +even for systems that support memory hotplug there is a hard limit on
> +the amount of memory that can be installed. The physical memory is not
> +necessary contiguous, it might be accessible as a set of distinct
> +address ranges. Besides, different CPU architectures, and even
> +different implementations of the same architecture have different view
> +how these address ranges defined.
> +
> +All this makes dealing directly with physical memory quite complex and
> +to avoid this complexity a concept of virtual memory was developed.
> +
> +The virtual memory abstracts the details of physical memory from the
> +application software, allows to keep only needed information in the
> +physical memory (demand paging) and provides a mechanism for the
> +protection and controlled sharing of data between processes.
> +
> +With virtual memory, each and every memory access uses a virtual
> +address. When the CPU decodes the an instruction that reads (or
> +writes) from (or to) the system memory, it translates the `virtual`
> +address encoded in that instruction to a `physical` address that the
> +memory controller can understand.

I spotted an errant "the an" in that paragraph.

I would rewrite that sentence as "When the CPU decodes an instruction that
reads from (or writes to) the system memory," ...

The rest of the document looks good to me, and a nice overview.


Best regards,
Justin.
