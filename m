Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7816B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 16:54:30 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id zm5so40131691pac.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 13:54:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id o126si6818533pfo.29.2016.04.06.13.54.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 13:54:29 -0700 (PDT)
Date: Wed, 6 Apr 2016 13:54:29 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [kernel-hardening] [RFC v1] mm: SLAB freelist randomization
Message-ID: <20160406205429.GA13901@kroah.com>
References: <1459971348-81477-1-git-send-email-thgarnie@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459971348-81477-1-git-send-email-thgarnie@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, gthelen@google.com, keescook@chromium.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, labbott@fedoraproject.org, Thomas Garnier <thgarnie@google.com>

On Wed, Apr 06, 2016 at 12:35:48PM -0700, Thomas Garnier wrote:
> Provide an optional config (CONFIG_FREELIST_RANDOM) to randomize the
> SLAB freelist. This security feature reduces the predictability of
> the kernel slab allocator against heap overflows.
> 
> Randomized lists are pre-computed using a Fisher-Yates shuffle and
> re-used on slab creation for performance.
> ---
> Based on next-20160405
> ---

No signed-off-by:?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
