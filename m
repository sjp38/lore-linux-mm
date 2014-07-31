Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 032C96B0035
	for <linux-mm@kvack.org>; Thu, 31 Jul 2014 11:38:46 -0400 (EDT)
Received: by mail-qa0-f51.google.com with SMTP id k15so2456426qaq.24
        for <linux-mm@kvack.org>; Thu, 31 Jul 2014 08:38:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f8si10317438qar.120.2014.07.31.08.38.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jul 2014 08:38:46 -0700 (PDT)
Message-ID: <53DA62FB.7000108@redhat.com>
Date: Thu, 31 Jul 2014 11:38:35 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg, vmscan: Fix forced scan of anonymous pages
References: <1406807385-5168-1-git-send-email-jmarchan@redhat.com> <1406807385-5168-3-git-send-email-jmarchan@redhat.com>
In-Reply-To: <1406807385-5168-3-git-send-email-jmarchan@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 07/31/2014 07:49 AM, Jerome Marchand wrote:
> When memory cgoups are enabled, the code that decides to force to
> scan anonymous pages in get_scan_count() compares global values
> (free, high_watermark) to a value that is restricted to a memory
> cgroup (file). It make the code over-eager to force anon scan.
> 
> For instance, it will force anon scan when scanning a memcg that
> is mainly populated by anonymous page, even when there is plenty of
> file pages to get rid of in others memcgs, even when swappiness ==
> 0. It breaks user's expectation about swappiness and hurts
> performance.
> 
> This patch make sure that forced anon scan only happens when there
> not enough file pages for the all zone, not just in one random
> memcg.
> 
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>

That fix is a lot smaller than I thought it would be. Nice.

Reviewed-by: Rik van Riel <riel@redhat.com>

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJT2mL7AAoJEM553pKExN6DbzsH/ArKqWXYFfz7/hjADJXz85aK
ygWdjpK18MbFeUMW3nL324j2567TXWpC2G7SgxSPjYnF/qvKjpoQHJk7WvisymjE
p+5jGQAxzXgjlq0usGoFRrWUnR6vkdjTx0K8r6MO/asMLbvDBjkXvaURHdcV6fx4
nUbkF/GRXGAGcnHOEks294w+8j8R50bugnX+IfmKo73eteNcMWU7Ga+b93kUmz3p
4EE2PRpRKFWtpTAhpFlFI46gfu+e7I1Ziu2pzNUlYOP3P7t9pRS8YOI5JNOnyDfi
lrbOXzoSqs6sbIlDd//A/p7u6Pzr+HnpbaxCrf9UCdNaMMqvb0gDQWv7221gI24=
=BfHz
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
