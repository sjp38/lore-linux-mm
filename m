Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 93C0C6B0337
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 10:19:25 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id t194-v6so6175419oie.16
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 07:19:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v2sor4242720otb.93.2018.11.06.07.19.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 07:19:24 -0800 (PST)
MIME-Version: 1.0
References: <20181106093100.71829-1-vovoy@chromium.org> <20181106105406.GO21967@phenom.ffwll.local>
In-Reply-To: <20181106105406.GO21967@phenom.ffwll.local>
From: Kuo-Hsin Yang <vovoy@chromium.org>
Date: Tue, 6 Nov 2018 23:19:12 +0800
Message-ID: <CAEHM+4oLesko3TPGDm2+FTCJT=gYw4fy0YmCQGuT1CTHFZgmkg@mail.gmail.com>
Subject: Re: [PATCH v6] mm, drm/i915: mark pinned shmemfs pages as unevictable
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>

On Tue, Nov 6, 2018 at 6:54 PM Daniel Vetter <daniel@ffwll.ch> wrote:
> There was ages ago some planes to have our own i915fs, so that we could
> overwrite the address_space hooks for page migration and eviction and tha=
t
> sort of thing, which would make all these pages evictable. Atm you have t=
o
> =C4=A5ope our shrinker drops them on the floor, which I think is fairly
> confusing to core mm code (it's kinda like page eviction worked way back
> before rmaps).
>

Thanks for the explanation. Your blog posts helped a lot to get me
started on hacking drm/i915 driver.

> Just an side really.
> -Daniel
>
> --
> Daniel Vetter
> Software Engineer, Intel Corporation
> http://blog.ffwll.ch
