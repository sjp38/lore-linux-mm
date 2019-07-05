Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 784AFC5B57D
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 03:10:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39EB821873
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 03:10:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nifty.com header.i=@nifty.com header.b="GExcANG0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39EB821873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=socionext.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CD9228E0003; Thu,  4 Jul 2019 23:10:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C89758E0001; Thu,  4 Jul 2019 23:10:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B78EB8E0003; Thu,  4 Jul 2019 23:10:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0008E0001
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 23:10:06 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id i26so4722814pfo.22
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 20:10:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=wWYGFUb+P+k+0keFxKdK3YKZmXuC4tWs7ONW753LY34=;
        b=DEyrEj0fRKlI9Kwk0aiXACWw6Lly6kAleZlLi/oeF+cz7ctPyrShPqmtOL1op+uTGQ
         AcQthigcASVMNVM1yLV3aK++3gURVfj7bNUOekcc6xHVOtH4MMAc49IhERYro1tUXKGb
         TFpygOvHXH9TFBkk1nbL4S9Mh+WDt2rW+WjHd0VKaEU4qru1s/U66tpphqqgIcpKCHUC
         qrOb2eCJLUQKbHnXKewLWn+rvb7SOEDIRFO7gdm/giMoZ5kYpEnYTuZepFDwbLMgEBAF
         Vm3j2s3DdvDskQhjNQsx561WasnSe83omDIDi7vh50jkisA3YssZt2RqOVLPVs4AL/1D
         aFNQ==
X-Gm-Message-State: APjAAAX7c1gtH64m8EkztVdKVf5vjm6mMUNCCUSORa3LLzG/0DLopmPB
	lQaSP5+VePOj5sbnylCu5YUbJef1rh3lU+Tp8v+u3ZnFNRFr9px3LfeJtkrTCQ1b2Wb7TdOq9Ju
	WANxWCdticszRhQRtXMtTF3NZn2V7louRlYwTR78xowpYlMo7YQYEmzY/tvqvSHM=
X-Received: by 2002:a17:90a:2486:: with SMTP id i6mr1639852pje.125.1562296206198;
        Thu, 04 Jul 2019 20:10:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHjrvLVYuIH5a9o9OXwuuuJ0EZ6vBSBtfkz91u+LD+F4i7rljy2jZGB813i9UX9v/BZGEs
X-Received: by 2002:a17:90a:2486:: with SMTP id i6mr1639787pje.125.1562296205650;
        Thu, 04 Jul 2019 20:10:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562296205; cv=none;
        d=google.com; s=arc-20160816;
        b=sBMvEO7itRxpIdyBXjLbUN/6UchQNUdDTypQdksDG3vh+Bsa87KXnyBJ+cx8+CJ9mm
         Vu1jVAr4znvGgNgGOBF4n8JYCuPVpVzy942AdvMChecNKYv8i4zWr57oj+TuSeoQx7he
         VGd8vKtaBWXNJbUm169vLSaQNTxZ4Zic+EgXHVfeK2shpaUSivqN/6qJQg3YfQKap/9/
         2h1NQX/oBaiZc/0Yd4EjWWeVhZxAFBaFciFVR3ReS/jRoIfa2JAjE0kCUi/T3RMrg/qY
         klO//b88JKJf2O9JeU7zyyokGrivChGhx2a6JTk1pQ3MNKQBpzgmogtuKZJoNYupKglf
         mV4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature:dkim-filter;
        bh=wWYGFUb+P+k+0keFxKdK3YKZmXuC4tWs7ONW753LY34=;
        b=s1NLBzGTCo+nrSzLj2TmSbew+xeR79A/+L+9aJF13BzIrGRh7pHusLfAQ9bhfV/a5r
         u/idAnjZfQokgEhdf1nT51KeVPZGTN2cdpJ9IVH1ryaP+5SDrUW9So0WzE4PTtUtIzzz
         V9P1+ifd1vzCdze7uUm2ZpctlF8b/apgBXI8eoCOEZ9VsG6vl5sVmeVEVYRrQtUWS90q
         eWCDxWifzl3JI8z2mSxzqZhOI9R9+7NMQ+OMtfCMdsQ2RDvjscGKcSFoCx09mRf46qNV
         EkQs8Iz66/ztJ4UCM8e6Hf5k2S9aCX38EmbyHQPfZ68NHa+hqpTez+4ubnCz0TRygvIv
         FxPg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nifty.com header.s=dec2015msa header.b=GExcANG0;
       spf=softfail (google.com: domain of transitioning yamada.masahiro@socionext.com does not designate 210.131.2.90 as permitted sender) smtp.mailfrom=yamada.masahiro@socionext.com
