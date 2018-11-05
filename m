Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA78E6B000D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 13:52:39 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b88-v6so10110658pfj.4
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 10:52:39 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 1-v6si24145350pln.299.2018.11.05.10.52.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 10:52:38 -0800 (PST)
Subject: Re: [PATCH v4] mm, drm/i915: mark pinned shmemfs pages as unevictable
References: <20181105111348.182492-1-vovoy@chromium.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <516428f4-93a9-9ed7-426e-344ba91d81e0@intel.com>
Date: Mon, 5 Nov 2018 10:52:34 -0800
MIME-Version: 1.0
In-Reply-To: <20181105111348.182492-1-vovoy@chromium.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kuo-Hsin Yang <vovoy@chromium.org>, linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Michal Hocko <mhocko@suse.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>

On 11/5/18 3:13 AM, Kuo-Hsin Yang wrote:
> -These are currently used in two places in the kernel:
> +These are currently used in three places in the kernel:
>  
>   (1) By ramfs to mark the address spaces of its inodes when they are created,
>       and this mark remains for the life of the inode.
> @@ -154,6 +154,8 @@ These are currently used in two places in the kernel:
>       swapped out; the application must touch the pages manually if it wants to
>       ensure they're in memory.
>  
> + (3) By the i915 driver to mark pinned address space until it's unpinned.

At a minimum, I think we owe some documentation here of how to tell
approximately how much memory i915 is consuming with this mechanism.
The debugfs stuff sounds like a halfway reasonable way to approximate
it, although it's imperfect.
