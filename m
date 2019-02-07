Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B8A6C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 10:27:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DEA3E218FE
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 10:27:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="iiC3rd9a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DEA3E218FE
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E7808E0025; Thu,  7 Feb 2019 05:27:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26D508E0002; Thu,  7 Feb 2019 05:27:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10D6B8E0025; Thu,  7 Feb 2019 05:27:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id D2B418E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 05:27:07 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id z22so1263865otq.2
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 02:27:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=KQVJ0Qx0jz4OgVw+39LjkotjVwynNqSsNpBV0A3AeRE=;
        b=ibT1eZ5d+lC1PCICCELbqvz78zpZfXt+WR6Ur1sDgLDlqUAHLU5WrvszQ9hMN3sbNI
         /+0o6mZAAzL3PccvZjqmThpuQTev1P4vm+E0b+3G8qT8PTybUHgMO/1ORd7Rt+TM04JU
         QhMREMhO5llnXMIcbFIfOxZ/ENOCT/i1UUrNgcOP2OZhRvT+6DuO0qhceSz9DvIIv3ZW
         n6ETR53KkyQ4VUBvUpppdvJSDEJbSTQ1EMUEI3bopcZvRvYuLQ+Iq/DTzTm2CWPBXzUm
         nPUH5zyqf/ODN8JQMf5ued5u/fbDMFT7XVex8RFF69ySezDZLSH5r22e12+Gh6GfvzF9
         AfQw==
X-Gm-Message-State: AHQUAuatIaw9FOYsN4eXzl8O7fFZc7cjyzpLDWKxkL27rRNDHoukzaRB
	hFf6cXpbSsUPUVE9YaLNwH0GQZ7/qSV2RJhGURzuLbBMClhWSAkJ50AnK2z2zRegVxI+UwidUve
	8WWhv3bhRNkOJN+iaLLlkTZ12jLC17zYblm6YIIf3cULLm4cDSFbv7tX1EfjCMRFL3lbXMZBYl3
	cw3IvmM90KD5vsbXQtcf2t35zXlmCFw1zLuqziiCuS5poQKEGk2PR/b9r5mGPyUxbOeE8hCNchF
	sRaVasq4PA8XE7kUvC5H7K6ej+AES2vj8EK0go90c/xjt4cCc9OpID578Y2Oq+0NohD0ebdsr35
	bIMFa/+huA4jjwI84NpnPx6MDcupaOEHH0xcGVdNkP0ju4PjPHi0+DWU2dP/SXP7T+Zyb6s83Q4
	8
X-Received: by 2002:a05:6808:249:: with SMTP id m9mr2217036oie.65.1549535227571;
        Thu, 07 Feb 2019 02:27:07 -0800 (PST)
X-Received: by 2002:a05:6808:249:: with SMTP id m9mr2217001oie.65.1549535226701;
        Thu, 07 Feb 2019 02:27:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549535226; cv=none;
        d=google.com; s=arc-20160816;
        b=NtwroO38lGPr455b/E872mJRgHdt2I4f8Hwak1q9pfmcCJQW0bho5CaHNstenB9caJ
         J41NxrU83vSMcb9WCRSb96p11X9QgzXT9qmBSi3EdJdSTBTXhHULQye2g3NzC+3Il62G
         Thab5Qk9721QneNOMfKJblrRFO65+fgwse7eYD2q+8qJukb4OarWTHc/96UpH5IsqViT
         huj4FWk0P+/E2Ki9IwfIDI2JamPTEiqjbtfoSxOuhR1AEBWmXaCEy8hKB1T8wFKjyYbr
         pdK1AJdsv4fzMmA8s3cu6UDsCxGWEQqMnLToFVhVruQYZlL8jhLkC/MfqWf30cJakxZc
         dhqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=KQVJ0Qx0jz4OgVw+39LjkotjVwynNqSsNpBV0A3AeRE=;
        b=dyFdAI/KQOg1YcMiOnOFMNUywBns+li3H60Rr3D5KG+7i9DBVU15jFXlvWN9o+EYB4
         hM1BrRtyATvTAgFN07ZYPrEko9OBAq1gBI92o9JyuOdjKflT0n0l75ccbKQFBUYPAkmH
         q1NBUTnEG8Q1w2WhN05MWr8/peftAis5KM662uByOdv1XITIyOlzm7y1HOflsode6NQJ
         y7ML2quQ49JpW/R23joIzXtx9+2PWvcz9+uI+9KH7MfuBc2mLbbIRfyax+dJyVw0ultq
         ZM/QXrl3kmZIXSOAwbWGXtsHGlqspaeMnRo1JI8JL96AV2aSfHoZ0Iz2ULoWHBwk8ElC
         A0YQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iiC3rd9a;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m186sor14715642oif.18.2019.02.07.02.27.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 02:27:06 -0800 (PST)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=iiC3rd9a;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KQVJ0Qx0jz4OgVw+39LjkotjVwynNqSsNpBV0A3AeRE=;
        b=iiC3rd9agn3fFWTEACayeEOzX/qIU3OUfTULp016nf/Pt9wZ13bomD4YfSTmmB6CfE
         V/y2oKetpYWIw1Ok/H6Tie+qdiJgS+Jmh8vLMJ8/GJpsV0EfhUOnAxBC1Bh9tPEKk5dj
         aHQQeBcHuYDjv+Pg0mnbbmHKZjlkauMBuAIqORuxyYvcdpMTrsB0UuuygbgANOb4EJpj
         Cz5Gyy3s6wEJsKWsy9/wjcUf5sy1hn3fqkv1FhiHmH97lUeAZSy7Sqk99afWYoY1qWkq
         axUzREfdptBlzxELLkk9VXDLa0A0vq6BqqzI9+xQc9h/UoaEPlgr83H7GznZszMTdixI
         CvEw==