Received: from conssluserg-05.nifty.com (conssluserg-05.nifty.com. [210.131.2.90])
        by mx.google.com with ESMTPS id y19si1111576pll.326.2019.07.04.20.10.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 20:10:05 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning yamada.masahiro@socionext.com does not designate 210.131.2.90 as permitted sender) client-ip=210.131.2.90;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nifty.com header.s=dec2015msa header.b=GExcANG0;
       spf=softfail (google.com: domain of transitioning yamada.masahiro@socionext.com does not designate 210.131.2.90 as permitted sender) smtp.mailfrom=yamada.masahiro@socionext.com
Received: from mail-vs1-f43.google.com (mail-vs1-f43.google.com [209.85.217.43]) (authenticated)
	by conssluserg-05.nifty.com with ESMTP id x6539liL015288
	for <linux-mm@kvack.org>; Fri, 5 Jul 2019 12:09:48 +0900
DKIM-Filter: OpenDKIM Filter v2.10.3 conssluserg-05.nifty.com x6539liL015288
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nifty.com;
	s=dec2015msa; t=1562296188;
	bh=wWYGFUb+P+k+0keFxKdK3YKZmXuC4tWs7ONW753LY34=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=GExcANG0Z97hoM5QYgPCfde3YccjeMehq5mCWvt/5h4kJNxx+OjGc61n7hj8dd2hg
	 q87bAV+yWBT6/zOxz2WaYYAd53hzVNTHHnDjnWJzq5ZWDM8cAOwp/8HA+bDpjTiY0r
	 VDumQ8H5Npn76tylIUohWQ01JaAgemwrwhpCVFcDQc4tKi4BWUSYjoBI0l93jza4F3
	 HkViyfsUL8AxqBFNPOGmcy03qX+vI005RHQke68u/LaZpclB3KHq7DJKiWqTXOmsnM
	 p543YvXKEKzyfH9KSIbWGLE9UVppdiHdRIu35XrHbhBD9eTwAafhzmU1c5ufWtaqQy
	 KD+AOv6OL4WwQ==
X-Nifty-SrcIP: [209.85.217.43]
Received: by mail-vs1-f43.google.com with SMTP id a186so2961873vsd.7
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 20:09:48 -0700 (PDT)
X-Received: by 2002:a67:f495:: with SMTP id o21mr774753vsn.54.1562296187154;
 Thu, 04 Jul 2019 20:09:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190704220152.1bF4q6uyw%akpm@linux-foundation.org>
 <80bf2204-558a-6d3f-c493-bf17b891fc8a@infradead.org> <CAK7LNAQc1xYoet1o8HJVGKuonUV40MZGpK7eHLyUmqet50djLw@mail.gmail.com>
In-Reply-To: <CAK7LNAQc1xYoet1o8HJVGKuonUV40MZGpK7eHLyUmqet50djLw@mail.gmail.com>
From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Fri, 5 Jul 2019 12:09:11 +0900
X-Gmail-Original-Message-ID: <CAK7LNASLfyreDPvNuL1svvHPC0woKnXO_bsNku4DMK6UNn4oHw@mail.gmail.com>
Message-ID: <CAK7LNASLfyreDPvNuL1svvHPC0woKnXO_bsNku4DMK6UNn4oHw@mail.gmail.com>
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

On Fri, Jul 5, 2019 at 12:05 PM Masahiro Yamada
<yamada.masahiro@socionext.com> wrote:
>
> On Fri, Jul 5, 2019 at 10:09 AM Randy Dunlap <rdunlap@infradead.org> wrote:
> >
> > On 7/4/19 3:01 PM, akpm@linux-foundation.org wrote:
> > > The mm-of-the-moment snapshot 2019-07-04-15-01 has been uploaded to
> > >
> > >    http://www.ozlabs.org/~akpm/mmotm/
> > >
> > > mmotm-readme.txt says
> > >
> > > README for mm-of-the-moment:
> > >
> > > http://www.ozlabs.org/~akpm/mmotm/
> >
> > I get a lot of these but don't see/know what causes them:
> >
> > ../scripts/Makefile.build:42: ../drivers/gpu/drm/i915/oa/Makefile: No such file or directory
> > make[6]: *** No rule to make target '../drivers/gpu/drm/i915/oa/Makefile'.  Stop.
> > ../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915/oa' failed
> > make[5]: *** [drivers/gpu/drm/i915/oa] Error 2
> > ../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915' failed
> >
>
> I checked next-20190704 tag.
>
> I see the empty file
> drivers/gpu/drm/i915/oa/Makefile
>
> Did someone delete it?
>


I think "obj-y += oa/"
in drivers/gpu/drm/i915/Makefile
is redundant.



-- 
Best Regards
Masahiro Yamada

