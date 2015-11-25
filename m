Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 699736B0254
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 13:53:19 -0500 (EST)
Received: by wmww144 with SMTP id w144so192187925wmw.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 10:53:19 -0800 (PST)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id pu5si36428915wjc.50.2015.11.25.10.53.18
        for <linux-mm@kvack.org>;
        Wed, 25 Nov 2015 10:53:18 -0800 (PST)
Date: Wed, 25 Nov 2015 18:53:10 +0000
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH v2] drm/i915: Disable shrinker for non-swapped backed
 objects
Message-ID: <20151125185310.GH22980@nuc-i3427.alporthouse.com>
References: <20151124231738.GA15770@nuc-i3427.alporthouse.com>
 <1448476616-5257-1-git-send-email-chris@chris-wilson.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448476616-5257-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: linux-mm@kvack.org, Akash Goel <akash.goel@intel.com>, sourab.gupta@intel.com

On Wed, Nov 25, 2015 at 06:36:56PM +0000, Chris Wilson wrote:
> +static bool swap_available(void)
> +{
> +	return total_swap_pages || frontswap_enabled;
> +}

Of course these aren't exported symbols, so really this is just RFC
right now.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
