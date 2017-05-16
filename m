Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 31A3E6B03A6
	for <linux-mm@kvack.org>; Tue, 16 May 2017 05:31:46 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p134so33981538wmg.3
        for <linux-mm@kvack.org>; Tue, 16 May 2017 02:31:46 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id k127si13467059wmg.128.2017.05.16.02.31.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 02:31:45 -0700 (PDT)
Date: Tue, 16 May 2017 10:31:19 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH] drm: use kvmalloc_array for drm_malloc*
Message-ID: <20170516093119.GW19912@nuc-i3427.alporthouse.com>
References: <20170516090606.5891-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170516090606.5891-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@intel.com>, Jani Nikula <jani.nikula@linux.intel.com>, Sean Paul <seanpaul@chromium.org>, David Airlie <airlied@linux.ie>, Michal Hocko <mhocko@suse.com>

On Tue, May 16, 2017 at 11:06:06AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> drm_malloc* has grown their own kmalloc with vmalloc fallback
> implementations. MM has grown kvmalloc* helpers in the meantime. Let's
> use those because it a) reduces the code and b) MM has a better idea
> how to implement fallbacks (e.g. do not vmalloc before kmalloc is tried
> with __GFP_NORETRY).

Better? The same idea. The only difference I was reluctant to hand out
large pages for long lived objects. If that's the wisdom of the core mm,
so be it.
Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
