Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 680D36B2998
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 00:02:04 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id w19-v6so12940239plq.1
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 21:02:04 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z18si45615271pgk.367.2018.11.21.21.02.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 21:02:03 -0800 (PST)
Date: Wed, 21 Nov 2018 21:01:59 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm: use swp_offset as key in shmem_replace_page()
Message-Id: <20181121210159.3a5fb6946e460c561fdec391@linux-foundation.org>
In-Reply-To: <20181121215442.138545-1-yuzhao@google.com>
References: <20181119010924.177177-1-yuzhao@google.com>
	<20181121215442.138545-1-yuzhao@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Zhao <yuzhao@google.com>
Cc: Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 21 Nov 2018 14:54:42 -0700 Yu Zhao <yuzhao@google.com> wrote:

> We changed key of swap cache tree from swp_entry_t.val to
> swp_offset. Need to do so in shmem_replace_page() as well.

What are the user-visible effects of this change?

> Fixes: f6ab1f7f6b2d ("mm, swap: use offset of swap entry as key of swap cache")
> Cc: stable@vger.kernel.org # v4.9+

Please always provide the user-impact information when fixing bugs.  This
becomes especially important when proposing -stable backporting.

Hugh said

: shmem_replace_page() has been wrong since the day I wrote it: good
: enough to work on swap "type" 0, which is all most people ever use
: (especially those few who need shmem_replace_page() at all), but broken
: once there are any non-0 swp_type bits set in the higher order bits.

but we still don't have a description of "broken".

Thanks.
