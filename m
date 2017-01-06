Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3F75C6B0038
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 19:34:10 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c186so72766204pfb.7
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 16:34:10 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q12si77463768pgc.52.2017.01.05.16.34.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 16:34:09 -0800 (PST)
Date: Thu, 5 Jan 2017 16:35:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix SLAB freelist randomization duplicate entries
Message-Id: <20170105163527.d37a29d6e7b3bfdafd7472d2@linux-foundation.org>
In-Reply-To: <20170103181908.143178-1-thgarnie@google.com>
References: <20170103181908.143178-1-thgarnie@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Garnier <thgarnie@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jsperbeck@google.com

On Tue,  3 Jan 2017 10:19:08 -0800 Thomas Garnier <thgarnie@google.com> wrote:

> This patch fixes a bug in the freelist randomization code. When a high
> random number is used, the freelist will contain duplicate entries. It
> will result in different allocations sharing the same chunk.

Important: what are the user-visible runtime effects of the bug?

> Fixes: c7ce4f60ac19 ("mm: SLAB freelist randomization")
> Signed-off-by: John Sperbeck <jsperbeck@google.com>
> Reviewed-by: Thomas Garnier <thgarnie@google.com>

This should have been signed off by yourself.

I'm guessing that the author was in fact John?  If so, you should
indicate this by putting his From: line at the start of the changelog. 
Otherwise, authorship will default to the sender (ie, yourself).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
