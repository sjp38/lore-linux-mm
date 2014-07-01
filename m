Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2A14A6B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 10:16:47 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id q59so9828636wes.27
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 07:16:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id fu10si12392707wic.31.2014.07.01.07.16.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jul 2014 07:16:38 -0700 (PDT)
Message-ID: <53B2C2A9.7030900@redhat.com>
Date: Tue, 01 Jul 2014 10:16:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v9] mm: support madvise(MADV_FREE)
References: <1404174975-22019-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1404174975-22019-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 06/30/2014 08:36 PM, Minchan Kim wrote:
> Linux doesn't have an ability to free pages lazy while other OS 
> already have been supported that named by madvise(MADV_FREE).
> 
> The gain is clear that kernel can discard freed pages rather than 
> swapping out or OOM if memory pressure happens.
> 
> Without memory pressure, freed pages would be reused by userspace 
> without another additional overhead(ex, page fault + allocation +
> zeroing).

> Cc: Michael Kerrisk <mtk.manpages@gmail.com> Cc: Linux API
> <linux-api@vger.kernel.org> Cc: Hugh Dickins <hughd@google.com> Cc:
> Johannes Weiner <hannes@cmpxchg.org> Cc: Rik van Riel
> <riel@redhat.com> Cc: KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> Cc: Mel Gorman <mgorman@suse.de> 
> Cc: Jason Evans <je@fb.com> Cc: Zhang Yanfei
> <zhangyanfei@cn.fujitsu.com> Signed-off-by: Minchan Kim
> <minchan@kernel.org>

Acked-by: Rik van Riel <riel@redhat.com>


- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJTssKpAAoJEM553pKExN6DspUH/3fdn95zVIA6GGfmFG/g05Fm
SYv82v0ee2gGM7yRGeVkFSVuj5qYCneyJeprERHBs43huafqqnWd9MMcZxxskNk7
MpyVmRsCh54qC2Y6Rqu5E15jEKjCcxss1vCbHp0ExtZHnfU29re+JB0oRE9IKszW
p2r6rsolHtNY4otTAQ6pAtA6ioH1E0xppK5mpqHAUpFJuq3PqXbSsptFdl6AJciw
25zBB6iOdVgpciYwkn7yBvaZiY+sRuiRFSAH0klQVHlX0ZueIXYnJtybVhHSqGs/
Nu1/zhrRrohOcj0Ka6cTJBBH2RyXTmgcurfTUlI4IZzcDqJWtuXjXBty0wkhIZQ=
=RjYx
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
