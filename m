Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id B39616B0279
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 21:39:19 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id o45so1196697qto.5
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 18:39:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c22si76588qtd.74.2017.06.21.18.39.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 18:39:17 -0700 (PDT)
Message-ID: <1498095554.13083.25.camel@redhat.com>
Subject: Re: [kernel-hardening] [PATCH] exec: Account for argv/envp pointers
From: Rik van Riel <riel@redhat.com>
Date: Wed, 21 Jun 2017 21:39:14 -0400
In-Reply-To: <20170622001720.GA32173@beast>
References: <20170622001720.GA32173@beast>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Qualys Security Advisory <qsa@qualys.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, 2017-06-21 at 17:17 -0700, Kees Cook wrote:
> When limiting the argv/envp strings during exec to 1/4 of the stack
> limit,
> the storage of the pointers to the strings was not included. This
> means
> that an exec with huge numbers of tiny strings could eat 1/4 of the
> stack limit in strings and then additional space would be later used
> by the pointers to the strings. For example, on 32-bit with a 8MB
> stack
> rlimit, an exec with 1677721 single-byte strings would consume less
> than
> 2MB of stack, the max (8MB / 4) amount allowed, but the pointers to
> the
> strings would consume the remaining additional stack space (1677721 *
> 4 == 6710884). The result (1677721 + 6710884 == 8388605) would
> exhaust
> stack space entirely. Controlling this stack exhaustion could result
> in
> pathological behavior in setuid binaries (CVE-2017-1000365).
> 
> Fixes: b6a2fea39318 ("mm: variable length argument support")
> Cc: stable@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
