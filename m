Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 3F60D6B0254
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 09:18:20 -0500 (EST)
Received: by wmww144 with SMTP id w144so182791212wmw.1
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 06:18:19 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id dc4si4562053wjc.52.2015.12.08.06.18.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 06:18:19 -0800 (PST)
Date: Tue, 8 Dec 2015 15:17:11 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 09/34] x86, pkeys: store protection in high VMA flags
In-Reply-To: <20151204011437.1F3BB55E@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1512081516470.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011437.1F3BB55E@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On Thu, 3 Dec 2015, Dave Hansen wrote:
> vma->vm_flags is an 'unsigned long', so has space for 32 flags
> on 32-bit architectures.  The high 32 bits are unused on 64-bit
> platforms.  We've steered away from using the unused high VMA
> bits for things because we would have difficulty supporting it
> on 32-bit.
> 
> Protection Keys are not available in 32-bit mode, so there is
> no concern about supporting this feature in 32-bit mode or on
> 32-bit CPUs.
> 
> This patch carves out 4 bits from the high half of
> vma->vm_flags and allows architectures to set config option
> to make them available.
> 
> Sparse complains about these constants unless we explicitly
> call them "UL".
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
