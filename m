Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id F30866B0005
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 08:06:24 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id y81-v6so14582107oig.20
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 05:06:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l3sor5988817ota.177.2018.11.01.05.06.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Nov 2018 05:06:23 -0700 (PDT)
MIME-Version: 1.0
References: <20181031081945.207709-1-vovoy@chromium.org> <039b2768-39ff-6196-9615-1f0302ee3e0e@intel.com>
In-Reply-To: <039b2768-39ff-6196-9615-1f0302ee3e0e@intel.com>
From: Vovo Yang <vovoy@chromium.org>
Date: Thu, 1 Nov 2018 20:06:12 +0800
Message-ID: <CAEHM+4q7V3d+EiHR6+TKoJC=6Ga0eCLWik0oJgDRQCpWps=wMA@mail.gmail.com>
Subject: Re: [PATCH v3] mm, drm/i915: mark pinned shmemfs pages as unevictable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: owner-linux-mm@kvack.org, linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.orglinux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Michal Hocko <mhocko@suse.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Oct 31, 2018 at 10:19 PM Dave Hansen <dave.hansen@intel.com> wrote:
> On 10/31/18 1:19 AM, owner-linux-mm@kvack.org wrote:
> > -These are currently used in two places in the kernel:
> > +These are currently used in three places in the kernel:
> >
> >   (1) By ramfs to mark the address spaces of its inodes when they are created,
> >       and this mark remains for the life of the inode.
> > @@ -154,6 +154,8 @@ These are currently used in two places in the kernel:
> >       swapped out; the application must touch the pages manually if it wants to
> >       ensure they're in memory.
> >
> > + (3) By the i915 driver to mark pinned address space until it's unpinned.
>
> mlock() and ramfs usage are pretty easy to track down.  /proc/$pid/smaps
> or /proc/meminfo can show us mlock() and good ol' 'df' and friends can
> show us ramfs the extent of pinned memory.
>
> With these, if we see "Unevictable" in meminfo bump up, we at least have
> a starting point to find the cause.
>
> Do we have an equivalent for i915?

AFAIK, there is no way to get i915 unevictable page count, some
modification to i915 debugfs is required.
