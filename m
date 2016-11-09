Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id C44236B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 13:36:16 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id rf5so78743025pab.3
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 10:36:16 -0800 (PST)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id z14si638389pgh.163.2016.11.09.10.36.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 10:36:15 -0800 (PST)
Received: by mail-pf0-x234.google.com with SMTP id d2so130992394pfd.0
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 10:36:15 -0800 (PST)
Date: Wed, 9 Nov 2016 10:36:06 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2] drm/i915: Make GPU pages movable
In-Reply-To: <20161109112835.kivhola7ux3lw4s6@phenom.ffwll.local>
Message-ID: <alpine.LSU.2.11.1611091034470.1547@eggly.anvils>
References: <1478271776-1194-1-git-send-email-akash.goel@intel.com> <1478271776-1194-2-git-send-email-akash.goel@intel.com> <20161109112835.kivhola7ux3lw4s6@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: akash.goel@intel.com, intel-gfx@lists.freedesktop.org, Chris Wilson <chris@chris-wilson.co.uk>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Sourab Gupta <sourab.gupta@intel.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 9 Nov 2016, Daniel Vetter wrote:
> 
> Hi all -mm folks!
> 
> Any feedback on these two? It's kinda an intermediate step towards a
> full-blown gemfs, and I think useful for that. Or do we need to go
> directly to our own backing storage thing? Aside from ack/nack from -mm I
> think this is ready for merging.

I'm currently considering them at last: will report back later.

Full-blown gemfs does not come in here, of course; but let me
fire a warning shot since you mention it: if it's going to use swap,
then we shall probably have to nak it in favour of continuing to use 
infrastructure from mm/shmem.c.  I very much understand why you would
love to avoid that dependence, but I doubt it can be safely bypassed.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
