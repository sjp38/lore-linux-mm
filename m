Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id EEA546B000A
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 19:10:52 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id i19-v6so3609380pgb.19
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 16:10:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x85-v6si6055788pfk.54.2018.10.24.16.10.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 16:10:51 -0700 (PDT)
Date: Wed, 24 Oct 2018 16:10:47 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/6] mm/hmm: fix race between hmm_mirror_unregister()
 and mmu_notifier callback
Message-Id: <20181024161047.cd979d1c3da115844182de3b@linux-foundation.org>
In-Reply-To: <20181019160442.18723-4-jglisse@redhat.com>
References: <20181019160442.18723-1-jglisse@redhat.com>
	<20181019160442.18723-4-jglisse@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralph Campbell <rcampbell@nvidia.com>, stable@vger.kernel.org

On Fri, 19 Oct 2018 12:04:39 -0400 jglisse@redhat.com wrote:

> From: Ralph Campbell <rcampbell@nvidia.com>
>=20
> In hmm_mirror_unregister(), mm->hmm is set to NULL and then
> mmu_notifier_unregister_no_release() is called. That creates a small
> window where mmu_notifier can call mmu_notifier_ops with mm->hmm equal
> to NULL. Fix this by first unregistering mmu notifier callbacks and
> then setting mm->hmm to NULL.
>=20
> Similarly in hmm_register(), set mm->hmm before registering mmu_notifier
> callbacks so callback functions always see mm->hmm set.
>=20
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> Reviewed-by: J=E9r=F4me Glisse <jglisse@redhat.com>
> Reviewed-by: Balbir Singh <bsingharora@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: stable@vger.kernel.org

I added your Signed-off-by: to this one.  It's required since you were
on the patch delivery path.
