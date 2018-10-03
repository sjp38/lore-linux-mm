Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 815146B0010
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 09:18:54 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id y201-v6so456131qka.1
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 06:18:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e2-v6si810237qtd.355.2018.10.03.06.18.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 06:18:53 -0700 (PDT)
Date: Wed, 3 Oct 2018 15:19:11 +0200
From: Eugene Syromiatnikov <esyr@redhat.com>
Subject: Re: [RFC PATCH v4 10/27] drm/i915/gvt: Update _PAGE_DIRTY to
 _PAGE_DIRTY_BITS
Message-ID: <20181003131911.GB32759@asgard.redhat.com>
References: <20180921150351.20898-1-yu-cheng.yu@intel.com>
 <20180921150351.20898-11-yu-cheng.yu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180921150351.20898-11-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Fri, Sep 21, 2018 at 08:03:34AM -0700, Yu-cheng Yu wrote:
> Update _PAGE_DIRTY to _PAGE_DIRTY_BITS in split_2MB_gtt_entry().
> 
> In order to support Control Flow Enforcement (CET), _PAGE_DIRTY
> is now _PAGE_DIRTY_HW or _PAGE_DIRTY_SW.
> 
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  drivers/gpu/drm/i915/gvt/gtt.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/gpu/drm/i915/gvt/gtt.c b/drivers/gpu/drm/i915/gvt/gtt.c
> index 00aad8164dec..2d6ba1462dd8 100644
> --- a/drivers/gpu/drm/i915/gvt/gtt.c
> +++ b/drivers/gpu/drm/i915/gvt/gtt.c
> @@ -1170,7 +1170,7 @@ static int split_2MB_gtt_entry(struct intel_vgpu *vgpu,
>  	}
>  
>  	/* Clear dirty field. */
> -	se->val64 &= ~_PAGE_DIRTY;
> +	se->val64 &= ~_PAGE_DIRTY_BITS;

_PAGE_DIRTY_BITS is defined only in "[RFC PATCH v4 11/27] x86/mm:
Introduce _PAGE_DIRTY_SW",
