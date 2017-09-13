Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 166606B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 17:52:53 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f4so1841495wmh.7
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 14:52:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x142si1807719wme.214.2017.09.13.14.52.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Sep 2017 14:52:52 -0700 (PDT)
Date: Wed, 13 Sep 2017 14:52:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V3 2/3] mm: dmapool: Align to ARCH_DMA_MINALIGN in
 non-coherent DMA mode
Message-Id: <20170913145249.f89678a57842da122aa062fd@linux-foundation.org>
In-Reply-To: <1505294451-21312-1-git-send-email-chenhc@lemote.com>
References: <1505294451-21312-1-git-send-email-chenhc@lemote.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huacai Chen <chenhc@lemote.com>
Cc: Fuxin Zhang <zhangfx@lemote.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Wed, 13 Sep 2017 17:20:51 +0800 Huacai Chen <chenhc@lemote.com> wrote:

> In non-coherent DMA mode, kernel uses cache flushing operations to
> maintain I/O coherency, so the dmapool objects should be aligned to
> ARCH_DMA_MINALIGN.

What are the user-visible effects of this bug?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
