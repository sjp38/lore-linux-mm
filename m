Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 38FDC6B02F4
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 12:23:54 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id k133so147311024ita.3
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 09:23:54 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [205.233.59.134])
        by mx.google.com with ESMTPS id p75si886307iod.27.2017.06.06.09.23.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 09:23:53 -0700 (PDT)
Date: Tue, 6 Jun 2017 18:23:43 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] mm,drm/i915: Mark pinned shmemfs pages as unevictable
Message-ID: <20170606162343.gqatr37kmiczeusi@hirez.programming.kicks-ass.net>
References: <20170606120436.8683-1-chris@chris-wilson.co.uk>
 <20170606121418.GM1189@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170606121418.GM1189@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Matthew Auld <matthew.auld@intel.com>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jun 06, 2017 at 02:14:18PM +0200, Michal Hocko wrote:
> That is certainly desirable. Peter has proposed a generic pin_page (or
> similar) API. What happened with it?

I got stuck on converting IB ... and I think someone thereafter made an
ever bigger mess of the pinning stuff. I don't know, I'd have to revisit
all that :/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
