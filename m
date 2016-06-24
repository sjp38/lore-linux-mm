Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 46BAE6B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 16:58:41 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ts6so88739534pac.1
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 13:58:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fj3si8805079pab.156.2016.06.24.13.58.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jun 2016 13:58:40 -0700 (PDT)
Date: Fri, 24 Jun 2016 13:58:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/compaction: remove unnecessary order check in
 try_to_compact_pages()
Message-Id: <20160624135839.d27727e6ba9ab4b4aff0cc32@linux-foundation.org>
In-Reply-To: <576115DC.5030601@linux.vnet.ibm.com>
References: <1465973568-3496-1-git-send-email-opensource.ganesh@gmail.com>
	<576115DC.5030601@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Ganesh Mahendran <opensource.ganesh@gmail.com>, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mhocko@suse.com, mina86@mina86.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 15 Jun 2016 14:16:20 +0530 Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:

> On 06/15/2016 12:22 PM, Ganesh Mahendran wrote:
> > The caller __alloc_pages_direct_compact() already check (order == 0).
> > So no need to check again.
> 
> Yeah, the caller (__alloc_pages_direct_compact) checks if the order of
> allocation is 0. But we can remove it there and keep it in here as this
> is the actual entry point for direct page compaction.

I think the check in __alloc_pages_direct_compact() is OK - it's a bit
silly to do a (small) bunch of additional work in
__alloc_pages_direct_compact() when orer==0.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
