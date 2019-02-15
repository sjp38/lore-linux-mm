Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEC3AC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:13:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE907218FF
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 18:13:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="IggnrRfp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE907218FF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B16B8E0002; Fri, 15 Feb 2019 13:13:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 460D48E0001; Fri, 15 Feb 2019 13:13:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37AB78E0002; Fri, 15 Feb 2019 13:13:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1119E8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 13:13:24 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id g24so6699707otq.22
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 10:13:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=NlOI0pvsjeeM6D/M81pgwByQGn1dt3+VjXarhgAxDXY=;
        b=bVNPEhgNdjA8YPY5zLzpQuuf5bCMJeJB6wtHGzbNjzqaKop9SNzeKk8+vlQpqUB0YQ
         98AFfhYke6BNUwVs+ao1jAQEW6EjgRIcbCB2PFn2cHYO8bqgrnxoTqylNYPtZwPaFZee
         dD1q/BgmhvDOqdhVpUsrcI5xuiCTPHxS0RwuL6QVqJrroOuNO+aJUz0PpNAfyvXDGnNW
         hzZuotP5fjdbN/iOBuvI1L4VsNMSO5/lqt9T+IuIf/+Ij2SKiMYWpScFGZMAbpxAX2ja
         v5xFqVunp8R4r4u1B9XIad21NU/GwzxmpH9npYXKOjjF5+b4lqnkeYFs8Pahm4CLHPhG
         DkHg==
X-Gm-Message-State: AHQUAuYj64OaU0r90QUkapdhR7aSTZJQTD+zGkJVVfGCgyzdrx6GxCa1
	vuWCjYn71BWOFdcFB3bdHmnMyHx09ivbsbDgar2Dv0UmjJQ/sK5nUCIGLSGAB0ZRMyEUCGi+Xvm
	9Cc2WZDROEKO4/RmovFIDfBwOTU1HmjKrhhQo6FCvIFt95e6+hEralrUjFVq546uATPhLRGHbFx
	RwbgEFZmr/BQOjt8GFjoqbd+2dlgLidoB+370q8/+7vivA7B9JUEPkQtHxWe+fK/cro29J1FCE7
	exMo3uhawLSh77aggqVDM15j8wRwzlF1EdL7tDkgeKgUwuP0rRziPYV7k1HIsfan1bR2z729wNv
	lTswcPZc1p+I27vQucSxiSoWSB+VRtPvinD7CecY1SgRDa3f7TvZ24kpL8uRxSQvE8+GWQOkR0m
	v
X-Received: by 2002:aca:4d53:: with SMTP id a80mr6780421oib.154.1550254403771;
        Fri, 15 Feb 2019 10:13:23 -0800 (PST)
X-Received: by 2002:aca:4d53:: with SMTP id a80mr6780389oib.154.1550254403114;
        Fri, 15 Feb 2019 10:13:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550254403; cv=none;
        d=google.com; s=arc-20160816;
        b=P/0BqMrX8BtWYtjQdK11Fzma3LnOL5sdktjb8B6qNzJMnVl6ug4Qxc8WgRearwRLz0
         TSxDi+WxjgMvYEaJJlbcHcziVH/ybfHKwVX9218CFhpd1HqraRKMMLs6Ys+dQoNgbUsN
         StTWRW1jhzSXIAeAtQqqHvbQalbVoGzg8b0v6RYhdseWIflRRp9rpagL/dJQJMtkTCGP
         LkLy02VQIGlo+VOy9Kc6IORJuqDgsrcE2KMaEW8vozd0+JUerl83uezT7YQ2yUJsHAgY
         H6yd+nsHn2Tl/lI/VvOn0eav/Rzk+4OrvDsjAS5JtZnorlFlp3+IEUUvTicMW+ECmWpY
         Be6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NlOI0pvsjeeM6D/M81pgwByQGn1dt3+VjXarhgAxDXY=;
        b=jmS/Jpi/EaRcWyxn+xie8pcAI2oFw8Vk5ZFLxppHu998tnSoUSC8eWdoDySEV4HivP
         v+X02FdTVHBoLKNeGn65yepmi47PSDGgUn0ALkADoj6s8Mz5Kg1RJnAI6nmdDXGB19Kt
         ZfbjpS1FMWHCqBdpweiwytVKA/zgAiwwSAw3aNgf3aZECQ5l0kFBiGwBy8wzAXlouOUG
         +SbAF1kSGyAD2EtQZVDWjbdfmjUAH+nSF6Q2qMjcmjpDTiakKN8GKgeAJNmsmI5JWxUi
         zUN1inh/Y7gCXjQl3yqAfqARyPB75VD/f/HoIQhDBN6bE9f+5HuCuv36JCqaWuR+/1w+
         NjeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=IggnrRfp;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x200sor2874470oix.110.2019.02.15.10.13.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 10:13:22 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=IggnrRfp;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NlOI0pvsjeeM6D/M81pgwByQGn1dt3+VjXarhgAxDXY=;
        b=IggnrRfpEwtDUtteCXO3PnAgjR/lFVXt/zw9lk3UioeTUXikCmI9KduLhLCsUFxZW2
         wVnVEOgeOPjh45winMv9UyXfkYjp6mecQ9G7fFkyN33qgfqf1b2bSkXU28iK7GGN6OdS
         gGndFqgBSswIblJwvz/sfx4QIYFG99oaUR1kcV/F9L0PIIHyYQznt/P3v29m40LGndZV
         9HxEnnXloK2YOH7PWNZgPRl4w3OtgSK3LGFl+tPRwUPHOTRgteGw+G+NUjN73kjuqn8o
         ihZnVoiTRgv9xm65zG9wQuvoPUUeGVzhfMbiT7HQiBtTUcqmh9Ua4ShxHla5VGSzzvBA
         N1gw==
