Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 99E906B005D
	for <linux-mm@kvack.org>; Sun, 30 Aug 2009 10:02:06 -0400 (EDT)
Message-ID: <4A9A8656.5050804@cs.helsinki.fi>
Date: Sun, 30 Aug 2009 17:01:58 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH v2] SLUB: fix ARCH_KMALLOC_MINALIGN cases 64 and 256
References: <> <1251458934-25838-1-git-send-email-aaro.koskinen@nokia.com>
In-Reply-To: <1251458934-25838-1-git-send-email-aaro.koskinen@nokia.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Aaro Koskinen <aaro.koskinen@nokia.com>
Cc: mpm@selenic.com, cl@linux-foundation.org, linux-mm@kvack.org, Artem.Bityutskiy@nokia.com
List-ID: <linux-mm.kvack.org>

Aaro Koskinen wrote:
> If the minalign is 64 bytes, then the 96 byte cache should not be created
> because it would conflict with the 128 byte cache.
> 
> If the minalign is 256 bytes, patching the size_index table should not
> result in a buffer overrun.
> 
> The calculation "(i - 1) / 8" used to access size_index[] is moved to
> a separate function as suggested by Christoph Lameter.
> 
> Signed-off-by: Aaro Koskinen <aaro.koskinen@nokia.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
