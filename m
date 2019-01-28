Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66C1CC282C8
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 19:54:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A4D12087F
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 19:54:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A4D12087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAEDA8E0002; Mon, 28 Jan 2019 14:54:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0D5D8E0001; Mon, 28 Jan 2019 14:54:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 987338E0002; Mon, 28 Jan 2019 14:54:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53DFC8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 14:54:27 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id o23so12542981pll.0
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:54:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=spqcKaMhg2D1agEtkYZsyaEWcvon3hwAsAnZw+kg3mI=;
        b=cEwKBhobfPM5OkVFljnMOG6AIJjDJhkV9ubOKlExI42IU/PGlcAfxqCVIkOYSNPSfQ
         iKAnCkUzqzegub8o1wbgVdcRDCWdUFKKJ/2fZykKFr/pYvJY45I/uvF2Er9Xo70eNXOI
         0DUpkLDN7GlW/ZBlkAt+Kvt0mdyaFPfjSLB9wJR2FA+NKl2oRVKLeQXLYHPzxw0eCTFa
         elqzr0DCFKZ0LbvnZZ3XSI0BXZ7vbTqbRl3jNVuZYdiy9LCKakahOIUMpUqi0qEwEXkH
         g6mhTztfF1WejZhT37YMVl63xvJMK9ziF1jC0Se+HCu8IBHCBZWgapl52aaEXTSOr4cz
         9bCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukeNIFWHa6oi6wTEJcave38oJw/BNXIkUYx4ywU04MuPwJsxIeGj
	ZaVb6hPPGNPZhSe4DxyA+E1jGmSSSINQvbVTskzD8tC7vy61jWiPuCIIdVRKFt0JZ2inaXhH9Ia
	skIg2h5M1HkaPK11S5I+WfBz3VMho+x/qzeKaX7JEIxHya50Hd+7VwRb0cmkfehcQyg==
X-Received: by 2002:a17:902:aa4c:: with SMTP id c12mr22988326plr.48.1548705266966;
        Mon, 28 Jan 2019 11:54:26 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6neXQfW2VtB9bX1K2hD7vYLsee+8I8ZX7um0cOJJsdhfY7/o061jQ357c/rTVYFUeiDdiP
X-Received: by 2002:a17:902:aa4c:: with SMTP id c12mr22988305plr.48.1548705266283;
        Mon, 28 Jan 2019 11:54:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548705266; cv=none;
        d=google.com; s=arc-20160816;
        b=nX4ZyeMTWO6ioczxtcnExTGW+J9vu9WOL6ZKOYkakpmGPw7dpMD7VEhFV1gjmHBBUn
         8Ax105avD+4xneD5wW5QiYBQkRG4JzLkSvDy63kPuaU6KxZFWgIkS91PxtRxQwFpNTVh
         X/58pFVEuI5EqgyEAU2kGtyWMsrdUXfAFM8Ro7e05vRhH7JDw+MbkXy296rfHf9AjWla
         Hw/wD5k3cttyUHK8TsTD++IxMhGLzPDObSyA147AkX8bbAuXU3vZIBTTULKMZ1JL0rCx
         ePn2MTjYDDbV9oe1fibYU7O58FSMDy1K4KpJf4ZEBAD81DTlylA9q+K/7HoLEa07sgI3
         e20Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=spqcKaMhg2D1agEtkYZsyaEWcvon3hwAsAnZw+kg3mI=;
        b=SRwo8K64Dz0+elea4ID6IDt5J+/9u6vi6cMVmEiwThXxBJ0dPdvN58iQsTfTjSV3Xn
         C5dA/v5B7GU0azsYmEejfKbZkpqyElyu1eLRO43gViROBlLLpiodG8TYiNbJ5CzrkftV
         dPmh9oN+i4gIfDimTCFPNafB9xatPCFhpqORqHtYTl5JK60JOM9L8FGsRZYz20f6KPbC
         9JcEZZEXBA7jbG/wQ5NKm8kCMZ3+tRdAh+bZfYgJpA0hnzqPnQBNY41QiC1geMJHoA3s
         lSNd+phua6iEM/MMtF4f46qAW1BlPbNb4hQ1ew6mW0iczwfWqg4DAEc7oB4l0u8kifGD
         a5vA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h88si2219937pfa.49.2019.01.28.11.54.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 11:54:26 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 103181AE5;
	Mon, 28 Jan 2019 19:54:25 +0000 (UTC)
