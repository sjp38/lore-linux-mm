Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF8A46B045B
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 12:48:08 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id o1so34265743ito.7
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 09:48:08 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [69.252.207.37])
        by mx.google.com with ESMTPS id 141si2824566itu.27.2016.11.18.09.48.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Nov 2016 09:48:06 -0800 (PST)
Date: Fri, 18 Nov 2016 11:47:09 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] slab: Add POISON_POINTER_DELTA to ZERO_SIZE_PTR
In-Reply-To: <1479376267-18486-1-git-send-email-mpe@ellerman.id.au>
Message-ID: <alpine.DEB.2.20.1611181146330.26818@east.gentwo.org>
References: <1479376267-18486-1-git-send-email-mpe@ellerman.id.au>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: akpm@linux-foundation.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, keescook@chromium.org

On Thu, 17 Nov 2016, Michael Ellerman wrote:

> Currently ZERO_OR_NULL_PTR() uses a trick of doing a single check that
> x <= ZERO_SIZE_PTR, and ignoring the fact that it also matches 1-15.

Well yes that was done so we do not add too many branches all over the
kernel.....


> That no longer really works once we add the poison delta, so split it
> into two checks. Assign x to a temporary to avoid evaluating it
> twice (suggested by Kees Cook).

And now you are doing just that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
