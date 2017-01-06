Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A56936B0277
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 17:42:28 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a190so1500913741pgc.0
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 14:42:28 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g188si52082471pfc.136.2017.01.06.14.42.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 14:42:27 -0800 (PST)
Date: Fri, 6 Jan 2017 14:43:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: page_alloc: Skip over regions of invalid pfns where
 possible
Message-Id: <20170106144348.f7d207baa7b3190a95aaeb2e@linux-foundation.org>
In-Reply-To: <20161125185518.29885-1-paul.burton@imgtec.com>
References: <20161125185518.29885-1-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Burton <paul.burton@imgtec.com>
Cc: linux-mm@kvack.org, James Hartley <james.hartley@imgtec.com>, linux-kernel@vger.kernel.org

On Fri, 25 Nov 2016 18:55:18 +0000 Paul Burton <paul.burton@imgtec.com> wrote:

> When using a sparse memory model memmap_init_zone() when invoked with
> the MEMMAP_EARLY context will skip over pages which aren't valid - ie.
> which aren't in a populated region of the sparse memory map. However if
> the memory map is extremely sparse then it can spend a long time
> linearly checking each PFN in a large non-populated region of the memory
> map & skipping it in turn.
> 
> When CONFIG_HAVE_MEMBLOCK_NODE_MAP is enabled, we have sufficient
> information to quickly discover the next valid PFN given an invalid one
> by searching through the list of memory regions & skipping forwards to
> the first PFN covered by the memory region to the right of the
> non-populated region. Implement this in order to speed up
> memmap_init_zone() for systems with extremely sparse memory maps.

Could we have a changelog which includes some timing measurements? 
That permits others to understand the value of this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
