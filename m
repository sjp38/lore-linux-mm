Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEA53C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 18:57:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9502420657
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 18:57:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="euQLU2Xc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9502420657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 024B66B0003; Thu, 21 Mar 2019 14:57:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F17056B0006; Thu, 21 Mar 2019 14:57:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2DCC6B0007; Thu, 21 Mar 2019 14:57:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 960976B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 14:57:32 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id t82so1622551wmg.8
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 11:57:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=k4/o12332QL7VyxmH7N//Xj1/7/p+fqipKwASTaeBR0=;
        b=RHzvo+K4P/PtMMOOb24y5gpDFfIt28olViuj2X7Yrigf21HB6hp25TDJ/afrjE0DZE
         ptjm8yXdqHDkDxFucz8yom//1XarG4cCGxMfezfa1CxiLUjD5Tjh0l67/MYvzoMaASPv
         2OXpK/8RXvrM8m1w/Z0DdauAG90Fjgakm91DPtnZBttXGDW5BmUCjqwu9iVMJ5mQYURu
         nckAKm8ZPbwy73WzzWgL9UsLnvxMOvZ+mes0v28H+gltuNqsV+HeXRDsVjvZHr2c8PH2
         STF6klNlDNky/mir3khylVE9IkhMeVZqDpTnrSIW3tQ225jsH+WZfLMqBHgzwPGV7XAu
         93qw==
X-Gm-Message-State: APjAAAX2//qI/k57dJTV27I3Ihni9bEc7icZxRLTnUeWAklvAr9vf6fq
	73EsrA+QbIsG95k1PWUMjhxT2vZHxPtSCffNcjOW8anXqcop6u5jy7sJ3cDzzrIQVS5BsajNNKe
	Z9L54/eh3QqiVPsKtonvUvG9ZGhxMA5+Ksb2z+zSHSUQ+PNChSPczdm+hiMjtYO1KhQ==
X-Received: by 2002:a5d:6a87:: with SMTP id s7mr3837081wru.81.1553194652013;
        Thu, 21 Mar 2019 11:57:32 -0700 (PDT)
X-Received: by 2002:a5d:6a87:: with SMTP id s7mr3837039wru.81.1553194650973;
        Thu, 21 Mar 2019 11:57:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553194650; cv=none;
        d=google.com; s=arc-20160816;
        b=ZfO4dmX6FN1BX8tKLmUFPEhoQ1ijZ+24zVp88NVjaZxqIftQmY71n9lm6DWO6pQSX9
         NOMhPBrfWRFJsfRxDccGxjQsszd7aoIn6SzSAmOSqL3JAgKUnpKHlsE5fW0OhZu6vz1e
         nvSFEo63fB+JkkNQownfDu2ITRUV4l5OYULoAGQdBOT8Pus0NX7MnsF5wCJoJ7OLzfHL
         NXuUTu0FBb6HE4L3blt5dHK8jWhE2IvgrtA9gnTUycEHEhG1+57/e+8PXcFpIo5Ze9cy
         i5d98fXAxH1iygtN2rfwheHHACJRvzLye+tS9F77VEzdaE021cObBZVCvXbh79JVjSqv
         gXcQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=k4/o12332QL7VyxmH7N//Xj1/7/p+fqipKwASTaeBR0=;
        b=VzthVGLE/FHZh1teuTS+KGJG3ObjuX7GGWD2U0BI2cDNqiN1VXOGD3xxITTXPg4/o/
         ttNmrCnugT+qwg60z/hbxG8ajmHMK4KcdRiM33JIeszCplyVZBjTtgM0Ucftj71ESFc6
         ZdDulO02SVOYgANdpRAfqQlLU4Xv4RhIFqCqk3UpAbVnUdJS0C8zThD9joF3scl4DIT0
         9NuzA1u3yICCeFIBiPQvysZivrOjF6112J+AT5mxuzJniypPy3OGzISCTvf7RBVKQ2Jj
         NAjWKuJYpazgbZvanp4LdaEjmFeqofYNeAhtH1krEd5itrFqYAUa3iFxRKr7DyVtc9Ur
         5nUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=euQLU2Xc;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t26sor4181859wmj.25.2019.03.21.11.57.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Mar 2019 11:57:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=euQLU2Xc;
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=k4/o12332QL7VyxmH7N//Xj1/7/p+fqipKwASTaeBR0=;
        b=euQLU2XcKsvkOwUxPVT0Ai0NgLmj+t8HVKIgz1E3lfFw+qdqR4CAaPNHaoHtE2dBbf
         U7CXv8hpMye2g0x8QbnKSa5JU72b7yoYCMDGlAd8T4asyqcqBBZJbpDSURzLhy9OCpXj
         tMOMtOk4QZUZ1xYPde+BY5yKwhZ6vOM7gLOMOLpXtRlgc2LY9E4FBED5PcC44MQBoa2x
         JOMqhnSbQGD+RqCFc60bLyGrbUeS1qiT6pRJi1b6mLaWzYjbHZkiZZgjd/MKK8tgeQb9
         BOxftEUbAhp89fm/2LkAnEz+TjrihnQkKoSttiPeU0PxoM2kHlKuXdyYaF1fL7jir54s
         0QwA==
