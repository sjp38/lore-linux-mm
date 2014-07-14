Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id EEBED6B0035
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 10:09:36 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id dc16so3229164qab.8
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 07:09:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t14si15481894qac.66.2014.07.14.07.09.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jul 2014 07:09:36 -0700 (PDT)
Message-ID: <53C3E494.90909@redhat.com>
Date: Mon, 14 Jul 2014 10:09:24 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 1/3] mm: vmscan: rework compaction-ready signaling in
 direct reclaim fix
References: <1405344049-19868-1-git-send-email-hannes@cmpxchg.org> <1405344049-19868-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1405344049-19868-2-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 07/14/2014 09:20 AM, Johannes Weiner wrote:
> As per Mel, replace out label with breaks from the loop.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Rik van Riel <riel@redhat.com>

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJTw+SUAAoJEM553pKExN6Dj4wH/imfBq+85Kpjrw4NQltD+uUt
0pAzt/SX9IfiUcowi/1i1jWUKhMAfrY4SCG14g3ErKnIprMT8oa9ujRGCpnnZud2
eqLDFIHM8BlLNfIOV6a96+i1JpFDLbNL8WBjlew6X7ZDZamUG6j+0XxBOtwVemn6
Yj+cubH6mgPtovGRHdEDnyb4JOw5eue4/vIpumdTak3mnKghRpAxdN5tq7h13e1a
w/tweAWFspYHBkUj6FjeGiXrttNF7ToOy0cJeypZJZJfZFRwHBYStTe81iLa7jld
eNmfr48eLjnHrvZAN+lFm/DPuqU4ISuoCnL9N67OCudLrj8YbBzw8tOYNvff7fw=
=bbE9
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
