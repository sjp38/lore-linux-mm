Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 294E9C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 10:04:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E251720857
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 10:04:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E251720857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7FF4B6B0007; Tue, 19 Mar 2019 06:04:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B0286B0008; Tue, 19 Mar 2019 06:04:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69F706B000A; Tue, 19 Mar 2019 06:04:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 24C026B0007
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 06:04:13 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o12so7382407edv.21
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 03:04:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2QGHJ6mltjWVFH3HvJQTWtgL03IZI8UWtydD4se9gdk=;
        b=mAxKyxF+T1N8IjEd07S8+BOitaqa4Cip8NoGBM7Pn5sBgl/JUBiYURT3pk8TxVXYY2
         6Ub0QNdpdmPjpMcd++Zd+e/UGOmP2dPi6vo4xvhs4ALnhsA4GMaP9h/FCDvo+KzhU9GW
         v/xZ+4RptX2orbwjX+H7QzakG16YM3nxPCvrVciO9HTvTINwKrrgzY6UU+oypVHd033j
         PDlur9drKB/+ak7FBnnNC0YGkw12e1mEH7MdEtko2b7NuUT3VHZUsvkSvAmjfms04OtC
         zS4CU2GENfjh1Gy41V7v2YH+6K0npsveRcbUZ4CeKnWR/Wqahl16VmiJeGD+axTu3Q/r
         clVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAXxfb0yiMyJQkSx8xu29CpleJTcSbnjApbB7ttCKPiXth9K5D6/
	OfSR4j29Gm1HDDCrBKmxeyKLSFVtNhyCYAI5ivZ3+KQEBPvKJVVhQPGJHsh73+oDQWj24o0hP1H
	3FS3q6IB5GviUoG/wMyk/zfW39K3msubM9wgY/bKxbqG7O3K9UplwwalVxsmHEd8rJA==
X-Received: by 2002:a17:906:63d1:: with SMTP id u17mr9330318ejk.6.1552989852686;
        Tue, 19 Mar 2019 03:04:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZCPYlP3tDJR7Lhh5ej9EIaIEND+0l28o3xjxfbXozzcQ3isTuExv14KnxrXHBSf2uz08T
X-Received: by 2002:a17:906:63d1:: with SMTP id u17mr9330279ejk.6.1552989851825;
        Tue, 19 Mar 2019 03:04:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552989851; cv=none;
        d=google.com; s=arc-20160816;
        b=DyFXv4plf8BCuhCpoulqUVtCq+s1xSXcRi//1tlqs0ILnMge6dFpCo7Y/CMhjICZz6
         k3QeReO5Jrqx/DoRHXLvCkfGSSTtZHx7LFG8ThJU/M1Uhmxb5MKoFF0ZIpsi/vpc/hwh
         o6M5W05W0B1R9IRGmy43DIzhZ759JPFFOFFiEUqlDddIyN70a4MFmoV3aKeyg57jaFTp
         EaQu1cwjVR2qweTNwME09lzPpfPxHHjNCiGSxonUtuQLtBkooJsdlw4iHqecIM7XSy4I
         sxqheHzrjAVZl8AI48yRaK9MEWk1ZmNaoJyss2o21+/s7w3fyEUDmhdxJe53dOUX0uUs
         CS9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2QGHJ6mltjWVFH3HvJQTWtgL03IZI8UWtydD4se9gdk=;
        b=xxODHyu3y9bSFGVtdZiVHH/YXd60c+UZelTYlQdhVlGloenkEVXu4MZa8m3lZefMu4
         YyKWcgctK4mN6DrBH8NN8qivv9OYvQxMgux4APUl0WbRlPH25NzrvNtvtY1jpMW9Yu+F
         3XLnbxQJq8dmRXB2DUBxAMchR8LVKfQqrqGS/TF01LWntttUL1Tmr2mhUwbjL+kJvRLr
         YSnQLUjNfSmNbFf61aHwrVxYNbqYwPpBao9HySQYtEHkD+nwli7keguJRM7eyW9oeJl8
         d8zYaxl5LXi0H8lSD/V7aX5rFVS84m7QNBEgFf3y0/iDXBDgsyi9OZC/CZTYwJgAHv7G
         4xyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id 30si1894106edq.10.2019.03.19.03.04.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 03:04:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) client-ip=81.17.249.194;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.194 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id 57134B88E6
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 10:04:11 +0000 (GMT)
Received: (qmail 4595 invoked from network); 19 Mar 2019 10:04:11 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[213.151.95.130])
  by 81.17.254.9 with ESMTPSA (DHE-RSA-AES256-SHA encrypted, authenticated); 19 Mar 2019 10:04:11 -0000
Date: Tue, 19 Mar 2019 10:04:10 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] list.h: fix list_is_first() kernel-doc
Message-ID: <20190319100410.gtscz4no3dfsbjng@techsingularity.net>
References:<ddce8b80-9a8a-d52d-3546-87b2211c089a@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To:<ddce8b80-9a8a-d52d-3546-87b2211c089a@infradead.org>
User-Agent: NeoMutt/20170912 (1.9.0)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 17, 2019 at 05:16:26PM -0700, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix typo of kernel-doc parameter notation (there should be
> no space between '@' and the parameter name).
> 
> Also fixes bogus kernel-doc notation output formatting.
> 
> Fixes: 70b44595eafe9 ("mm, compaction: use free lists to quickly locate a migration source")
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>

Thanks

Acked-by: Mel Gorman <mgorman@techsingularity.net>

