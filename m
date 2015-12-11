Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 82AC16B0253
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 17:33:02 -0500 (EST)
Received: by padhk6 with SMTP id hk6so31720644pad.2
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:33:02 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bf7si3784542pad.239.2015.12.11.14.33.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Dec 2015 14:33:01 -0800 (PST)
Date: Fri, 11 Dec 2015 14:33:00 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/6] mm: Add vm_insert_pfn_prot
Message-Id: <20151211143300.0ac516fbd219a67954698f9a@linux-foundation.org>
In-Reply-To: <c35a9ff9b8ef452964adbf3d828edceff45b70a8.1449803537.git.luto@kernel.org>
References: <cover.1449803537.git.luto@kernel.org>
	<c35a9ff9b8ef452964adbf3d828edceff45b70a8.1449803537.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 10 Dec 2015 19:21:43 -0800 Andy Lutomirski <luto@kernel.org> wrote:

> The x86 vvar mapping contains pages with differing cacheability
> flags.  This is currently only supported using (io_)remap_pfn_range,
> but those functions can't be used inside page faults.

Foggy.  What does "support" mean here?

> Add vm_insert_pfn_prot to support varying cacheability within the
> same non-COW VMA in a more sane manner.

Here, "support" presumably means "insertion of pfns".  Can we spell all
this out more completely please?

> x86 needs this to avoid a CRIU-breaking and memory-wasting explosion
> of VMAs when supporting userspace access to the HPET.
> 

OtherwiseAck.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
