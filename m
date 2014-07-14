Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id D4A1F6B0036
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 10:10:22 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id f8so1677811wiw.0
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 07:10:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id fw9si16017570wjb.82.2014.07.14.07.10.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Jul 2014 07:10:18 -0700 (PDT)
Message-ID: <53C3E4BE.2010505@redhat.com>
Date: Mon, 14 Jul 2014 10:10:06 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 2/3] mm: vmscan: remove all_unreclaimable() fix
References: <1405344049-19868-1-git-send-email-hannes@cmpxchg.org> <1405344049-19868-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1405344049-19868-3-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 07/14/2014 09:20 AM, Johannes Weiner wrote:
> As per Mel, use bool for reclaimability throughout and simplify
> the reclaimability tracking in shrink_zones().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Rik van Riel <riel@redhat.com>


- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJTw+S+AAoJEM553pKExN6DtvYH/RXaEx/lWC9UR5eRQ8nQy2L4
V87wVoWPXauuIeJrGurTV28cvqUW/JXNAmnONuGdRI//9jE2vMZmVi2X5V4CnGv2
zpMsM2MhIn7tzBKW7AlBLHBC9nUEIHpo+OA3IvCvQsgG5qWNkdWOTUv1xkiqTuuQ
Nu7pxiNH360Dp+g2VCuFU2+nrjcKKSolsMBqEvGGP+Dh3/G5EQpQ/lQJ0/a/4q1y
/ew0HCYRfH2/kCMKxixTtUXR7QcMw4L4AkD0fHoisRoyuVAws4QwYA4zB1FKpxgr
XIsVPLftQc8f+++Djone+RvPaPmUOvXrf8UdbxTG5wrfBJ9aPB5AuecWqOOO22g=
=3M3e
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