X-Google-Smtp-Source: AHgI3Ib6HeNEukHX6Wuxa000hsIt2rfWwm8dF85TfVfexoPuO9AJzbWi8uTIgn6Jpf5UtgwSDhiyrRuZJOJTxIrVjho=
X-Received: by 2002:a05:6808:344:: with SMTP id j4mr6779822oie.149.1550254402390;
 Fri, 15 Feb 2019 10:13:22 -0800 (PST)
MIME-Version: 1.0
References: <201902150227.x1F2RBhh041762@www262.sakura.ne.jp>
 <20190215130147.GZ4525@dhcp22.suse.cz> <1189d67e-3672-5364-af89-501cad94a6ac@i-love.sakura.ne.jp>
 <e7197148-4612-3d6a-f367-1c647193c509@suse.cz>
In-Reply-To: <e7197148-4612-3d6a-f367-1c647193c509@suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 15 Feb 2019 10:13:11 -0800
Message-ID: <CAPcyv4ihKWkONbnaParFKLke7sHBWJzXzN2auUKPQvhcEnJjdg@mail.gmail.com>
Subject: Re: [linux-next-20190214] Free pages statistics is broken.
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Michal Hocko <mhocko@kernel.org>, 
	Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 15, 2019 at 9:44 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>
> On 2/15/19 3:27 PM, Tetsuo Handa wrote:
> > On 2019/02/15 22:01, Michal Hocko wrote:
> >> On Fri 15-02-19 11:27:10, Tetsuo Handa wrote:
> >>> I noticed that amount of free memory reported by DMA: / DMA32: / Normal: fields are
> >>> increasing over time. Since 5.0-rc6 is working correctly, some change in linux-next
> >>> is causing this problem.
> >>
> >> Just a shot into the dark. Could you try to disable the page allocator
> >> randomization (page_alloc.shuffle kernel command line parameter)? Not
> >> that I see any bug there but it is a recent change in the page allocator
> >> I am aware of and it might have some anticipated side effects.
> >>
> >
> > I tried CONFIG_SHUFFLE_PAGE_ALLOCATOR=n but problem still exists.
>
> I think it's the preparation patch [1], even with randomization off:
>
> @@ -1910,7 +1900,7 @@ static inline void expand(struct zone *zone, struct page *page,
>                 if (set_page_guard(zone, &page[size], high, migratetype))
>                         continue;
>
> -               list_add(&page[size].lru, &area->free_list[migratetype]);
> +               add_to_free_area(&page[size], area, migratetype);
>                 area->nr_free++;
>                 set_page_order(&page[size], high);
>         }
>
> This should have removed the 'area->nr_free++;' line, as add_to_free_area()
> includes the increment.

Yes, good find! I'll send an incremental fixup patch in a moment
unless someone beats me to it.

