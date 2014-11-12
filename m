Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id F013C6B00E7
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 09:20:35 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id n3so5046883wiv.6
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 06:20:35 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cq2si40279564wjc.73.2014.11.12.06.20.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Nov 2014 06:20:35 -0800 (PST)
Date: Wed, 12 Nov 2014 09:20:22 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: mincore: add hwpoison page handle
Message-ID: <20141112142022.GA29766@phnom.home.cmpxchg.org>
References: <000001cffe2a$66a95a50$33fc0ef0$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000001cffe2a$66a95a50$33fc0ef0$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, mgorman@suse.de, 'Rik van Riel' <riel@redhat.com>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>

On Wed, Nov 12, 2014 at 11:39:29AM +0800, Weijie Yang wrote:
> When encounter pte is a swap entry, the current code handles two cases:
> migration and normal swapentry, but we have a third case: hwpoison page.
> 
> This patch adds hwpoison page handle, consider hwpoison page incore as
> same as migration.
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

The change makes sense:

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

But please add a description of what happens when a poison entry is
encountered with the current code.  I'm guessing swap_address_space()
will return garbage and this might crash the kernel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
