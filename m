Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 62C6C6B02C3
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 21:43:46 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a2so6406314pfj.2
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 18:43:46 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id d16si799108plj.722.2017.08.31.18.43.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 Aug 2017 18:43:44 -0700 (PDT)
Date: Fri, 1 Sep 2017 11:43:41 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2017-08-31-16-13 uploaded
Message-ID: <20170901114341.1da24b37@canb.auug.org.au>
In-Reply-To: <59a8982c.FwLJY62HB+esikOu%akpm@linux-foundation.org>
References: <59a8982c.FwLJY62HB+esikOu%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, mhocko@suse.cz, broonie@kernel.org, =?UTF-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>

Hi Andrew,

On Thu, 31 Aug 2017 16:13:48 -0700 akpm@linux-foundation.org wrote:
>
> * mm-hmm-struct-hmm-is-only-use-by-hmm-mirror-functionality-v2-fix.patch

You should have dropped the above patch from me before applying the
below patch from J=C3=A9r=C3=B4me.

> * mm-hmm-fix-build-when-hmm-is-disabled.patch

I will do that in linux-next today.
--=20
Cheers,
Stephen Rothwell

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
