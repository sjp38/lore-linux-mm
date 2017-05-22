Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id EC14B6B0292
	for <linux-mm@kvack.org>; Mon, 22 May 2017 19:24:28 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id z125so99396472itc.4
        for <linux-mm@kvack.org>; Mon, 22 May 2017 16:24:28 -0700 (PDT)
Received: from mail-it0-x243.google.com (mail-it0-x243.google.com. [2607:f8b0:4001:c0b::243])
        by mx.google.com with ESMTPS id 10si19781248ioq.73.2017.05.22.16.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 16:24:28 -0700 (PDT)
Received: by mail-it0-x243.google.com with SMTP id l145so15479762ita.0
        for <linux-mm@kvack.org>; Mon, 22 May 2017 16:24:28 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Subject: Re: [PATCH v2 10/11] x86/mm: Be more consistent wrt PAGE_SHIFT vs
 PAGE_SIZE in tlb flush code
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <29e74164b213b349fd9c4bc1bec5e154af38ac87.1495492063.git.luto@kernel.org>
Date: Mon, 22 May 2017 16:24:23 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <519997CE-E94C-40E3-96A7-48CA682B553E@gmail.com>
References: <cover.1495492063.git.luto@kernel.org>
 <cover.1495492063.git.luto@kernel.org>
 <29e74164b213b349fd9c4bc1bec5e154af38ac87.1495492063.git.luto@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

>=20
> 	/* Balance as user space task's flush, a bit conservative */
> 	if (end =3D=3D TLB_FLUSH_ALL ||
> -	    (end - start) > tlb_single_page_flush_ceiling * PAGE_SIZE) {
> +	    (end - start) > tlb_single_page_flush_ceiling >> PAGE_SHIFT) =
{

Shouldn=E2=80=99t it be << ?

Nadav

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
