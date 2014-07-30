Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC4F6B0036
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 05:03:56 -0400 (EDT)
Received: by mail-ig0-f180.google.com with SMTP id l13so2532268iga.13
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 02:03:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w5si4403335igl.55.2014.07.30.02.03.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jul 2014 02:03:55 -0700 (PDT)
Date: Wed, 30 Jul 2014 02:06:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: BUG when __kmap_atomic_idx crosses boundary
Message-Id: <20140730020615.2f943cf7.akpm@linux-foundation.org>
In-Reply-To: <1406710355-4360-1-git-send-email-cpandya@codeaurora.org>
References: <1406710355-4360-1-git-send-email-cpandya@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chintan Pandya <cpandya@codeaurora.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 30 Jul 2014 14:22:35 +0530 Chintan Pandya <cpandya@codeaurora.org> wrote:

> __kmap_atomic_idx >= KM_TYPE_NR or < ZERO is a bug.
> Report it even if CONFIG_DEBUG_HIGHMEM is not enabled.
> That saves much debugging efforts.

Please take considerably more care when preparing patch changelogs.

kmap_atomic() is a very commonly called function so we'll need much
more detail than this to justify adding overhead to it.

I don't think CONFIG_DEBUG_HIGHMEM really needs to exist.  We could do
s/CONFIG_DEBUG_HIGHMEM/CONFIG_DEBUG_VM/g and perhaps your secret bug
whatever it was would have been found more easily.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
