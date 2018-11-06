Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id E590D6B0331
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 09:14:22 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id s22-v6so8932604oie.9
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 06:14:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3-v6sor5691865oin.29.2018.11.06.06.14.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 06:14:22 -0800 (PST)
MIME-Version: 1.0
References: <20181106093100.71829-1-vovoy@chromium.org> <20181106132324.17390-1-chris@chris-wilson.co.uk>
In-Reply-To: <20181106132324.17390-1-chris@chris-wilson.co.uk>
From: Kuo-Hsin Yang <vovoy@chromium.org>
Date: Tue, 6 Nov 2018 22:14:10 +0800
Message-ID: <CAEHM+4qb0Q7jJNqowECGeU8ZqcWY8ZyQLrY-OgbvyM1D=BFqyA@mail.gmail.com>
Subject: Re: [PATCH v7] mm, drm/i915: mark pinned shmemfs pages as unevictable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>

On Tue, Nov 6, 2018 at 9:23 PM Chris Wilson <chris@chris-wilson.co.uk> wrote:
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
> Acked-by: Michal Hocko <mhocko@suse.com> # mm part
> Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>

Thanks for your fixes and review.
