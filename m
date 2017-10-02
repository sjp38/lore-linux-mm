Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6309F6B0038
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 17:40:46 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id q124so1111633wmb.23
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 14:40:46 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q190si7196685wmb.193.2017.10.02.14.40.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 14:40:45 -0700 (PDT)
Date: Mon, 2 Oct 2017 14:40:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/hmm: constify hmm_devmem_page_get_drvdata()
 parameter
Message-Id: <20171002144042.e33ff3cf7dc95845e255d2c0@linux-foundation.org>
In-Reply-To: <1506972774-10191-1-git-send-email-jglisse@redhat.com>
References: <1506972774-10191-1-git-send-email-jglisse@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>

On Mon,  2 Oct 2017 15:32:54 -0400 J=E9r=F4me Glisse <jglisse@redhat.com> w=
rote:

> From: Ralph Campbell <rcampbell@nvidia.com>
>=20
> Constify pointer parameter to avoid issue when use from code that
> only has const struct page pointer to use in the first place.

That's rather vague.  Does such calling code exist in the kernel?  This
affects the which-kernel-gets-patched decision.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
