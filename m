Return-Path: <SRS0=CHX8=XL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E64B4C4CECD
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 15:14:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9C4C206C2
	for <linux-mm@archiver.kernel.org>; Mon, 16 Sep 2019 15:14:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DvhydDp4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9C4C206C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BD816B0005; Mon, 16 Sep 2019 11:14:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2477D6B0006; Mon, 16 Sep 2019 11:14:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10E7A6B026B; Mon, 16 Sep 2019 11:14:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0030.hostedemail.com [216.40.44.30])
	by kanga.kvack.org (Postfix) with ESMTP id DB7506B0005
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 11:14:58 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 8E3FE824CA39
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 15:14:58 +0000 (UTC)
X-FDA: 75941131476.21.edge79_82b5b843e7614
X-HE-Tag: edge79_82b5b843e7614
X-Filterd-Recvd-Size: 4689
Received: from mail-ot1-f65.google.com (mail-ot1-f65.google.com [209.85.210.65])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon, 16 Sep 2019 15:14:58 +0000 (UTC)
Received: by mail-ot1-f65.google.com with SMTP id z6so193102otb.2
        for <linux-mm@kvack.org>; Mon, 16 Sep 2019 08:14:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=z0/EWWbquuGe/alMAK52FBBiIV0cXbrcVPiI5d8H2kA=;
        b=DvhydDp4Gjrd2G6qJDzXD3XOWPCqDoxP5i3/PlSHgjgZkqOp4Cq/KgGwBARdDjCLWx
         1vNisHSk+S/wNrHX1fPZdjE3ZeWyfw7tmjf4Y/pCQ+/OWmD9fRYdbjkXRaS+l4H2vG7W
         PTFVopNTicepzUYPPTIAEaorvSxghBiJfbawugVL+uEQSFgLmJzVm/Veo/Ge0t9Z9CbR
         CypWoStT2qoLYKHBQnhSdwjJwHnlftPy4aX1MSfhOZ6ns8MFwThDcaWvgqKxb/tQ7110
         V+AAEUL7n7VeLaaj79dxtLu9rit/ZO7BopCSLX6hcj/sKNcLeqYSKdrDjAzvqs1FXZmD
         Ao5w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=z0/EWWbquuGe/alMAK52FBBiIV0cXbrcVPiI5d8H2kA=;
        b=EA0Mr/G2ouWkHTAaSxfNFVG6AIbPVAP1pYkNLOs2g7gbAbJMcHjli5zjFiPh5UCeM6
         UkNyX6nEGOyE7U5NRQwR/idiHF8DwcZuk4NbzeXQ7fqQtmErWcADy4Scb7siOmk0/R7b
         YTl4j1ZZeMwMKLI58q1sk2oPGhQTbv/zbUQ3V8Hx2AWE6JMr5hMvKi/0ExFqrsGjFpDa
         jO8/FCc4oxCoPNyDUrq80Vpn92k80ZCIGQ+LS0SSlxV+YbkMJcfJIcd2SPOXQcEDURKP
         1MwPNG1N0pSOkgCENAUIHpTd1vP66Ugs5KfsTRzXTDO11sdhCIXf7xo8GbmgGTtQwuCr
         Xfvg==
X-Gm-Message-State: APjAAAW7lPbrMZvk8yLy8ikDCmXUm9URCHFluEalXbH3irmPlvHUtTkh
	te91rzNM0j3WG0P+ji819LoNLiLokvvvF8xFp5o=
X-Google-Smtp-Source: APXvYqwr0f3KzajSDi9qsg3JLAmYbbkUZ9nL5Oyt5K3lTAXjPs/yGAzctYEPjVsS/U7zeSmEUm2j+YejcAmEqIAh7/c=
X-Received: by 2002:a9d:1ec:: with SMTP id e99mr44878419ote.173.1568646897425;
 Mon, 16 Sep 2019 08:14:57 -0700 (PDT)
MIME-Version: 1.0
References: <20190915170809.10702-6-lpf.vector@gmail.com> <201909160919.Qa2fDQjj%lkp@intel.com>
In-Reply-To: <201909160919.Qa2fDQjj%lkp@intel.com>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Mon, 16 Sep 2019 23:14:46 +0800
Message-ID: <CAD7_sbG3UcizVKMemaxOnpxDQKARSEJo340c8zPHkX4R+KdW9Q@mail.gmail.com>
Subject: Re: [RESEND v4 5/7] mm, slab_common: Make kmalloc_caches[] start at
 size KMALLOC_MIN_SIZE
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, 
	Vlastimil Babka <vbabka@suse.cz>, Christopher Lameter <cl@linux.com>, penberg@kernel.org, 
	David Rientjes <rientjes@google.com>, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, Roman Gushchin <guro@fb.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 16, 2019 at 9:46 AM kbuild test robot <lkp@intel.com> wrote:
>
> Hi Pengfei,
>
> Thank you for the patch! Yet something to improve:
>
> [auto build test ERROR on linus/master]
> [cannot apply to v5.3 next-20190904]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Pengfei-Li/mm-slab-Make-kmalloc_info-contain-all-types-of-names/20190916-065820
> config: parisc-allmodconfig (attached as .config)
> compiler: hppa-linux-gcc (GCC) 7.4.0
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         GCC_VERSION=7.4.0 make.cross ARCH=parisc
>
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
>
> All errors (new ones prefixed by >>):
>
> >> mm/slab_common.c:1144:34: error: 'KMALLOC_INFO_START_IDX' undeclared here (not in a function); did you mean 'VMALLOC_START'?
>     kmalloc_info = &all_kmalloc_info[KMALLOC_INFO_START_IDX];
>                                      ^~~~~~~~~~~~~~~~~~~~~~
>                                      VMALLOC_START
>
> vim +1144 mm/slab_common.c
>
>   1142
>   1143  const struct kmalloc_info_struct * const __initconst
> > 1144  kmalloc_info = &all_kmalloc_info[KMALLOC_INFO_START_IDX];
>   1145
>

Thanks.

This error is caused by I was mistakenly placed KMALLOC_INFO_SHIFT_LOW
and KMALLOC_INFO_START_IDX in the wrong place. (ARCH=sh is the same)

I will fix it in v5.

> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

