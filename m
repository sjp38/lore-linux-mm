Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CC1DC18E7D
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:03:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8089217F9
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 10:02:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Hxk6PkJx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8089217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74B776B0007; Wed, 22 May 2019 06:02:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6FCCA6B0008; Wed, 22 May 2019 06:02:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 613FA6B000A; Wed, 22 May 2019 06:02:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3656B6B0007
	for <linux-mm@kvack.org>; Wed, 22 May 2019 06:02:59 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id 5so689985oix.4
        for <linux-mm@kvack.org>; Wed, 22 May 2019 03:02:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=47TiyBCz41Yx1Bv/NNksDp+zVbcuSGdQexnBZ0Z9rP4=;
        b=UXzl0u+R46Su0DowvDWVfwhNQt+pIJtgFb7y+wHPsEA+wmWc3MIfvc1mkZaZkpQOeM
         acKk+tmp3drOI4CZybCk7vOuaMnDDwi3fJjgaVAu6O3tF7b3VEBIYaUG3L/Hz2zPGKA/
         Mo2hTVlIWUhpofDykc0Vfcy08eY6afkS+L9mTR2x5+2sN95+Vdnh1TD3U3Be1IjTthHQ
         reP7FqBZ7nNyJDICGSDSsx//83bdJe4yva2Pe9l82xJVeNRtOvyS6qOVCnYjl+u66dXl
         6wpV5oZRNwuz5PWRky1QNVFCSlbaZ9e/KthCsuLwbujbxti1EzLYq4OFAJ8l8bSntADa
         2wcA==
X-Gm-Message-State: APjAAAXe1OEmk1xqWJtrP70Qav0OAvY5sfLlmYRUpP7B2vmJhKu5Ei1F
	mmAdXOa29YLzMdDYC3rWUoAElEM05FJweD+ysm/b99AuBDFIM0Pf3sgJq+xKcczRUkAEAt0r3f8
	d1rJV5s6ONdsppD8ZErwQrwdky3IUB8syuW6uPqjGxI0PvS+upEU9+0HriSwr3mSD3A==
X-Received: by 2002:a05:6830:1389:: with SMTP id d9mr171685otq.329.1558519378852;
        Wed, 22 May 2019 03:02:58 -0700 (PDT)
X-Received: by 2002:a05:6830:1389:: with SMTP id d9mr171649otq.329.1558519378267;
        Wed, 22 May 2019 03:02:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558519378; cv=none;
        d=google.com; s=arc-20160816;
        b=E3fuiNlqqFhKBhMjX1A9dMM+NG5/+e4/k6tkDz0g6F/CwmBZhseUvdK2f6n9D2TmLB
         4iUy8h+E/DpLyeTAfN+XBE/32UyxXBW3dtN6BjhOgpU02fOCdlOyjzp9Wu1YBPrpqnvM
         jjqIp5230CC7WF0PuEPzXEuRSQvm+mSN7HD1IurpmTPB94bwUKHhgsapPGL78U2Yykyq
         yV6Cm+FayNKIqlJgI6l/e0DaS54YRuIykmdEIwEbC05MfU+v/b/sUqgj+f2+JvXSTfIb
         qpXlR0Rgs1GLZR44gjCFlYXQQf/YaBaglnZZ/yDY2ecYn2v8aTEI1zJV+9lQAKIxCuqK
         brlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=47TiyBCz41Yx1Bv/NNksDp+zVbcuSGdQexnBZ0Z9rP4=;
        b=KWDcxiuvFe9vG97RfUTyhRyv8K8hpY0msoW8n/c9iEP4lccuT6dOJbSRiA+juJd6mt
         IVPKFK2n+6TPiL/qjX9FjcS8b8u18sEqBJnMT0+Sl7XHmyNuvUrQLOoqK+lPuh8nppSI
         UDDHGgAcQxo625ExtrcMkkHvrAWcG67icRpu5hHE2Woy9W/88uodNw+PeQJX3rWuli5x
         4dCdQdvjI0eG3HYBOcqdqAr++wndoXljUvyDYpExPEfX/f/2pPgG/n54NUo2Q5O3VH/Q
         joEvF6tsfqJhhi+i+/8aporrw647cUVZaC6O9DjYRqs1i4ubUupIC9DqUNqywWBDFC4b
         wPTw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Hxk6PkJx;
       spf=pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=elver@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h74sor9835942oib.69.2019.05.22.03.02.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 May 2019 03:02:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Hxk6PkJx;
       spf=pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=elver@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=47TiyBCz41Yx1Bv/NNksDp+zVbcuSGdQexnBZ0Z9rP4=;
        b=Hxk6PkJx0M1SEl/EATamZoo1PbzAmcXNEwVjqmBc+SnUwmrdzF2iuUVjWEjQ6cI+fR
         67M5NTPxRJOcMbUUkAWrsfwRUyL6YyPpbzv89mnmsCa+sRIJGeOnSwS9nyn5CM+vzhGE
         hxE0bbOlNDDP5d+gog20x4heHjwnStDaj7Xy2R2YlPenUJz6iZoqb5Em/Ynp6TUvs/zv
         YVJ21wXJTwNi5pm9CBizLH4TY4HK1XmXxvq2U4kdq8YXhcteZnMwKitwhW4bHxVozsbf
         MM7ZMDCGprZ82beyTbXJh00k98J4Hqp4EDcTqF5Xw91mVShWdm/gvFO3/lYki/81Kgjs
         2jCw==
