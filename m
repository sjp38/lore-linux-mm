Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 6C7B06B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 08:05:03 -0400 (EDT)
Date: Thu, 23 Aug 2012 14:05:01 +0200 (CEST)
From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH v3 2/9] rbtree: add __rb_change_child() helper function
In-Reply-To: <20120820151710.eeed9bcf.akpm@linux-foundation.org>
Message-ID: <alpine.LNX.2.01.1208231356010.30263@frira.zrqbmnf.qr>
References: <1345500331-10546-1-git-send-email-walken@google.com> <1345500331-10546-3-git-send-email-walken@google.com> <20120820151710.eeed9bcf.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org


On Tuesday 2012-08-21 00:17, Andrew Morton wrote:
>
>If we have carefully made a decision to inline a function, we should
>(now) use __always_inline.
>If we have carefully made a decision to not inline a function, we
>should use noinline.
>
>If we don't care, we should omit all such markings.
>This leaves no place for "inline"?

The current use of "inline" is to shut up the compiler, otherwise gcc
would emit a warning about "function declared but not used".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
