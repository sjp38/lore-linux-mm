Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED3DE6B031B
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 07:14:49 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id v72so11398595pgb.10
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 04:14:49 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x3-v6si46527403plb.262.2018.11.06.04.14.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 04:14:48 -0800 (PST)
Date: Tue, 6 Nov 2018 13:14:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v6] mm, drm/i915: mark pinned shmemfs pages as unevictable
Message-ID: <20181106121446.GL27423@dhcp22.suse.cz>
References: <20181106093100.71829-1-vovoy@chromium.org>
 <154150241813.6179.68008798371252810@skylake-alporthouse-com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154150241813.6179.68008798371252810@skylake-alporthouse-com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Kuo-Hsin Yang <vovoy@chromium.org>, intel-gfx@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>

On Tue 06-11-18 11:06:58, Chris Wilson wrote:
[...]
> The challenge for the patch as it stands, is who lands it? We can take
> it through drm-intel (for merging in 4.21) but need Andrew's ack on top
> of all to agree with that path. Or we split the patch and only land the
> i915 portion once we backmerge the mm tree. I think pushing the i915
> portion through the mm tree is going to cause the most conflicts, so
> would recommend against that.

I usually prefer new exports to go along with their users. I am pretty
sure that the core mm change can be routed via whatever tree needs that.
Up to Andrew but this doesn't seem to be conflicting with anything that
is going on in MM.
-- 
Michal Hocko
SUSE Labs
