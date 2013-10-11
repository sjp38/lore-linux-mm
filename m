Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id B6C856B0031
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 14:55:46 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so4668880pdi.19
        for <linux-mm@kvack.org>; Fri, 11 Oct 2013 11:55:46 -0700 (PDT)
Date: Fri, 11 Oct 2013 11:55:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] swap: fix set_blocksize race during swapon/swapoff
Message-Id: <20131011115542.a81a9215d9b876706ec58a72@linux-foundation.org>
In-Reply-To: <1381485262-16792-1-git-send-email-k.kozlowski@samsung.com>
References: <1381485262-16792-1-git-send-email-k.kozlowski@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Weijie Yang <weijie.yang.kh@gmail.com>, Bob Liu <bob.liu@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Shaohua Li <shli@fusionio.com>, Minchan Kim <minchan@kernel.org>

On Fri, 11 Oct 2013 11:54:22 +0200 Krzysztof Kozlowski <k.kozlowski@samsung.com> wrote:

> Swapoff used old_block_size from swap_info which could be overwritten by
> concurrent swapon.

Better changelogs, please.  What were the user-visible effects of the
bug, and how is it triggered?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