X-Google-Smtp-Source: APXvYqxn2zuZFxT6AuzcL2G2owEvKVqlQddmjBsLX4hBZYveZsSf0+nswnaPVACN+eD/e/rS8IjO6U0C2AmMC7ytPx0=
X-Received: by 2002:aca:e044:: with SMTP id x65mr4232447oig.70.1558519377524;
 Wed, 22 May 2019 03:02:57 -0700 (PDT)
MIME-Version: 1.0
References: <20190517131046.164100-1-elver@google.com> <201905190408.ieVAcUi7%lkp@intel.com>
 <20190521191050.b8ddb9bb660d13330896529e@linux-foundation.org>
In-Reply-To: <20190521191050.b8ddb9bb660d13330896529e@linux-foundation.org>
From: Marco Elver <elver@google.com>
Date: Wed, 22 May 2019 12:02:46 +0200
Message-ID: <CANpmjNPYoaE6GFC1WC2m1GsGjqWRLfuxdi86dB+NCFeZ93mtOw@mail.gmail.com>
Subject: Re: [PATCH] mm/kasan: Print frame description for stack bugs
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitry Vyukov <dvyukov@google.com>, 
	Alexander Potapenko <glider@google.com>, Andrey Konovalov <andreyknvl@google.com>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I've sent v3. If possible, please replace current version with v3,
which also includes the fix.

Many thanks,
-- Marco


On Wed, 22 May 2019 at 04:10, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Sun, 19 May 2019 04:48:21 +0800 kbuild test robot <lkp@intel.com> wrote:
>
> > Hi Marco,
> >
> > Thank you for the patch! Perhaps something to improve:
> >
> > [auto build test WARNING on linus/master]
> > [also build test WARNING on v5.1 next-20190517]
> > [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> >
> > url:    https://github.com/0day-ci/linux/commits/Marco-Elver/mm-kasan-Print-frame-description-for-stack-bugs/20190519-040214
> > config: xtensa-allyesconfig (attached as .config)
> > compiler: xtensa-linux-gcc (GCC) 8.1.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         # save the attached .config to linux build tree
> >         GCC_VERSION=8.1.0 make.cross ARCH=xtensa
> >
> > If you fix the issue, kindly add following tag
> > Reported-by: kbuild test robot <lkp@intel.com>
> >
>
> This, I assume?
>
> --- a/mm/kasan/report.c~mm-kasan-print-frame-description-for-stack-bugs-fix
> +++ a/mm/kasan/report.c
> @@ -230,7 +230,7 @@ static void print_decoded_frame_descr(co
>                 return;
>
>         pr_err("\n");
> -       pr_err("this frame has %zu %s:\n", num_objects,
> +       pr_err("this frame has %lu %s:\n", num_objects,
>                num_objects == 1 ? "object" : "objects");
>
>         while (num_objects--) {
> @@ -257,7 +257,7 @@ static void print_decoded_frame_descr(co
>                 strreplace(token, ':', '\0');
>
>                 /* Finally, print object information. */
> -               pr_err(" [%zu, %zu) '%s'", offset, offset + size, token);
> +               pr_err(" [%lu, %lu) '%s'", offset, offset + size, token);
>         }
>  }
>
> _
>
> --
> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
> To post to this group, send email to kasan-dev@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/20190521191050.b8ddb9bb660d13330896529e%40linux-foundation.org.
> For more options, visit https://groups.google.com/d/optout.

