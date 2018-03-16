Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 539AB6B0025
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:10:02 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f4-v6so6144166plr.11
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:10:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b22si6120434pfi.244.2018.03.16.14.10.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 14:10:01 -0700 (PDT)
Date: Fri, 16 Mar 2018 14:09:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 02/14] mm/hmm: fix header file if/else/endif maze
Message-Id: <20180316140959.b603888e2a9ba2e42e56ba1f@linux-foundation.org>
In-Reply-To: <20180316191414.3223-3-jglisse@redhat.com>
References: <20180316191414.3223-1-jglisse@redhat.com>
	<20180316191414.3223-3-jglisse@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>

On Fri, 16 Mar 2018 15:14:07 -0400 jglisse@redhat.com wrote:

> From: J=E9r=F4me Glisse <jglisse@redhat.com>
>=20
> The #if/#else/#endif for IS_ENABLED(CONFIG_HMM) were wrong.

"were wrong" is not a sufficient explanation of the problem, especially
if we're requesting a -stable backport.  Please fully describe the
effects of a bug when fixing it?
