Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id F08F86B0072
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 18:12:55 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id rd3so44301456pab.9
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 15:12:55 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l12si11449877pdm.243.2015.01.29.15.12.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jan 2015 15:12:55 -0800 (PST)
Date: Thu, 29 Jan 2015 15:12:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 13/17] mm: vmalloc: add flag preventing guard hole
 allocation
Message-Id: <20150129151254.edc75e5ae20c3cafb55d88b1@linux-foundation.org>
In-Reply-To: <1422544321-24232-14-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-14-git-send-email-a.ryabinin@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org

On Thu, 29 Jan 2015 18:11:57 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

> For instrumenting global variables KASan will shadow memory
> backing memory for modules. So on module loading we will need
> to allocate shadow memory and map it at exact virtual address.

I don't understand.  What does "map it at exact virtual address" mean?

> __vmalloc_node_range() seems like the best fit for that purpose,
> except it puts a guard hole after allocated area.

Why is the guard hole a problem?

More details needed in this changelog, please.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
