Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id A2FE06B0292
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 19:04:29 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id r68-v6so7653023oie.12
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 16:04:29 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q6sor12248607ote.132.2018.11.05.16.04.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 16:04:28 -0800 (PST)
MIME-Version: 1.0
References: <20181105111348.182492-1-vovoy@chromium.org> <516428f4-93a9-9ed7-426e-344ba91d81e0@intel.com>
In-Reply-To: <516428f4-93a9-9ed7-426e-344ba91d81e0@intel.com>
From: Kuo-Hsin Yang <vovoy@chromium.org>
Date: Tue, 6 Nov 2018 08:04:17 +0800
Message-ID: <CAEHM+4rCPdkv6-3sKZZHh5oBophz8GuF991pLgdue8gMDeXoTA@mail.gmail.com>
Subject: Re: [PATCH v4] mm, drm/i915: mark pinned shmemfs pages as unevictable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Michal Hocko <mhocko@suse.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Nov 6, 2018 at 2:52 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 11/5/18 3:13 AM, Kuo-Hsin Yang wrote:
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
> At a minimum, I think we owe some documentation here of how to tell
> approximately how much memory i915 is consuming with this mechanism.
> The debugfs stuff sounds like a halfway reasonable way to approximate
> it, although it's imperfect.

OK, I will add more comments here.
