Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id C013A6B0311
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 06:49:58 -0500 (EST)
Received: by mail-oi1-f198.google.com with SMTP id g138-v6so8642510oib.14
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 03:49:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 3-v6sor5469651oin.29.2018.11.06.03.49.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Nov 2018 03:49:57 -0800 (PST)
MIME-Version: 1.0
References: <20181106093100.71829-1-vovoy@chromium.org> <154150241813.6179.68008798371252810@skylake-alporthouse-com>
In-Reply-To: <154150241813.6179.68008798371252810@skylake-alporthouse-com>
From: Kuo-Hsin Yang <vovoy@chromium.org>
Date: Tue, 6 Nov 2018 19:49:46 +0800
Message-ID: <CAEHM+4rEibRffjO0dDncqRpc++8cAOpk-E0PNMW-4E-cMjkNnQ@mail.gmail.com>
Subject: Re: [PATCH v6] mm, drm/i915: mark pinned shmemfs pages as unevictable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>

On Tue, Nov 6, 2018 at 7:07 PM Chris Wilson <chris@chris-wilson.co.uk> wrote:
> This gave disappointing syslatency results until I put a cond_resched()
> here and moved the one in put_pages_gtt to before the page alloc, see
> https://patchwork.freedesktop.org/patch/260332/
>
> The last really nasty wart for syslatency is the spin in
> i915_gem_shrinker, for which I'm investigating
> https://patchwork.freedesktop.org/patch/260365/
>
> All 3 patches together give very reasonable syslatency results! (So
> good that it's time to find a new worst case scenario!)
>
> The challenge for the patch as it stands, is who lands it? We can take
> it through drm-intel (for merging in 4.21) but need Andrew's ack on top
> of all to agree with that path. Or we split the patch and only land the
> i915 portion once we backmerge the mm tree. I think pushing the i915
> portion through the mm tree is going to cause the most conflicts, so
> would recommend against that.

Splitting the patch and landing the mm part first sounds reasonable to me.
