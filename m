Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 483C4C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 20:05:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1325A2171F
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 20:04:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="hUxoFsGk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1325A2171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FC2B8E0003; Wed, 31 Jul 2019 16:04:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B5668E0001; Wed, 31 Jul 2019 16:04:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79B568E0003; Wed, 31 Jul 2019 16:04:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3FCEA8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 16:04:59 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id n4so37642312plp.4
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 13:04:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=DvIle9Z7Le0W/koXErTIOG9PhIMMIXfJqWN4mPJ33BE=;
        b=nupVAns5UkI4lTS2ZvGdKWI8pKAIyGdxBa9pDVd/WGUh7BsZ90cWu4xhVIpkyuIYsr
         1eGcaJEzhgvln0Wu2Q9dpDN/d3ZWWxS6lgzIRzlou6S8We1L89LJJwwgk8hVbyv0Iv37
         mQnsUKIW5dvaUgsN0HhyeG0nAVS21pootXbMblae/i5X+b02Cs2r3x7wUTTlmmvby2f0
         wjZ0lugUnyfkqVDGA/wVSdjWIYvc/QG7CrxZxaRgkrQenQyXfxRHcL5pc3SgI+Ggq5fc
         qnLrErF6L4GoY2cWIP76sGl5sUZ0JPxJ3EZWY4jduGQfk6uULU0M+04bISVT5rjLqYP/
         MWyw==
X-Gm-Message-State: APjAAAXwtdN8i4LO/sYj0FMyekRrIkua9lHGXISzrVCDCdyHMMNVSsNs
	anbowYj81qrP6b+FCC/7+tzohBSGHHJs+Y8WwZyFoQh6U1YgWMo9IXguqxQmD2bQn+Yq5xwYUth
	/Nhd+OqCIDvK3j9HhrVoeitx3ZsFpCPNqLLokbpGLhruFuGhxjovR3M6N6cRBnm/PNQ==
X-Received: by 2002:a63:e148:: with SMTP id h8mr4270900pgk.275.1564603498722;
        Wed, 31 Jul 2019 13:04:58 -0700 (PDT)
X-Received: by 2002:a63:e148:: with SMTP id h8mr4270840pgk.275.1564603498064;
        Wed, 31 Jul 2019 13:04:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564603498; cv=none;
        d=google.com; s=arc-20160816;
        b=NRLkKMP8ETsntG0mlpUdotMps5qWlQQTIYEDkQuspTBtG0uxJ7fuTmL7R6fNglt/vC
         mnkd9p7RC3Gp7DowQUwiNLPSSxgbtdP6dpOeHXB6/HMurUbRD6iJqCUilAexGE+2QOKr
         NAnJGHY2M8z82muEB3lw6KzPYSOp20YOeqB26ZOUv7YC124IsjlzVPro8J6NqQIYPwNK
         zzHtJ49eQlVbFua7CdhP5InPdsTjeOXgH24T0mh3N92DiCVl2I6EOm9Jdm0j7es4CQuV
         sINOY1lxxxzn1pfDkEIe/G+JVJKcGbR371eLQddKrKz+8V/Nm2IafTj0+lzrcqQ0Xgc2
         LwPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=DvIle9Z7Le0W/koXErTIOG9PhIMMIXfJqWN4mPJ33BE=;
        b=BQ1HpnecAVrH7rEI1YnuXGVdvoxGxhJFNyvFB0JV6op9BGTANkH3e8VPAwxXYSgIfK
         /rJrgLFR1dFCqBsVfxxzgvOmHw8zgMbxNy5PPl/psz7leT8tLfpFDmn9ZPRWcmAxjpSR
         ldW+ZiZSxZyKgpcgJeeonjB0cNaYl9lMjzi4qPyT9NN8zfAIO+7kgw+mcNJxjqVMs1uD
         z6cIpWmawxM2/JT4vK6z5MNvd99j3yyopCiDARlX+erdH/i3LfXy3o6b9yKUI+EZz7qH
         Rkm0+WGn7YMUf7MscNjlYh8Sdpia7xCdoCbJTP6g0c+ZMQnODVCqYA9+J9Hzt66iYV1o
         DGXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=hUxoFsGk;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t22sor46375013pgg.51.2019.07.31.13.04.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 13:04:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=hUxoFsGk;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=DvIle9Z7Le0W/koXErTIOG9PhIMMIXfJqWN4mPJ33BE=;
        b=hUxoFsGkeADYymjGHq5GAFM8PLLF2oTqH90Qwa1lVGomKVeJv3LpYYq908h6tx+NC6
         JboSViSFWGOnrHw3eax6eEOT2n+FS9htW1HchWAp3w0jojJ78gsyAANzR8f7TlGgYKbp
         yQKiR7/Vje+a0p9TBadUOpZtoN9epeDzQlCK0=
X-Google-Smtp-Source: APXvYqwIJxMJOxdtJ5g0WQFgFO3TDsvWgqhNn6FrJTk3e9UcxKXtIPqx/42ra07S8mgFqWWw/OG6iw==
X-Received: by 2002:a63:1455:: with SMTP id 21mr71350404pgu.116.1564603497556;
        Wed, 31 Jul 2019 13:04:57 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id g4sm84014438pfo.93.2019.07.31.13.04.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 31 Jul 2019 13:04:56 -0700 (PDT)
Date: Wed, 31 Jul 2019 13:04:55 -0700
From: Kees Cook <keescook@chromium.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Laura Abbott <labbott@redhat.com>,
	Alexander Potapenko <glider@google.com>,
	kernel test robot <rong.a.chen@intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
	linux-mm@kvack.org
Subject: Re: [PATCH] mm: slub: Fix slab walking for init_on_free
Message-ID: <201907311304.2AAF454F5C@keescook>
References: <CAG_fn=VBGE=YvkZX0C45qu29zqfvLMP10w_owj4vfFxPcK5iow@mail.gmail.com>
 <20190731193240.29477-1-labbott@redhat.com>
 <20190731193509.GG4700@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190731193509.GG4700@bombadil.infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 31, 2019 at 12:35:09PM -0700, Matthew Wilcox wrote:
> On Wed, Jul 31, 2019 at 03:32:40PM -0400, Laura Abbott wrote:
> > Fix this by ensuring the value we set with set_freepointer is either NULL
> > or another value in the chain.
> > 
> > Reported-by: kernel test robot <rong.a.chen@intel.com>
> > Signed-off-by: Laura Abbott <labbott@redhat.com>
> 
> Fixes: 6471384af2a6 ("mm: security: introduce init_on_alloc=1 and init_on_free=1 boot options")

Reviewed-by: Kees Cook <keescook@chromium.org>

-- 
Kees Cook

