Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E007C46498
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 03:06:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24E9520828
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 03:06:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nifty.com header.i=@nifty.com header.b="hc5L71Dy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24E9520828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=socionext.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B55A86B0006; Thu,  4 Jul 2019 23:06:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B05F28E0003; Thu,  4 Jul 2019 23:06:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F3778E0001; Thu,  4 Jul 2019 23:06:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3CE6B0006
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 23:06:48 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id z1so4737947pfb.7
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 20:06:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=PUF8lDa4vdReIoKmN9yFODRcREJp8yLKeKn0eH+L6bE=;
        b=A485F2MrBEA1kb8hDDvaD5/10wZMUW3dQzH6OUg+LFWVlxVsb2OQUr3FO1R2noyvff
         KR+px4KhoMbYkJYFMyHYHT+KtcaZeMyaYL+4RZMDt9uUwjy2D0QlImRzPfsq9TgWQFoR
         2i+ZKtJliCURw2+iOOJnOQ90dMA3Uoy7Xy3OWEfQmHwdJjZUcQfp3k4qLQYv1QygoHFJ
         fZaAaDOpTJsIKSeSAMe9wKwVtqCUpARuctIPS1txQb1O25/shnfiEC70oisXPHFCkO/W
         fSE7iM3OPkx5uWSehq3pxVaT0z98YAsxyUX5FHfdSsZJ6ZUqNIFHhcTPP2LaBoldh+qT
         DPyw==
X-Gm-Message-State: APjAAAUyRyA1q/WjnZqqpDiZBUiaBLPu2o9CyibxgkVX8ahaAcS4pQ6v
	JgHxCA07l/DNQMlYCNuoouMbAn51UyLKtzZLSVluEZ9ZyrWzN5CIX8kNlI5IMrWEdtGHCWYDN+z
	Va+lEmW+QmNdcd7Nos8E+h5v+5Mh9Op7ijORBkspFerX0ocgl12BW4RRPmEUEdRw=
X-Received: by 2002:a17:902:8203:: with SMTP id x3mr1870546pln.304.1562296007950;
        Thu, 04 Jul 2019 20:06:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcpqWMMUqXL3nek0At0EVzH+HcVhPN7Ae2dxEnIgU9qU6ZjOZeO2qoBfWtEIGdM9wpffJx
X-Received: by 2002:a17:902:8203:: with SMTP id x3mr1870480pln.304.1562296007329;
        Thu, 04 Jul 2019 20:06:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562296007; cv=none;
        d=google.com; s=arc-20160816;
        b=Dvd6eMIsvk2Da7AWJ9xN5A/Fy8yzvepLgS2h8QjlbIoIR59uonwUe3zFzu2u2xhiwW
         1XPd0LYnowZ+T885a1Jm0CABQ8f3tcSSJ2KE0+5IbZWCkQ8gMmxLc9mUA1C1AWZb9o/w
         qy0CLJWAq6T48X9sajXEu0zT9ZhTbkLYZ08ZAQWqEQOpl1MMdUCzeA0hmqjVmJ0bOpbF
         0xmezzzqyWKQ+bVJ0C9PR9op8QbzGBJKmwxCWRG9bKcbF865wshTfy6fsK1NLNk7kfi3
         6qezTv5dvh1wmbYMt6UvHo/5XM6jhGxUWFB3ESENp3GKEPTqz8gsrgeF9/bNZxVg4ZP8
         UQ2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature:dkim-filter;
        bh=PUF8lDa4vdReIoKmN9yFODRcREJp8yLKeKn0eH+L6bE=;
        b=gAOnHgKW2acAzxxOe6SBalUtuhQKFJ6MLhjtAPobzL4/RVWZ3pPj92rZCoUMX08B8l
         wTc++0nQEsMVDjdOIbpgQ1gmntVlEXoKT4ZdHCXryILQ4Zi1b1EhuPUX8kmlofzqcCTp
         +b43K8DrmJVv/q2wJcHivTmA+zxBqTU+7ooZMGD9iRjXSGm5Zrk/gXs1Zclf6M/FqRb4
         CS5DrKconjSHi5EDUon9jKXX5EPKqKBZoMt9nUMC6Oct8HYHfbs8J7rpc02m65/EfQ2b
         nTNAmDF+rN+cjIRLYxD49voscSS95moBM71ItDX24fY+rhIMnVP//+QWCf13Ir2XDtk4
         LTjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nifty.com header.s=dec2015msa header.b=hc5L71Dy;
       spf=softfail (google.com: domain of transitioning yamada.masahiro@socionext.com does not designate 210.131.2.91 as permitted sender) smtp.mailfrom=yamada.masahiro@socionext.com
