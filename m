Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id EEA736B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 16:53:53 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id rd3so1273903pab.12
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 13:53:50 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v11si2382875pas.205.2014.08.27.13.53.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Aug 2014 13:53:49 -0700 (PDT)
Date: Wed, 27 Aug 2014 13:53:48 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] x86: use memblock_alloc_range() or
 memblock_alloc_base()
Message-Id: <20140827135348.9c9ccefebccc74083f7ba922@linux-foundation.org>
In-Reply-To: <1408892163-8073-1-git-send-email-akinobu.mita@gmail.com>
References: <1408892163-8073-1-git-send-email-akinobu.mita@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org

On Sun, 24 Aug 2014 23:56:02 +0900 Akinobu Mita <akinobu.mita@gmail.com> wrote:

> Replace memblock_find_in_range() and memblock_reserve() with
> memblock_alloc_range() or memblock_alloc_base().

Please spend a little more time preparing the changelogs?

Why are we making this change?  Because memblock_alloc_range() is
equivalent to memblock_find_in_range()+memblock_reserve() and it's just
a cleanup?  Or is there some deeper functional reason?

Does memblock_find_in_range() need to exist?  Can we convert all
callers to memblock_alloc_range()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
