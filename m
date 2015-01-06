Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7602B6B00A1
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 21:45:47 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id k14so28598259wgh.1
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 18:45:47 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v4si117554911wjx.164.2015.01.05.18.45.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jan 2015 18:45:46 -0800 (PST)
Message-ID: <54AB4C4C.5030004@redhat.com>
Date: Mon, 05 Jan 2015 21:45:32 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3 1/2] mm, vmscan: prevent kswapd livelock due to pfmemalloc-throttled
 process being killed
References: <1420448203-30212-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <1420448203-30212-1-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Vladimir Davydov <vdavydov@parallels.com>, stable@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 01/05/2015 03:56 AM, Vlastimil Babka wrote:
> Charles Shirron and Paul Cassella from Cray Inc have reported
> kswapd stuck in a busy loop with nothing left to balance, but
> kswapd_try_to_sleep() failing to sleep. Their analysis found the
> cause to be a combination of several factors:

> Fixes: 5515061d22f0 ("mm: throttle direct reclaimers if PF_MEMALLOC
> reserves are low and swap is backed by network storage") 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz> Signed-off-by:
> Vladimir Davydov <vdavydov@parallels.com> Cc:
> <stable@vger.kernel.org>   # v3.6+ Cc: Mel Gorman
> <mgorman@suse.de> Cc: Johannes Weiner <hannes@cmpxchg.org> Cc:
> Michal Hocko <mhocko@suse.cz> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUq0xLAAoJEM553pKExN6D8ZgH/3AjsMKmA/JytTf5WOjpO0+W
ozN7ttYjYfIAFytYymPYkbm5/8pLBhy9HM9szMijRa+vhLyiGr5CSB0jTTU+1ImP
BynATfT4NbAHssosMRCHqRep/NmGkaV0qkiL4ndEaCwiGz/x481jgvHXP3GdHxbu
kIt8gYrP1gK3yM+yGk06nhsM9QU0C0P/ngzAvMTrch/nKr679Uu+chyLAskms7hZ
+x0OZkkN1gWGDCn55swLPURbIPnWedml+HB19e30fehLtpCcPoTzc1Zr46fPcI4O
BhJJX8QCWhpYdXqE1TZCid3zV4wPTJKAe1MskzBCgo3ELYE7ll1gM24QcfrpdgA=
=0cv0
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
