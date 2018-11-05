Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9EA7E6B026B
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:41:40 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id p25-v6so456212eds.15
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:41:40 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x16-v6si11539707eds.184.2018.11.05.08.41.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 08:41:39 -0800 (PST)
Date: Mon, 5 Nov 2018 17:41:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4] mm, drm/i915: mark pinned shmemfs pages as unevictable
Message-ID: <20181105164135.GM4361@dhcp22.suse.cz>
References: <20181105111348.182492-1-vovoy@chromium.org>
 <20181105130209.GI4361@dhcp22.suse.cz>
 <CAEHM+4r4gRiBdRHaziiAFzwB5VD785zpUEr31zFLbx4sNUW6TQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAEHM+4r4gRiBdRHaziiAFzwB5VD785zpUEr31zFLbx4sNUW6TQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kuo-Hsin Yang <vovoy@chromium.org>
Cc: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>

On Mon 05-11-18 22:33:13, Kuo-Hsin Yang wrote:
> On Mon, Nov 5, 2018 at 9:02 PM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Mon 05-11-18 19:13:48, Kuo-Hsin Yang wrote:
[...]
> > > + * @pvec: pagevec with pages to check
> > >   *
> > > - * Checks pages for evictability and moves them to the appropriate lru list.
> > > - *
> > > - * This function is only used for SysV IPC SHM_UNLOCK.
> > > + * This function is only used to move shmem pages.
> >
> > I do not really see anything that would be shmem specific here. We can
> > use this function for any LRU pages unless I am missing something
> > obscure. I would just drop the last sentence.
> 
> OK, this function should not be specific to shmem pages.
> 
> Is it OK to remove the #ifdef SHMEM surrounding check_move_unevictable_pages?

Yes, I think so.
-- 
Michal Hocko
SUSE Labs
