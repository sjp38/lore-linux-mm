Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A917C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:43:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01F402184C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:43:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01F402184C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E9E98E0003; Tue, 26 Feb 2019 09:43:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 899598E0001; Tue, 26 Feb 2019 09:43:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B0198E0003; Tue, 26 Feb 2019 09:43:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 524398E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:43:01 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 207so10604556qkf.9
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:43:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version:sender;
        bh=M+j68POGamg6UGMdkb4TuBEO8+FAMEX8znScuT/RnAw=;
        b=seeBAATt4lNb5sqe9OInewdbAj5m3AOQKlbVX7QU5TDv3iS4Yemjy0NKWW3yf8XO3z
         GU8pxxSR/E+pAJWdH4OkuDJcdytMFLmCO59i549E5UgnhgyLOL/Zv9M3y6ycHHtmqobj
         T4H6MlD4RD+959l3BQxWc5pFmbNZy/BQg+sx+KFABbdCrwPAP+LfqvQanMZUqU4wEY00
         dQtNMmIckQOYAoe0vKWwKLkktJoEQQKmPiBLS69LqePJ3RsmVg/Co9JjL//mC8euIETR
         cKCcc4r6aVD1VHoPVnmuP9FiE26cu8rW11DbYxkcfxEAVi5lNdgsXKneXIVPMWhpZ4D2
         jy5Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: AHQUAubBFmrhPko3+5YHSuuBR1w7V12Coe5m45nu4oRQLJjl4ApKY3Ai
	j+ffM4h+zh8WoNPnMApEOLqrkz3osDqEen1UiQDCRQx2mkTs755edSh/WFwYUZeGyKFE0MIq1RC
	i5cP8eNFzOGXqctKAhbSFIxW4a4RnPZM4WrlHqpW5dpiumIrBJFCNf4+hU5PR89Ub5g==
X-Received: by 2002:a37:a612:: with SMTP id p18mr17316723qke.115.1551192181065;
        Tue, 26 Feb 2019 06:43:01 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbT5QKDgyk0MObj0aMuS/u4ioUaQlOvsJuYLfxW69BcKJu9nK1aJAr7EtShWOvHb2kEe/9D
X-Received: by 2002:a37:a612:: with SMTP id p18mr17316687qke.115.1551192180360;
        Tue, 26 Feb 2019 06:43:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551192180; cv=none;
        d=google.com; s=arc-20160816;
        b=grvP640eTu2+Ra811PNEBmDaYHoNlGXZVLoiJ2pt8PpsOzvCgAyIV7MXzrwSF8eweh
         HDR4Yjq2rhcJC1krhi3pQcOqKX8ImRxgO+Itvp1vQ3Q5gQhRHyMdFoI8JlcOVIxUWjsj
         SXHxqjTq+wYkRixt2T1jWE/UW77sw1sPShgKi1fpJtInyV+pZdPaJHE2oUWhAe9lURLz
         wt4fTwU0RtAYmJUZJZVYH22Qna9LQpw50sMOe9w/g3bo0iFH/prBrRLr5ZC0IWmtbE6P
         D+4AVTt2XhQi5S9yNLQLso5RqRYPi/Hpn4xcgaTU76SBz187fJOvmzcfOVP6vxqJJmrw
         hXJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:references:in-reply-to:date:cc:to:from:subject
         :message-id;
        bh=M+j68POGamg6UGMdkb4TuBEO8+FAMEX8znScuT/RnAw=;
        b=sU7AHNHAFG+v23f2R4INewH2I1EyPpiYBlXqiEwh4wPckYFoIhwCDzRLg1lF849JqZ
         aH5A02w98tM3f/xVKS2MUQxV9BM6l8JywT/apBnyzIXzhBT61k3i6Mtd2CyGCeMpWdyg
         C6WHtTcJ6PW5I4og2x4NOvBBFAXoWZzPktihgvqLjjtt1xZHQu5BQdUOBWc9vmiYNzJI
         n96xh89efQIcNsBM7puJ3O76x/iuB06037ccyCPpAuOuLPwZg9gQRrZr2L+6OnzKH1bu
         4GIFFyAxBiQKX0vuO0UdZho0AVAyz07trvi1d2MJGvZiWdE0AOooStYAKrvB24q8iVw/
         epzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id q31si5809584qvf.108.2019.02.26.06.42.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 06:42:59 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.91)
	(envelope-from <riel@shelob.surriel.com>)
	id 1gydwT-0002az-OQ; Tue, 26 Feb 2019 09:42:45 -0500
Message-ID: <63491909d5c7011b946a354000caace11d63cb84.camel@surriel.com>
Subject: Re: [PATCH 5/5] mm/vmscan: don't forcely shrink active anon lru list
From: Rik van Riel <riel@surriel.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Johannes Weiner
	 <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
 linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Vlastimil
 Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>
Date: Tue, 26 Feb 2019 09:42:45 -0500
In-Reply-To: <ea0f769b-29e6-8787-7b18-cb7b24c1cda3@virtuozzo.com>
References: <20190222174337.26390-1-aryabinin@virtuozzo.com>
	 <20190222174337.26390-5-aryabinin@virtuozzo.com>
	 <20190222182249.GC15440@cmpxchg.org>
	 <ea0f769b-29e6-8787-7b18-cb7b24c1cda3@virtuozzo.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-WS/NIoxTuxo0S9rJ9C/P"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-WS/NIoxTuxo0S9rJ9C/P
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2019-02-26 at 15:04 +0300, Andrey Ryabinin wrote:

> I think we should leave anon aging only for !SCAN_FILE cases.
> At least aging was definitely invented for the SCAN_FRACT mode which
> was the
> main mode at the time it was added by the commit:

> and I think would be reasonable to  avoid the anon aging in the
> SCAN_FILE case.
> Because if workload generates enough inactive file pages we never go
> to the SCAN_FRACT,
> so aging is just as useless as with no swap case.

There are a few different cases here.

If you NEVER end up scanning or evicting anonymous
pages, scanning them is indeed a waste of time.

However, if you occasionally end pushing something
into swap, it is very useful to know that the pages
that did get pushed to swap had been sitting on the
inactive list for a very long time, and had not been
used in that time.

To limit the amount of wasted work, only SWAP_CLUSTER_MAX
pages are moved from the active_anon list to the inactive_anon
list at a time.

I suppose that could be gated behind a check whether or
not the system has swap space configured, so no anon
pages are ever scanned if the system has no swap space.

--=20
All Rights Reversed.

--=-WS/NIoxTuxo0S9rJ9C/P
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlx1UGUACgkQznnekoTE
3oOZwwgAkmPl1r/i+agIxCVMrx4XQvkeXk9zU3Cem8xsvmsAcq62iaA/hfJKEukA
N3I5NOYQp7ZqP0niwFBNt3koIerq/jahFHSdVEoF0GMdiV+p/Jykx4ntSU0IcEAq
+HRSd2JpMO9XcZyJc/ZdRTyrMPQj/6YbYvfSULbRpBceZ3tY3bGZd0/5lgJjL82c
YxqLNUiC7vS6lBZujMf+M5RE0IrhKkGewBs908aYQ1FY7HmYhqN4JzcTu6t4hDJ+
xKVdppUk6nhUTqPMv7RH8Gfg7px6XBkxGDTStuvHCQ/m35F6OxGpTRAPFa5iNFv1
+lqGz79wqx80ceDPB68CHqizXBoHpg==
=5brM
-----END PGP SIGNATURE-----

--=-WS/NIoxTuxo0S9rJ9C/P--