Date: Mon, 28 Jan 2019 11:54:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Rik van Riel <riel@surriel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com,
 Johannes Weiner <hannes@cmpxchg.org>, Chris Mason <clm@fb.com>, Roman
 Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm,slab,vmscan: accumulate gradual pressure on small
 slabs
Message-Id: <20190128115424.df3f4647023e9e43e75afe67@linux-foundation.org>
In-Reply-To: <20190128143535.7767c397@imladris.surriel.com>
References: <20190128143535.7767c397@imladris.surriel.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2019 14:35:35 -0500 Rik van Riel <riel@surriel.com> wrote:

> There are a few issues with the way the number of slab objects to
> scan is calculated in do_shrink_slab.  First, for zero-seek slabs,
> we could leave the last object around forever. That could result
> in pinning a dying cgroup into memory, instead of reclaiming it.
> The fix for that is trivial.
> 
> Secondly, small slabs receive much more pressure, relative to their
> size, than larger slabs, due to "rounding up" the minimum number of
> scanned objects to batch_size.
> 
> We can keep the pressure on all slabs equal relative to their size
> by accumulating the scan pressure on small slabs over time, resulting
> in sometimes scanning an object, instead of always scanning several.
> 
> This results in lower system CPU use, and a lower major fault rate,
> as actively used entries from smaller caches get reclaimed less
> aggressively, and need to be reloaded/recreated less often.
> 
> Fixes: 4b85afbdacd2 ("mm: zero-seek shrinkers")
> Fixes: 172b06c32b94 ("mm: slowly shrink slabs with a relatively small number of objects")
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Chris Mason <clm@fb.com>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: kernel-team@fb.com
> Tested-by: Chris Mason <clm@fb.com>

I added your Signed-off-by:

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -488,18 +488,28 @@ static unsigned long do_shrink_slab(struct shrink_control *shrinkctl,
>  		 * them aggressively under memory pressure to keep
>  		 * them from causing refetches in the IO caches.
>  		 */
> -		delta = freeable / 2;
> +		delta = (freeable + 1)/ 2;
>  	}
>  
>  	/*
>  	 * Make sure we apply some minimal pressure on default priority
> -	 * even on small cgroups. Stale objects are not only consuming memory
> +	 * even on small cgroups, by accumulating pressure across multiple
> +	 * slab shrinker runs. Stale objects are not only consuming memory
>  	 * by themselves, but can also hold a reference to a dying cgroup,
>  	 * preventing it from being reclaimed. A dying cgroup with all
>  	 * corresponding structures like per-cpu stats and kmem caches
>  	 * can be really big, so it may lead to a significant waste of memory.
>  	 */
> -	delta = max_t(unsigned long long, delta, min(freeable, batch_size));
> +	if (!delta) {
> +		shrinker->small_scan += freeable;
> +
> +		delta = shrinker->small_scan >> priority;
> +		shrinker->small_scan -= delta << priority;
> +
> +		delta *= 4;
> +		do_div(delta, shrinker->seeks);

What prevents shrinker->small_scan from over- or underflowing over time?

> +	}
>  
>  	total_scan += delta;
>  	if (total_scan < 0) {

I'll add this:





whitespace fixes, per Roman

--- a/mm/vmscan.c~mmslabvmscan-accumulate-gradual-pressure-on-small-slabs-fix
+++ a/mm/vmscan.c
@@ -488,7 +488,7 @@ static unsigned long do_shrink_slab(stru
 		 * them aggressively under memory pressure to keep
 		 * them from causing refetches in the IO caches.
 		 */
-		delta = (freeable + 1)/ 2;
+		delta = (freeable + 1) / 2;
 	}
 
 	/*
@@ -508,7 +508,6 @@ static unsigned long do_shrink_slab(stru
 
 		delta *= 4;
 		do_div(delta, shrinker->seeks);
-
 	}
 
 	total_scan += delta;
_

