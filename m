Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4796B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 14:36:08 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so24076086wmr.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 11:36:08 -0700 (PDT)
Received: from mx.tkos.co.il (guitar.tcltek.co.il. [192.115.133.116])
        by mx.google.com with ESMTPS id f193si4675092wmd.129.2016.07.07.11.36.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 11:36:04 -0700 (PDT)
Date: Thu, 7 Jul 2016 21:35:59 +0300
From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH 1/9] mm: Hardened usercopy
Message-ID: <20160707183559.GR2118@tarshish>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
 <1467843928-29351-2-git-send-email-keescook@chromium.org>
 <20160707053710.GH2118@tarshish>
 <CAGXu5jJV4ZQp4VQ44SPQ49RxXpFXzx6d233A3+_Ka7txYHmuMw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jJV4ZQp4VQ44SPQ49RxXpFXzx6d233A3+_Ka7txYHmuMw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, sparclinux <sparclinux@vger.kernel.org>, linux-ia64@vger.kernel.org, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch <linux-arch@vger.kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, "x86@kernel.org" <x86@kernel.org>, Russell King <linux@armlinux.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, PaX Team <pageexec@freemail.hu>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Fenghua Yu <fenghua.yu@intel.com>, Rik van Riel <riel@redhat.com>, Vitaly Wool <vitalywool@gmail.com>, David Rientjes <rientjes@google.com>, Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, Brad Spengler <spender@grsecurity.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Pekka Enberg <penberg@kernel.org>, Casey Schaufler <casey@schaufler-ca.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, "David S. Miller" <davem@davemloft.net>

Hi Kees,

On Thu, Jul 07, 2016 at 01:25:21PM -0400, Kees Cook wrote:
> On Thu, Jul 7, 2016 at 1:37 AM, Baruch Siach <baruch@tkos.co.il> wrote:
> > On Wed, Jul 06, 2016 at 03:25:20PM -0700, Kees Cook wrote:
> >> +#ifdef CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR
> >
> > Should be CONFIG_HARDENED_USERCOPY to match the slab/slub implementation
> > condition.
> >
> >> +const char *__check_heap_object(const void *ptr, unsigned long n,
> >> +                             struct page *page);
> >> +#else
> >> +static inline const char *__check_heap_object(const void *ptr,
> >> +                                           unsigned long n,
> >> +                                           struct page *page)
> >> +{
> >> +     return NULL;
> >> +}
> >> +#endif
> 
> Hmm, I think what I have is correct: if the allocator supports the
> heap object checking, it defines __check_heap_object as existing via
> CONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR. If usercopy checking is done
> at all is controlled by CONFIG_HARDENED_USERCOPY.
> 
> I.e. you can have the other usercopy checks even if your allocator
> doesn't support object size checking.

Right. I missed the fact that usercopy.c build also depends on 
CONFIG_HARDENED_USERCOPY. Sorry for the noise.

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.52.368.4656, http://www.tkos.co.il -

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
