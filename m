Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 94A3C280310
	for <linux-mm@kvack.org>; Mon, 21 Aug 2017 11:57:43 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s14so287175272pgs.4
        for <linux-mm@kvack.org>; Mon, 21 Aug 2017 08:57:43 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id w189si2638614pgb.273.2017.08.21.08.57.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Aug 2017 08:57:42 -0700 (PDT)
Date: Mon, 21 Aug 2017 17:57:37 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] mm,drm/i915: Mark pinned shmemfs pages as unevictable
Message-ID: <20170821155737.dewjjal3cou52ruw@hirez.programming.kicks-ass.net>
References: <20170606120436.8683-1-chris@chris-wilson.co.uk>
 <20170606121418.GM1189@dhcp22.suse.cz>
 <150314853540.7354.10275185301153477504@mail.alporthouse.com>
 <20170821140641.GN25956@dhcp22.suse.cz>
 <150332781184.13047.15448500819676507290@mail.alporthouse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150332781184.13047.15448500819676507290@mail.alporthouse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Michal Hocko <mhocko@suse.com>, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Matthew Auld <matthew.auld@intel.com>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Aug 21, 2017 at 04:03:31PM +0100, Chris Wilson wrote:
> My googlefu says "[RFC][PATCH 1/5] mm: Introduce VM_PINNED and
> interfaces" is the series, and it certainly targets the very same
> problem.
> 
> Peter, is that the latest version?

Probably, I ran into the Infiniband code and couldn't convince anybody
to help me out :/ Its been stale for a few years now I'm afraid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
