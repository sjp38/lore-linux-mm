Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 194CB6B002B
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 22:35:15 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id k14so7018225oag.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 19:35:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121008150949.GA15130@redhat.com>
References: <20121008150949.GA15130@redhat.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Mon, 15 Oct 2012 22:34:53 -0400
Message-ID: <CAHGf_=pr1AYeWZhaC2MKN-XjiWB7=hs92V0sH-zVw3i00X-e=A@mail.gmail.com>
Subject: Re: mpol_to_str revisited.
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, bhutchings@solarflare.com, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Oct 8, 2012 at 11:09 AM, Dave Jones <davej@redhat.com> wrote:
> Last month I sent in 80de7c3138ee9fd86a98696fd2cf7ad89b995d0a to remove
> a user triggerable BUG in mempolicy.
>
> Ben Hutchings pointed out to me that my change introduced a potential leak
> of stack contents to userspace, because none of the callers check the return value.
>
> This patch adds the missing return checking, and also clears the buffer beforehand.

I don't think 80de7c3138ee9fd86a98696fd2cf7ad89b995d0a is right fix. we should
close a race (or kill remain ref count leak) if we still have.
Because of, this patch makes unstable /proc output and might lead to
userland confusing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
