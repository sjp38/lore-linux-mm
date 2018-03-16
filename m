Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 981366B0006
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 20:11:54 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id m4so5411654uad.5
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 17:11:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t10sor2373559uaf.37.2018.03.15.17.11.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 15 Mar 2018 17:11:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180315183700.3843-3-jglisse@redhat.com>
References: <20180315183700.3843-1-jglisse@redhat.com> <20180315183700.3843-3-jglisse@redhat.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 16 Mar 2018 11:11:52 +1100
Message-ID: <CAKTCnz=dGz-yoONiG+0Ajf-S6EePyMvHmNvndHA-QtfkqjXWZw@mail.gmail.com>
Subject: Re: [PATCH 2/4] mm/hmm: fix header file if/else/endif maze
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>

On Fri, Mar 16, 2018 at 5:36 AM,  <jglisse@redhat.com> wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>
> The #if/#else/#endif for IS_ENABLED(CONFIG_HMM) were wrong.
>
> Signed-off-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
> ---

Acked-by: Balbir Singh <bsingharora@gmail.com>
