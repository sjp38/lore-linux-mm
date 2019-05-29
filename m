Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 616E5C28CC1
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 16:40:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 052DA23DF2
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 16:40:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gy54YSWi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 052DA23DF2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5205E6B026C; Wed, 29 May 2019 12:40:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D1E96B026D; Wed, 29 May 2019 12:40:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BFC46B026E; Wed, 29 May 2019 12:40:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 153726B026C
	for <linux-mm@kvack.org>; Wed, 29 May 2019 12:40:08 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id z6so1181000vkd.12
        for <linux-mm@kvack.org>; Wed, 29 May 2019 09:40:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+Esfl3nvaEBw2uCWEGOwNd1KcpJR7qnstyVJ5GKtC10=;
        b=DSnyzNTOTttftrdPqdxQfTmVZiuNxFixZA2qx4BWS/T+7iLadqNq9A1hsiNbC1oCr+
         tzisjDFFg/rD/+ke7ZAz4gyEyO3zn8zBP8rq6FB0vZjwPprC/wgAqnKSw6+uYMuiGdmW
         DgMIxrMyuV009MONNOM7Eixhn57ybQwDHsGtuKK3STo0gwmN8yV9g4SocIorFO8cs5LI
         s3qTm20+rhpOt6bVlxBGTWvu/kVmcvv5oIbK93CmyfOLvIjNffnDceDqWk7uVDQh1oNu
         OaevADpcGMliM7GOrXCWsx1jhbil/caIKQuEu5trKU5NRLf4TlfmLQ/nOe4bru9wy9cd
         gEgw==
X-Gm-Message-State: APjAAAVPAuPL5CDjv0Fx9oDKrJMwr6he2k/jVahSwYmyx7pF6HmnI54U
	rp1hmJ3wEj+pcjNn6Sha3KEB7XezKTS9M233hYvl7S0apCqx8dIziATdUREMRyiziLqSnX6rNXZ
	X3sjVO8Q2dwyb5/eLY01zbKvWaAjUbpo68yaz2bMgxPgeUIWYAQxb0D/iMAd1C4zZEg==
X-Received: by 2002:a67:ca1b:: with SMTP id z27mr50388186vsk.189.1559148007707;
        Wed, 29 May 2019 09:40:07 -0700 (PDT)
X-Received: by 2002:a67:ca1b:: with SMTP id z27mr50388138vsk.189.1559148006711;
        Wed, 29 May 2019 09:40:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559148006; cv=none;
        d=google.com; s=arc-20160816;
        b=h+HFqrJI/bizLeOZoUH9N8EMMB1dO74wPAURhsLc8/UaucMwwCWDid8DoN8c8L4sso
         UPGNKOWII3kS89mV7lpc0mpXBWFiSIgvd7u3L3TKga+bG//hriFbRdtWf3CDyoyStGU0
         c0K+8zjOpAQJ1n12tKigQ7iTF4CfSeqJus8RFxmJLK0RfazfoCteh1xDiV1wIebQNPxR
         05n0vMsy9daEGL2nyuAbebwvBXDWdpgwSVRGg+4knYVDAPrDHGklPrfpw8pg0AL+NMX6
         ScGl/GBqe2o6B7/F6Sjtn2ieHBvomHn+/RfcG4Y6J015+10COZbQagirvwtMs6XI3NOW
         0FEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+Esfl3nvaEBw2uCWEGOwNd1KcpJR7qnstyVJ5GKtC10=;
        b=S+mtoOi+py/JZB4jPk1MIHoHKrCY1wjZCCOeFnnmxR+kgHMQrQA3J/Mt4RUqt/gSQ0
         lIx5ZG5lnHEd0JxCHzbTqMQXs31PNcu8DkZNXEd6YkClW0T8noeYpDwzDjLpfKzGbyjw
         yoFDT5nCfSQGHRWPCBwLAO8JjcJPc2d6OgRoiOrYtRhM4QpuaK9YM5ZfBxt9myLepHrl
         ZXg5R9YlhplttUmjbOfJWwLjHHyO2+q3bFkjNOH9y6XTb280ayn+uvC+0WDp5z83A1JW
         xUoX/VYUB6ZH4zwi4vWwWEd6xpi3M9ZKqorTCrZfRTFalw4xduU7RNXAKnSyjPHevce+
         F87A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gy54YSWi;
       spf=pass (google.com: domain of dianzhangchen0@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dianzhangchen0@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g7sor87820vsk.57.2019.05.29.09.40.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 May 2019 09:40:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of dianzhangchen0@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=gy54YSWi;
       spf=pass (google.com: domain of dianzhangchen0@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dianzhangchen0@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+Esfl3nvaEBw2uCWEGOwNd1KcpJR7qnstyVJ5GKtC10=;
        b=gy54YSWi28xfcPumIcxdQBpxiv38UYPyQki2rU5FibosdeZ6MlUtt9mGYX3pMzpi1J
         eVhOA5uX5C/8oMK59ewu0GTbMw/NJWIUQ8b/ZIBDbt98ekfp++OMeCkgUOCvHQqDoN8q
         DaT+H9TyYWJTCERqolLABJA2fLCqFKB1pboH6qY+GtugTcyXA1u2hJOOP4KVS5o8T1W0
         Nc3mxPD+goAx+22GUHKIz3rE9eBxPxsWhYqcyXvXu+t7PAS8w0XKOkNJlFUXgc+fItQU
         niid+sGwkxSgn5eDnRpH3eTcty2oJDRMsOtoLpYvHkC93a4vKqdqfiIJhAnbRHUedyz6
         NvjA==
X-Google-Smtp-Source: APXvYqwhVWfGociEat3pJKeWFTfSJFNJ89kc9w5M4Opt5Pu3UHJ1E0/+S9NVwIgBcTxJaDoqMh03meYLgWch4Id81Lc=
X-Received: by 2002:a67:ea58:: with SMTP id r24mr5616881vso.60.1559148004894;
 Wed, 29 May 2019 09:40:04 -0700 (PDT)
MIME-Version: 1.0
References: <1559133448-31779-1-git-send-email-dianzhangchen0@gmail.com> <20190529162532.GG18589@dhcp22.suse.cz>
In-Reply-To: <20190529162532.GG18589@dhcp22.suse.cz>
From: Dianzhang Chen <dianzhangchen0@gmail.com>
Date: Thu, 30 May 2019 00:39:53 +0800
Message-ID: <CAFbcbMDJB0uNjTa9xwT9npmTdqMJ1Hez3CyeOCjjrLF2W0Wprw@mail.gmail.com>
Subject: Re: [PATCH] mm/slab_common.c: fix possible spectre-v1 in kmalloc_slab()
To: Michal Hocko <mhocko@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, 
	iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It's come from `192+1`.


The more code fragment is:


if (size <= 192) {

    if (!size)

        return ZERO_SIZE_PTR;

    size = array_index_nospec(size, 193);

    index = size_index[size_index_elem(size)];

}


Sine array_index_nospec(index, size) can clamp the index within the
range of [0, size), so in order to make the `size<=192`, need to clamp
the index in the range of [0, 192+1) .

On Thu, May 30, 2019 at 12:25 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 29-05-19 20:37:28, Dianzhang Chen wrote:
> [...]
> > @@ -1056,6 +1057,7 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
> >               if (!size)
> >                       return ZERO_SIZE_PTR;
> >
> > +             size = array_index_nospec(size, 193);
> >               index = size_index[size_index_elem(size)];
>
> What is this 193 magic number?
> --
> Michal Hocko
> SUSE Labs