X-Google-Smtp-Source: AHgI3IbAjKvQxulqhIkAuOqdf95N7/LHxBrA5Kg81BCJVsQ4ajeb4xF6iL//RLLe9VbzWYskUcY5fo6qcLiAtEr0Kkg=
X-Received: by 2002:aca:e003:: with SMTP id x3mr2231660oig.39.1549535226052;
 Thu, 07 Feb 2019 02:27:06 -0800 (PST)
MIME-Version: 1.0
References: <39fb6c5a191025378676492e140dc012915ecaeb.1547652372.git.christophe.leroy@c-s.fr>
In-Reply-To: <39fb6c5a191025378676492e140dc012915ecaeb.1547652372.git.christophe.leroy@c-s.fr>
From: Jann Horn <jannh@google.com>
Date: Thu, 7 Feb 2019 11:26:39 +0100
Message-ID: <CAG48ez1gXgsBG6bYGG5+B4Dqkhk_iVaYLqt63RaxURxE0yt9eA@mail.gmail.com>
Subject: Re: [PATCH v3 1/2] mm: add probe_user_read()
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, Mike Rapoport <rppt@linux.ibm.com>, 
	kernel list <linux-kernel@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 7, 2019 at 10:22 AM Christophe Leroy
<christophe.leroy@c-s.fr> wrote:
> In powerpc code, there are several places implementing safe
> access to user data. This is sometimes implemented using
> probe_kernel_address() with additional access_ok() verification,
> sometimes with get_user() enclosed in a pagefault_disable()/enable()
> pair, etc. :
>     show_user_instructions()
>     bad_stack_expansion()
>     p9_hmi_special_emu()
>     fsl_pci_mcheck_exception()
>     read_user_stack_64()
>     read_user_stack_32() on PPC64
>     read_user_stack_32() on PPC32
>     power_pmu_bhrb_to()
>
> In the same spirit as probe_kernel_read(), this patch adds
> probe_user_read().
>
> probe_user_read() does the same as probe_kernel_read() but
> first checks that it is really a user address.
>
> The patch defines this function as a static inline so the "size"
> variable can be examined for const-ness by the check_object_size()
> in __copy_from_user_inatomic()
>
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>



> ---
>  v3: Moved 'Returns:" comment after description.
>      Explained in the commit log why the function is defined static inline
>
>  v2: Added "Returns:" comment and removed probe_user_address()
>
>  include/linux/uaccess.h | 34 ++++++++++++++++++++++++++++++++++
>  1 file changed, 34 insertions(+)
>
> diff --git a/include/linux/uaccess.h b/include/linux/uaccess.h
> index 37b226e8df13..ef99edd63da3 100644
> --- a/include/linux/uaccess.h
> +++ b/include/linux/uaccess.h
> @@ -263,6 +263,40 @@ extern long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count);
>  #define probe_kernel_address(addr, retval)             \
>         probe_kernel_read(&retval, addr, sizeof(retval))
>
> +/**
> + * probe_user_read(): safely attempt to read from a user location
> + * @dst: pointer to the buffer that shall take the data
> + * @src: address to read from
> + * @size: size of the data chunk
> + *
> + * Safely read from address @src to the buffer at @dst.  If a kernel fault
> + * happens, handle that and return -EFAULT.
> + *
> + * We ensure that the copy_from_user is executed in atomic context so that
> + * do_page_fault() doesn't attempt to take mmap_sem.  This makes
> + * probe_user_read() suitable for use within regions where the caller
> + * already holds mmap_sem, or other locks which nest inside mmap_sem.
> + *
> + * Returns: 0 on success, -EFAULT on error.
> + */
> +
> +#ifndef probe_user_read
> +static __always_inline long probe_user_read(void *dst, const void __user *src,
> +                                           size_t size)
> +{
> +       long ret;
> +
> +       if (!access_ok(src, size))
> +               return -EFAULT;

If this happens in code that's running with KERNEL_DS, the access_ok()
is a no-op. If this helper is only intended for accessing real
userspace memory, it would be more robust to add
set_fs(USER_DS)/set_fs(oldfs) around this thing. Looking at the
functions you're referring to in the commit message, e.g.
show_user_instructions() does an explicit `__access_ok(pc,
NR_INSN_TO_PRINT * sizeof(int), USER_DS)` to get the same effect.
(However, __access_ok() looks like it's horribly broken on x86 from
what I can tell, because it's going to use the generic version that
always returns 1...)

> +       pagefault_disable();
> +       ret = __copy_from_user_inatomic(dst, src, size);
> +       pagefault_enable();
> +
> +       return ret ? -EFAULT : 0;
> +}
> +#endif
> +
>  #ifndef user_access_begin
>  #define user_access_begin(ptr,len) access_ok(ptr, len)
>  #define user_access_end() do { } while (0)
> --
> 2.13.3
>
>

