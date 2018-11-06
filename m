Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1146B0290
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 19:03:19 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id j192-v6so7645483oih.11
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 16:03:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l22sor9093522otn.146.2018.11.05.16.03.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 16:03:18 -0800 (PST)
MIME-Version: 1.0
References: <20181105111348.182492-1-vovoy@chromium.org> <20181105130209.GI4361@dhcp22.suse.cz>
 <CAEHM+4r4gRiBdRHaziiAFzwB5VD785zpUEr31zFLbx4sNUW6TQ@mail.gmail.com> <20181105164135.GM4361@dhcp22.suse.cz>
In-Reply-To: <20181105164135.GM4361@dhcp22.suse.cz>
From: Kuo-Hsin Yang <vovoy@chromium.org>
Date: Tue, 6 Nov 2018 08:03:06 +0800
Message-ID: <CAEHM+4qOeQAK+QA-sqpcnfZ36zDiO_3ScYFxnY_ur7y+u_P9BA@mail.gmail.com>
Subject: Re: [PATCH v4] mm, drm/i915: mark pinned shmemfs pages as unevictable
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>

On Tue, Nov 6, 2018 at 12:41 AM Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 05-11-18 22:33:13, Kuo-Hsin Yang wrote:
> > OK, this function should not be specific to shmem pages.
> >
> > Is it OK to remove the #ifdef SHMEM surrounding check_move_unevictable_pages?
>
> Yes, I think so.

Thanks for you review.
