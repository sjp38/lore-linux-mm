Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id CEFB483292
	for <linux-mm@kvack.org>; Tue, 23 May 2017 18:05:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l73so180339971pfj.8
        for <linux-mm@kvack.org>; Tue, 23 May 2017 15:05:29 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y193si21925475pgd.41.2017.05.23.15.05.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 15:05:29 -0700 (PDT)
Date: Tue, 23 May 2017 15:05:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [HMM 00/15] HMM (Heterogeneous Memory Management) v22
Message-Id: <20170523150526.1b8c11d13f2c9be2ae989ca5@linux-foundation.org>
In-Reply-To: <20170523220248.GA23833@redhat.com>
References: <20170522165206.6284-1-jglisse@redhat.com>
	<20170523220248.GA23833@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Tue, 23 May 2017 18:02:49 -0400 Jerome Glisse <jglisse@redhat.com> wrote:

> Andrew i posted updated patch for 0007 0008 and 0009 as reply to orignal
> patches. It includes changes Dan and Kyrill wanted to see. I added the
> device_private_key to page_alloc.c to avoid modify more than 3 patches
> but if you prefer i can repost a v23 serie and move the static key to
> hmm.c
> 
> Also i guess posting a v23 would have it tested against builder as i
> doubt automatic builder are clever enough to understand all this.
> 

Yes please.  22->23 is less than a 5% increment ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