Received: from conssluserg-06.nifty.com (conssluserg-06.nifty.com. [210.131.2.91])
        by mx.google.com with ESMTPS id b12si7240415pfb.122.2019.07.04.20.06.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 20:06:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning yamada.masahiro@socionext.com does not designate 210.131.2.91 as permitted sender) client-ip=210.131.2.91;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nifty.com header.s=dec2015msa header.b=hc5L71Dy;
       spf=softfail (google.com: domain of transitioning yamada.masahiro@socionext.com does not designate 210.131.2.91 as permitted sender) smtp.mailfrom=yamada.masahiro@socionext.com
Received: from mail-vk1-f181.google.com (mail-vk1-f181.google.com [209.85.221.181]) (authenticated)
	by conssluserg-06.nifty.com with ESMTP id x6536QvA018785
	for <linux-mm@kvack.org>; Fri, 5 Jul 2019 12:06:27 +0900
DKIM-Filter: OpenDKIM Filter v2.10.3 conssluserg-06.nifty.com x6536QvA018785
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nifty.com;
	s=dec2015msa; t=1562295987;
	bh=PUF8lDa4vdReIoKmN9yFODRcREJp8yLKeKn0eH+L6bE=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=hc5L71DyP571OH1ILbrgsHHQpZxhkuz18yBJhiWyhTAww3ze+ztOro/wGz1TDYFUE
	 /Si8hBWyn/V+Wg7PcYBWYxq1n2b2lpdpZvozLTunEj/uzkQ6RFOunckU0TuUzz9m2O
	 RXMPcf27hMNI6zqtIhJMXDYJTJ3SOPQKOXPt5xrHNYe/6sLud/g+w7+4NbpxrT/Grd
	 8MDTyD1iqfPBs9CuK/ynHGls1pUT/6NeGMZXtHG9zbpUfsfYbzST09seR6N/R3uVix
	 7kKWqrwbGRnDtZYlfOtqiGntTGk7sXKjNMyFI00Ibkod/cTVCg9158ANjrjUuw9/GO
	 cblKP9Jp4wGZg==
X-Nifty-SrcIP: [209.85.221.181]
Received: by mail-vk1-f181.google.com with SMTP id 130so933233vkn.9
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 20:06:26 -0700 (PDT)
X-Received: by 2002:a1f:728b:: with SMTP id n133mr313496vkc.84.1562295985842;
 Thu, 04 Jul 2019 20:06:25 -0700 (PDT)
MIME-Version: 1.0
References: <20190704220152.1bF4q6uyw%akpm@linux-foundation.org> <80bf2204-558a-6d3f-c493-bf17b891fc8a@infradead.org>
In-Reply-To: <80bf2204-558a-6d3f-c493-bf17b891fc8a@infradead.org>
From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Fri, 5 Jul 2019 12:05:49 +0900
X-Gmail-Original-Message-ID: <CAK7LNAQc1xYoet1o8HJVGKuonUV40MZGpK7eHLyUmqet50djLw@mail.gmail.com>
Message-ID: <CAK7LNAQc1xYoet1o8HJVGKuonUV40MZGpK7eHLyUmqet50djLw@mail.gmail.com>
Subject: Re: mmotm 2019-07-04-15-01 uploaded (gpu/drm/i915/oa/)
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Brown <broonie@kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-mm@kvack.org,
        Linux-Next Mailing List <linux-next@vger.kernel.org>, mhocko@suse.cz,
        mm-commits@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>,
        dri-devel <dri-devel@lists.freedesktop.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 5, 2019 at 10:09 AM Randy Dunlap <rdunlap@infradead.org> wrote:
>
> On 7/4/19 3:01 PM, akpm@linux-foundation.org wrote:
> > The mm-of-the-moment snapshot 2019-07-04-15-01 has been uploaded to
> >
> >    http://www.ozlabs.org/~akpm/mmotm/
> >
> > mmotm-readme.txt says
> >
> > README for mm-of-the-moment:
> >
> > http://www.ozlabs.org/~akpm/mmotm/
>
> I get a lot of these but don't see/know what causes them:
>
> ../scripts/Makefile.build:42: ../drivers/gpu/drm/i915/oa/Makefile: No such file or directory
> make[6]: *** No rule to make target '../drivers/gpu/drm/i915/oa/Makefile'.  Stop.
> ../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915/oa' failed
> make[5]: *** [drivers/gpu/drm/i915/oa] Error 2
> ../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915' failed
>

I checked next-20190704 tag.

I see the empty file
drivers/gpu/drm/i915/oa/Makefile

Did someone delete it?


-- 
Best Regards
Masahiro Yamada

