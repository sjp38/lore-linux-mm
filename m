Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id DD2A16B02EA
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 04:19:27 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id q23so8458100otl.1
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 01:19:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r132-v6sor7457018oih.58.2018.11.06.01.19.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 01:19:26 -0800 (PST)
MIME-Version: 1.0
References: <20181106090352.64114-1-vovoy@chromium.org> <20181106090839.GE27423@dhcp22.suse.cz>
In-Reply-To: <20181106090839.GE27423@dhcp22.suse.cz>
From: Kuo-Hsin Yang <vovoy@chromium.org>
Date: Tue, 6 Nov 2018 17:19:15 +0800
Message-ID: <CAEHM+4rdeGqryvJqTkV_ocEA8y7dOXS_Nx+O3ouFZ44j9wzm=g@mail.gmail.com>
Subject: Re: [PATCH v5] mm, drm/i915: mark pinned shmemfs pages as unevictable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>

On Tue, Nov 6, 2018 at 5:08 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 06-11-18 17:03:51, Kuo-Hsin Yang wrote:
> > The i915 driver uses shmemfs to allocate backing storage for gem
> > objects. These shmemfs pages can be pinned (increased ref count) by
> > shmem_read_mapping_page_gfp(). When a lot of pages are pinned, vmscan
> > wastes a lot of time scanning these pinned pages. In some extreme case,
> > all pages in the inactive anon lru are pinned, and only the inactive
> > anon lru is scanned due to inactive_ratio, the system cannot swap and
> > invokes the oom-killer. Mark these pinned pages as unevictable to speed
> > up vmscan.
> >
> > Export pagevec API check_move_unevictable_pages().
> >
> > This patch was inspired by Chris Wilson's change [1].
> >
> > [1]: https://patchwork.kernel.org/patch/9768741/
> >
> > Cc: Chris Wilson <chris@chris-wilson.co.uk>
> > Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> > Cc: Peter Zijlstra <peterz@infradead.org>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Dave Hansen <dave.hansen@intel.com>
> > Signed-off-by: Kuo-Hsin Yang <vovoy@chromium.org>
> > Acked-by: Michal Hocko <mhocko@suse.com>
>
> please make it explicit that the ack applies to mm part as i've
> mentioned when giving my ack to the previous version.
>
> E.g.
> Acked-by: Michal Hocko <mhocko@use.com> # mm part
>
> because i am not familiar with the drm code to ack any changes there.

Got it. Thanks.
