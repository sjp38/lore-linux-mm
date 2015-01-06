Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6CCC86B00A4
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 21:58:21 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id a1so28654267wgh.37
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 18:58:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id cu6si21067700wib.36.2015.01.05.18.58.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jan 2015 18:58:20 -0800 (PST)
Message-ID: <54AB4F3F.50103@redhat.com>
Date: Mon, 05 Jan 2015 21:58:07 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3 2/2] mm, vmscan: wake up all pfmemalloc-throttled processes
 at once
References: <1420448203-30212-1-git-send-email-vbabka@suse.cz> <1420448203-30212-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1420448203-30212-2-git-send-email-vbabka@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, stable@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 01/05/2015 03:56 AM, Vlastimil Babka wrote:
> Kswapd in balance_pgdate() currently uses wake_up() on processes
> waiting in throttle_direct_reclaim(), which only wakes up a single
> process. This might leave processes waiting for longer than
> necessary, until the check is reached in the next loop iteration.
> Processes might also be left waiting if zone was fully balanced in
> single iteration. Note that the comment in balance_pgdat() also
> says "Wake them", so waking up a single process does not seem
> intentional.
> 
> Thus, replace wake_up() with wake_up_all().
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz> Cc: Mel Gorman
> <mgorman@suse.de> Cc: Johannes Weiner <hannes@cmpxchg.org> Cc:
> Michal Hocko <mhocko@suse.cz> Cc: Vladimir Davydov
> <vdavydov@parallels.com> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUq08+AAoJEM553pKExN6D9bEIAKV916k0OguiyAGIXrgjPrba
3W2eQ2FFWIm6KwumPas7t6jBzR11yFhpAIACf6nNt12EmH73UwaW2z6vdYque4c+
HU79DXTNTQ91xJfXI8XfNsZW/s8zpCZ+Sm08N7/O7k6c76yKR+owXmoSnjb2Q4N9
O0F0db3Jkd52sH/2l+LCUKrTeI9fRBrKnpAv7FAhZ5go8N7tdtIjYv8hhpIZ/83F
WSRsORt0VKOx0an+JO09e5f6R+RF7RAqiU6yUdDAk52CJzyRqECksLxDOvw81OHD
QUT5TuMVNoqXNJxFpQvyI8Dn82d1CiisX2Wztcic4OlxPJQ6gK04SmeWMXw8Ijw=
=pnD6
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
