Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 7A16B6B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 18:34:12 -0400 (EDT)
Message-ID: <506382E3.3020102@att.net>
Date: Wed, 26 Sep 2012 17:34:11 -0500
From: Daniel Santos <danielfsantos@att.net>
Reply-To: Daniel Santos <daniel.santos@pobox.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/9] rbtree: add __rb_change_child() helper function
References: <1345500331-10546-1-git-send-email-walken@google.com> <1345500331-10546-3-git-send-email-walken@google.com> <20120820151710.eeed9bcf.akpm@linux-foundation.org>
In-Reply-To: <20120820151710.eeed9bcf.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michel Lespinasse <walken@google.com>, riel@redhat.com, peterz@infradead.org, daniel.santos@pobox.com, aarcange@redhat.com, dwmw2@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org

Sorry to resurrect the dead here, but I'm playing catch-up and this
looks important.

On 08/20/2012 05:17 PM, Andrew Morton wrote:
> I'm inclined to agree with Peter here - "inline" is now a vague,
> pathetic and useless thing.  The problem is that the reader just
> doesn't *know* whether or not the writer really wanted it to be
> inlined.
>
> If we have carefully made a decision to inline a function, we should
> (now) use __always_inline.
Are we all aware here that __always_inline (a.k.a.
"__attribute__((always_inline))") just means "inline even when not
optimizing"?  This appears to be a very common misunderstanding (unless
the gcc docs are wrong, see
http://gcc.gnu.org/onlinedocs/gcc/Function-Attributes.html#index-g_t_0040code_007bflatten_007d-function-attribute-2512).

If you want to *force* gcc to inline a function (when inlining is
enabled), you can currently only do it from the calling function by
adding the |flatten attribute to it, which I have proposed adding here:
https://lkml.org/lkml/2012/9/25/643.

Thus, all of the __always_inline markings we have in the kernel only
affect unoptimized builds (and maybe -O1?).  If we need this feature
(and I think it would be darned handy!) we'll have to work on gcc to get it.

Daniel
|

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
