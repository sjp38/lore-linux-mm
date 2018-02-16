Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id C937C6B0006
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 12:48:52 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id t18so2637137plo.9
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 09:48:52 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l67sor446078pfb.88.2018.02.16.09.48.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Feb 2018 09:48:51 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH 2/3] x86/mm: introduce __PAGE_KERNEL_GLOBAL
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20180215132055.F341C31E@viggo.jf.intel.com>
Date: Fri, 16 Feb 2018 09:47:49 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <E0AB2852-C4E0-43D3-ABA7-34117A5516C1@gmail.com>
References: <20180215132053.6C9B48C8@viggo.jf.intel.com>
 <20180215132055.F341C31E@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org

Dave Hansen <dave.hansen@linux.intel.com> wrote:

>=20
> From: Dave Hansen <dave.hansen@linux.intel.com>
>=20
> Kernel mappings are historically _PAGE_GLOBAL.  But, with PTI, we do =
not
> want them to be _PAGE_GLOBAL.  We currently accomplish this by simply
> clearing _PAGE_GLOBAL from the suppotred mask which ensures it is
> cleansed from many of our PTE construction sites:
>=20
>        if (!static_cpu_has(X86_FEATURE_PTI))
> 	                __supported_pte_mask |=3D _PAGE_GLOBAL;
>=20
> But, this also means that we now get *no* opportunity to use global
> pages with PTI, even for data which is shared such as the =
cpu_entry_area
> and entry/exit text.


Doesn=E2=80=99t this patch change the kernel behavior when the =
=E2=80=9Cnopti=E2=80=9D parameter is used?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
