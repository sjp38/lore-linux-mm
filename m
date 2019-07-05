Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C57EC5B57D
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 05:29:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0F9E218A4
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 05:29:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="gpwsyMS6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0F9E218A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 520056B0003; Fri,  5 Jul 2019 01:29:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D0738E0003; Fri,  5 Jul 2019 01:29:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BF338E0001; Fri,  5 Jul 2019 01:29:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 04DFA6B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 01:29:09 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a21so4915476pgh.11
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 22:29:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=qNZyoCrDt9Pu/FvinUTVMXpvuBiR35dmsH196/cAnJA=;
        b=VgWT+TyfkxNyA+0ZdYgsGjuV6Mdpt6sx0y691YoAMQrPNTyr8+/qGQs2lgWXGV0uph
         uxFqYLi3MHestUGWQK4D1L4hk1IuflNVvVbSIioDY/pbdx6FzXsvpnubZ2Rzk63LPQHL
         9RrOcQIh4Yghuf3byKcj7j7SWmIi4TY0w1dg30vwC4SsRggkCpTSSHcN4kp4o29xPwDv
         UqI4fW1/jbiFqOZnDbMprp818MJn9zoVgRWgQ1eCXUTnHq1lwfB3R7O6iNWxoz5un5aH
         vu3SAfDsqcWVaiOPzVqRtbhsU84S6OgNRvXYWov2X1mpboeyP7+i80Z9aaFtpVeCSihL
         5S+w==
X-Gm-Message-State: APjAAAViLTzWS8yXiVBRLLGDcWaGOrgWZwuh0QyXzgc+8b9BEYqGoDRC
	ep3fe+ZqHuTIPoSG7fzTy1zCMI0UvYKVkdQIkYLU9bAapjMmJPstwwBNxoJ12cpDRm+iCiteSpw
	SJuSE8Ji9sUdynCBoghxq30kL9kxWE/vCxr1foOIxtsLW1E1EkLqmixckMk7sKcdDig==
X-Received: by 2002:a17:90a:ba94:: with SMTP id t20mr2479338pjr.8.1562304548706;
        Thu, 04 Jul 2019 22:29:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwil/LVCDDOEkv9nuyBnq99PMsr+zn4JN2t8f0Uz/gOcpxlWsPj8FLlKWluzukZ/GBPFlgo
X-Received: by 2002:a17:90a:ba94:: with SMTP id t20mr2479273pjr.8.1562304548133;
        Thu, 04 Jul 2019 22:29:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562304548; cv=none;
        d=google.com; s=arc-20160816;
        b=tzWYvuT63LpCztzPY+bmhLHtGg//wmoU/kTvBOsgAhqKD33O727l4c70JFYKeAD0y1
         e7QZEmiven0UDRC7UqjEn5lwAoh3pDv2f6b7bYhS8lOJAZIi4YT80acPAmDV3KwbVm+Y
         edsV4dW5yR9g//cZljLuVGiuInZ92z5Oo7LA9XGmBtqYs3bu55QfleCZXM0G2rY9zlHo
         SZqiAQJDlUcxHalcexc9/S/RUFn8xN3jzoqFOKEW7OTsurSuY0vPYrY5hHpeMWljHrht
         LAUMnfVYyT0wwpgoJ1KZoZJ4Iyyib2+w0dcPkWaU5J21AJ/1TMiwVMEpqlXZIr2H+pSl
         MoJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=qNZyoCrDt9Pu/FvinUTVMXpvuBiR35dmsH196/cAnJA=;
        b=VMiPJrNqfZWhejS7S4Wnx4oe0aI7+V8e3/MKTN0XivXqpFLE6JGwGx4RuBo8byFZ3K
         fRxzAsb+qPswngWdx5sWYUlGWbj1GqQIaIXhFnprtBc7u24frcLAqiKqEAN1CPKArNej
         xWPion4uqHKoE6TCLjzHbaLQ0IV+FeSakyjw3Czzwn4M4b9wjRTTLIZDh+OG4WC1o2hZ
         Ees1BuZCldSb21QvKpm/mv0OvROaLdRKKc9Mb0yk/p8MpmU484/Smd+CIi2xC0wYUVu9
         ydVWlbnDoz+OEwd8CkQwMaUpZuH9yeAgcAEQ2hDgRSSQ++K+pRXPnzx6WGgfWPvnZKGI
         RcvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=gpwsyMS6;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 63si7587277pfg.192.2019.07.04.22.29.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 22:29:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=gpwsyMS6;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 111B621850;
	Fri,  5 Jul 2019 05:29:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562304547;
	bh=ku9aEp+wapV1jAtHr82zZH6REpuJWRVS+GCf+tHXR7Y=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=gpwsyMS6DRC1CwjjTw4nWYbfs5wE2bJ85FBSXW84XxfeYBs6quUOEtr8MLEJ6QcMZ
	 03jv6nY0lDeUSDRQOggVvU24ZcWC8z5wMyc53vkGgU4qbFnuhBeU8cBq+krJtoDFTV
	 5BAl2jqKEoiqIRjP7Qf7cwvYh0pBZRG2A96dQtGc=
Date: Thu, 4 Jul 2019 22:29:06 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Joe Perches <joe@perches.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, Masahiro Yamada
 <yamada.masahiro@socionext.com>, Randy Dunlap <rdunlap@infradead.org>, Mark
 Brown <broonie@kernel.org>, linux-fsdevel@vger.kernel.org, Linux Kernel
 Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux-Next
 Mailing List <linux-next@vger.kernel.org>, mhocko@suse.cz,
 mm-commits@vger.kernel.org, Michal Wajdeczko <michal.wajdeczko@intel.com>,
 Daniel Vetter <daniel.vetter@ffwll.ch>, Jani Nikula
 <jani.nikula@linux.intel.com>, Joonas Lahtinen
 <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>,
 Intel Graphics <intel-gfx@lists.freedesktop.org>, DRI
 <dri-devel@lists.freedesktop.org>, Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: mmotm 2019-07-04-15-01 uploaded (gpu/drm/i915/oa/)
Message-Id: <20190704222906.f817d02cb248561edd84a669@linux-foundation.org>
In-Reply-To: <5f4680cce78573ecfbbdc0dfca489710581b966f.camel@perches.com>
References: <20190704220152.1bF4q6uyw%akpm@linux-foundation.org>
	<80bf2204-558a-6d3f-c493-bf17b891fc8a@infradead.org>
	<CAK7LNAQc1xYoet1o8HJVGKuonUV40MZGpK7eHLyUmqet50djLw@mail.gmail.com>
	<20190705131435.58c2be19@canb.auug.org.au>
	<20190704220931.f1bd2462907901f9e7aca686@linux-foundation.org>
	<5f4680cce78573ecfbbdc0dfca489710581b966f.camel@perches.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 04 Jul 2019 22:22:41 -0700 Joe Perches <joe@perches.com> wrote:

> > So when comparing a zero-length file with a non-existent file, diff
> > produces no output.
> 
> Why use the -N option ?
> 
> $ diff --help
> [...]
>   -N, --new-file                  treat absent files as empty
> 
> otherwise
> 
> $ cd $(mktemp -d -p .)
> $ touch x
> $ diff -u x y
> diff: y: No such file or directory

Without -N diff fails and exits with an error.  -N does what's desired
as long as the non-missing file isn't empty.