X-Google-Smtp-Source: APXvYqz/nFaRkE5KwQhK/5840K12O/IcX+w5EbmyDGpVH+EW7wBhWfcRRswUW45+PdVWTscXCUtrTQzfYH7nbXOj+2A=
X-Received: by 2002:a1c:4e04:: with SMTP id g4mr441765wmh.127.1553194650179;
 Thu, 21 Mar 2019 11:57:30 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
 <20190315205826.fgbelqkyuuayevun@ca-dmjordan1.us.oracle.com>
 <CABXGCsMcXb_W-w0AA4ZFJ5aKNvSMwFn8oAMaFV7AMHgsH_UB7g@mail.gmail.com>
 <CABXGCsO+DoEu5KMW8bELCKahhfZ1XGJCMYJ3Nka8B0Xi0A=aKg@mail.gmail.com>
 <1553174486.26196.11.camel@lca.pw> <CABXGCsM9ouWB0hELst8Kb9dt2u6HKY-XR=H8=u-1BKugBop0Pg@mail.gmail.com>
 <1553183333.26196.15.camel@lca.pw>
In-Reply-To: <1553183333.26196.15.camel@lca.pw>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Thu, 21 Mar 2019 23:57:19 +0500
Message-ID: <CABXGCsMQ7x2XxJmmsZ_cdcvqsfjqOgYFu40gTAcVOZgf4x6rVQ@mail.gmail.com>
Subject: Re: kernel BUG at include/linux/mm.h:1020!
To: Qian Cai <cai@lca.pw>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, 
	mgorman@techsingularity.net, vbabka@suse.cz
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Mar 2019 at 20:48, Qian Cai <cai@lca.pw> wrote:
> OK, those pages look similar enough. If you add this to __init_single_page() in
> mm/page_alloc.c :
>
> if (page == (void *)0xffffdcd2607ce000 || page == (void *)0xffffe4b7607ce000 ||
> page == (void *)0xffffd27aa07ce000 || page == (void *)0xffffcf49607ce000) {
>         printk("KK page = %px\n", page);
>         dump_stack();
> }
>
> to see where those pages have been initialized in the first place.

In the new kernel panics "page" also does not repeated.

$ journalctl | grep "page:"
Mar 21 20:46:56 localhost.localdomain kernel: page:fffffbbbe07ce000 is
uninitialized and poisoned
Mar 21 21:28:03 localhost.localdomain kernel: page:ffffdecc207ce000 is
uninitialized and poisoned
Mar 21 23:43:24 localhost.localdomain kernel: page:fffff91ce07ce000 is
uninitialized and poisoned


--
Best Regards,
Mike Gavrilov.

