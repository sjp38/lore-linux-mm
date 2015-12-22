Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id DCF146B0026
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 09:57:58 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id q3so97773771pav.3
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 06:57:58 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id m74si25283737pfi.92.2015.12.22.06.57.57
        for <linux-mm@kvack.org>;
        Tue, 22 Dec 2015 06:57:57 -0800 (PST)
Subject: Re: [kernel-hardening] [RFC][PATCH 6/7] mm: Add Kconfig option for
 slab sanitization
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
 <1450755641-7856-7-git-send-email-laura@labbott.name>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <567964F3.2020402@intel.com>
Date: Tue, 22 Dec 2015 06:57:55 -0800
MIME-Version: 1.0
In-Reply-To: <1450755641-7856-7-git-send-email-laura@labbott.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Laura Abbott <laura@labbott.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

On 12/21/2015 07:40 PM, Laura Abbott wrote:
> +	  The tradeoff is performance impact. The noticible impact can vary
> +	  and you are advised to test this feature on your expected workload
> +	  before deploying it

What if instead of writing SLAB_MEMORY_SANITIZE_VALUE, we wrote 0's?
That still destroys the information, but it has the positive effect of
allowing a kzalloc() call to avoid zeroing the slab object.  It might
mitigate some of the performance impact.

If this is on at compile time, but booted with sanitize_slab=off, is
there a performance impact?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
