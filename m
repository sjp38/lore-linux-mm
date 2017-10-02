Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 031016B0253
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 17:57:16 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r83so14463405pfj.5
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 14:57:15 -0700 (PDT)
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id f6si8456037pgp.631.2017.10.02.14.57.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 14:57:15 -0700 (PDT)
From: Ralph Campbell <rcampbell@nvidia.com>
Subject: RE: [PATCH] mm/hmm: constify hmm_devmem_page_get_drvdata() parameter
Date: Mon, 2 Oct 2017 21:54:43 +0000
Message-ID: <5de6865d177849a389f02e064b2ff65b@HQMAIL105.nvidia.com>
References: <1506972774-10191-1-git-send-email-jglisse@redhat.com>
 <20171002144042.e33ff3cf7dc95845e255d2c0@linux-foundation.org>
In-Reply-To: <20171002144042.e33ff3cf7dc95845e255d2c0@linux-foundation.org>
MIME-Version: 1.0
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, =?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

The use case is when called by struct hmm_devmem_ops.fault() which passes a=
 const struct page * pointer and hmm_devmem_page_get_drvdata() is called to=
 get the private data.
Since HMM was only recently added, it only affects kernels after September =
8, 2017.

> -----Original Message-----
> From: Andrew Morton [mailto:akpm@linux-foundation.org]
> Sent: Monday, October 2, 2017 2:41 PM
> To: J=E9r=F4me Glisse <jglisse@redhat.com>
> Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; Ralph Campbell
> <rcampbell@nvidia.com>
> Subject: Re: [PATCH] mm/hmm: constify hmm_devmem_page_get_drvdata()
> parameter
>=20
> On Mon,  2 Oct 2017 15:32:54 -0400 J=E9r=F4me Glisse <jglisse@redhat.com>
> wrote:
>=20
> > From: Ralph Campbell <rcampbell@nvidia.com>
> >
> > Constify pointer parameter to avoid issue when use from code that only
> > has const struct page pointer to use in the first place.
>=20
> That's rather vague.  Does such calling code exist in the kernel?  This a=
ffects the
> which-kernel-gets-patched decision.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
