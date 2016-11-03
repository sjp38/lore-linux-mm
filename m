Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 611466B02C4
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 17:16:09 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ro13so28106059pac.7
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 14:16:09 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w14si11700256pfd.17.2016.11.03.14.16.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 14:16:08 -0700 (PDT)
Date: Thu, 3 Nov 2016 14:16:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATH] z3fold: extend compaction function
Message-Id: <20161103141607.855925f33be627dea9731eb3@linux-foundation.org>
In-Reply-To: <20161103220428.984a8d09d0c9569e6bc6b8cc@gmail.com>
References: <20161103220428.984a8d09d0c9569e6bc6b8cc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Dan Streetman <ddstreet@ieee.org>

On Thu, 3 Nov 2016 22:04:28 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:

> z3fold_compact_page() currently only handles the situation when
> there's a single middle chunk within the z3fold page. However it
> may be worth it to move middle chunk closer to either first or
> last chunk, whichever is there, if the gap between them is big
> enough.

"may be worth it" is vague.  Does the patch improve the driver or does
it not?  If it *does* improve the driver then in what way?  *Why* is is
"worth it"?

> This patch adds the relevant code, using BIG_CHUNK_GAP define as
> a threshold for middle chunk to be worth moving.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
