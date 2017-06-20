Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3DE6B02F4
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 00:09:53 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id p138so87441253ioe.13
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 21:09:53 -0700 (PDT)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id i130si13058728ioa.80.2017.06.19.21.09.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 21:09:52 -0700 (PDT)
Received: by mail-it0-x244.google.com with SMTP id f20so13984194itb.2
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 21:09:52 -0700 (PDT)
Message-ID: <1497931790.11009.1.camel@gmail.com>
Subject: Re: [kernel-hardening] [PATCH 23/23] mm: Allow slab_nomerge to be
 set at build time
From: Daniel Micay <danielmicay@gmail.com>
Date: Tue, 20 Jun 2017 00:09:50 -0400
In-Reply-To: <1497915397-93805-24-git-send-email-keescook@chromium.org>
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
	 <1497915397-93805-24-git-send-email-keescook@chromium.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com
Cc: David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2017-06-19 at 16:36 -0700, Kees Cook wrote:
> Some hardened environments want to build kernels with slab_nomerge
> already set (so that they do not depend on remembering to set the
> kernel
> command line option). This is desired to reduce the risk of kernel
> heap
> overflows being able to overwrite objects from merged caches,
> increasing
> the difficulty of these attacks. By keeping caches unmerged, these
> kinds
> of exploits can usually only damage objects in the same cache (though
> the
> risk to metadata exploitation is unchanged).

It also further fragments the ability to influence slab cache layout,
i.e. primitives to do things like filling up slabs to set things up for
an exploit might not be able to deal with the target slabs anymore. It
doesn't need to be mentioned but it's something to think about too. In
theory, disabling merging can make it *easier* to get the right layout
too if there was some annoyance that's now split away. It's definitely a
lot more good than bad for security though, but allocator changes have
subtle impact on exploitation. This can make caches more deterministic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
