Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8F88C43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 02:26:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 53F7820830
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 02:26:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Op7t8mr2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 53F7820830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBE098E0003; Sun,  3 Mar 2019 21:26:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B6E2C8E0001; Sun,  3 Mar 2019 21:26:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A5D6D8E0003; Sun,  3 Mar 2019 21:26:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 79D718E0001
	for <linux-mm@kvack.org>; Sun,  3 Mar 2019 21:26:18 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id f10so3393173ioj.9
        for <linux-mm@kvack.org>; Sun, 03 Mar 2019 18:26:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=SlxiaBDtCsb8s+AHXZJQEIWXirTcDE9/aTxKrUnRaR4=;
        b=t1tDaMB3RyQr7Zekjhc4yri0t6z0DyF6RdKgy6TxWRDHDIL5Uerca0Dy/67USYfaiX
         mbxH4tK/XwbULBzBvhDnRULVpjdiWaHWnurrymDccrOLYbsybhplyJq+pAk3H4Jt5YkH
         yfZuX92oKkJQ/9/QYhcvaWrUKgijIDB0z2BpSceocTxtJAsbgKREzy4j9lrAjJHBFhjO
         p9F4oSvYBU/35rDRvo5Bd2iwqDsQH9Ogo1qzaWZCQFDWn7YXu85Ima3KHWyGQxtwBIIr
         pZY1bVoYuDQd6spDsfnTtcO/6SfHio+Lri4yz5WQ3Egsu9zuPsWx6BhDowphq8HSHK2y
         mPBQ==
X-Gm-Message-State: APjAAAXyOqqPi4rQ5n1Oca9ZN55UUyeRt8ko3NHdE8FsOqHTjH2CuiVt
	/XO+zHzFwRUVToehJahY/BL3IHwx4SeyeWGfkXOuzOvA+IPFckOg5EArn2cSQjpozVSExygbqsX
	Hhth4enL/zKLroWfJ8Pw6qzdyHQVDL35QzA+Ap9TKcceJrfivpfYJ3brypE7gm+XY3Y9baR9Lvd
	GYOWcsZAxB5/JH7urZ8+rf+xP1JM2opWjewlXnbb1wuKV0m0IH0b3CXrEqdnRdSKfSG5HiAxKSS
	4lrXf1TnJWru01mHblPUaIkd8ZhK+lnlcNZaSCvJhNC1jeopQaIywbOUGvzmbUE/wINeKcg3N12
	5TfcP92Oya7rEnsPXO60vdOEjYpYwBaBnucHbnWKtc3xSkUUPTtltazLFHGWZOO4+HmLJgJdpmO
	R
X-Received: by 2002:a5d:8489:: with SMTP id t9mr9368615iom.0.1551666378254;
        Sun, 03 Mar 2019 18:26:18 -0800 (PST)
X-Received: by 2002:a5d:8489:: with SMTP id t9mr9368587iom.0.1551666377029;
        Sun, 03 Mar 2019 18:26:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551666377; cv=none;
        d=google.com; s=arc-20160816;
        b=fIO+JwVwm2uX8LuoSTtwBKF3C4hVVSGyFJ67rO9crHUwnlqi34E1YSN3Grhc3jiE+Y
         fBTj4mC0bKTRFZA5/Gt7vRh52FpCKYL+BDs7F9lN2veXv+7TiuqEeGHPBah/f68Om3OV
         xNMjo5IsvxDUSEv2RVgMqads44h7lNTcv1kvE6T1XJlB8l7QpvvqAlSx+b/0r/X5MPf3
         3HZqPhPw60j6tznLBTOY+lNPpNL6Lfu0QYC7XFNI7OnZBzCnvFH/8TGAtK1vYa5Xjwyl
         gYOcAazCKwE8CN5L8WenflGWRi7bQ0y6+as7/GeAgRfmgNVPjlSZWoOJXJ0G97Tl19eO
         0fyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=SlxiaBDtCsb8s+AHXZJQEIWXirTcDE9/aTxKrUnRaR4=;
        b=0a/aTZjO+/hb51icV4QOUySLNcFMZ6akDw9scUZ4nG5m/dUrJdX2dnf/G5+B8uApl3
         rqBKND2Dp8SNDL8XrdqQrMlhwIRn+2uUZZUNdFcV3lLIJUV7jrPiLfuvNvewIWSIAWoX
         zcVsWPg5JzNXeVQVhXQndrkemegxDIwKFdZ8nfGvEd7a/nMKIm4LYA5Es7gAg8mqEs6Z
         QT4uuvXgjRdu+cU5e46HrFMhrUJEjALX9nTOT68WAZDgdCf/nqL/LTZaY+ULvwxvj5Dy
         tpXOsdOnKWeBCCnYaEXgwCyYc2hZww15x/+J3hmpEK3Sp3V8oPiPKzVTdSpsAhL2fo6l
         Wjug==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Op7t8mr2;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z12sor11430068jab.1.2019.03.03.18.26.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 03 Mar 2019 18:26:17 -0800 (PST)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Op7t8mr2;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=SlxiaBDtCsb8s+AHXZJQEIWXirTcDE9/aTxKrUnRaR4=;
        b=Op7t8mr2aPhyg/N82dMo16QAf7Y20RPLi6Hq+814LAkXcZjdT2AsuK0Mw0CjgVh3Wj
         5ZWSuAZHeuhJJBejxAH6V/eOKlY49r0nl9OfJT8mwgIm8dIGUc9GBBchtwItQFWdjo3y
         cY2Yv8xlhbeWR0ikCbhehJBAc+lF+XCMTzvEssMeEsyQ1BCofcMBo4ZjaSyTXqlmMtWw
         ITC6/9zugY0B12B5DsD6H2X4FlOv49mvJGTqD74mnzVDJZVsDTkWqcY5Xmw0GIEhZo3Z
         ZNFXAQLFIkU2NWOzqAHwWhfkD97y1gRsmuB2ffb7EDFsCY4q9OiHTi+Mz8Fm90ZhiESH
         CnfA==
X-Google-Smtp-Source: APXvYqytvs8Nz3VbdmmAxu9RELGFVcrKpqEgtCCTSKXAFC+oePn5C1fNufMGe6C6DmOF1ZYtXxl8UWccGDL1w59L/qM=
X-Received: by 2002:a02:13ca:: with SMTP id 193mr9070150jaz.117.1551666376494;
 Sun, 03 Mar 2019 18:26:16 -0800 (PST)
MIME-Version: 1.0
References: <1551501538-4092-1-git-send-email-laoar.shao@gmail.com> <201903030739.kcuGQINq%fengguang.wu@intel.com>
In-Reply-To: <201903030739.kcuGQINq%fengguang.wu@intel.com>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Mon, 4 Mar 2019 10:25:40 +0800
Message-ID: <CALOAHbDjz-0oHyffgiwgba44uGCMpcu3r3Yuuvdhg7mbk00h1A@mail.gmail.com>
Subject: Re: [PATCH] mm: compaction: show gfp flag names in
 try_to_compact_pages tracepoint
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, 
	Souptick Joarder <jrdr.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 3, 2019 at 7:04 AM kbuild test robot <lkp@intel.com> wrote:
>
> Hi Yafang,
>
> Thank you for the patch! Perhaps something to improve:
>
> [auto build test WARNING on tip/perf/core]
> [also build test WARNING on v5.0-rc8 next-20190301]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Yafang-Shao/mm-compaction-show-gfp-flag-names-in-try_to_compact_pages-tracepoint/20190302-212241
> reproduce:
>         # apt-get install sparse
>         make ARCH=x86_64 allmodconfig
>         make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'
>
> All warnings (new ones prefixed by >>):
>
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
> >> include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>
> sparse warnings: (new ones prefixed by >>)
>
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast from restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: incorrect type in argument 3 (different base types)
> >> include/trace/events/compaction.h:171:1: sparse:    expected unsigned long flags
> >> include/trace/events/compaction.h:171:1: sparse:    got restricted gfp_t [usertype] gfp_mask
>    include/trace/events/compaction.h:171:1: sparse: warning: cast to restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: cast to restricted gfp_t
>    include/trace/events/compaction.h:171:1: sparse: warning: restricted gfp_t degrades to integer
>    include/trace/events/compaction.h:171:1: sparse: warning: restricted gfp_t degrades to integer
>    include/linux/gfp.h:318:27: sparse: warning: restricted gfp_t degrades to integer
>    mm/compaction.c:1750:39: sparse: warning: incorrect type in initializer (different base types)
>    mm/compaction.c:1750:39: sparse:    expected int may_perform_io
>    mm/compaction.c:1750:39: sparse:    got restricted gfp_t
>    mm/compaction.c:351:13: sparse: warning: context imbalance in 'compact_trylock_irqsave' - wrong count at exit
>    include/linux/spinlock.h:384:9: sparse: warning: context imbalance in 'compact_unlock_should_abort' - unexpected unlock
>    mm/compaction.c:545:39: sparse: warning: context imbalance in 'isolate_freepages_block' - unexpected unlock
>    mm/compaction.c:943:53: sparse: warning: context imbalance in 'isolate_migratepages_block' - unexpected unlock
>
> vim +171 include/trace/events/compaction.h
>
> b7aba698 Mel Gorman      2011-01-13  170
> 837d026d Joonsoo Kim     2015-02-11 @171  TRACE_EVENT(mm_compaction_try_to_compact_pages,
> 837d026d Joonsoo Kim     2015-02-11  172
> 837d026d Joonsoo Kim     2015-02-11  173        TP_PROTO(
> 837d026d Joonsoo Kim     2015-02-11  174                int order,
> 837d026d Joonsoo Kim     2015-02-11  175                gfp_t gfp_mask,
> a5508cd8 Vlastimil Babka 2016-07-28  176                int prio),
> 837d026d Joonsoo Kim     2015-02-11  177
> a5508cd8 Vlastimil Babka 2016-07-28  178        TP_ARGS(order, gfp_mask, prio),
> 837d026d Joonsoo Kim     2015-02-11  179
> 837d026d Joonsoo Kim     2015-02-11  180        TP_STRUCT__entry(
> 837d026d Joonsoo Kim     2015-02-11  181                __field(int, order)
> 837d026d Joonsoo Kim     2015-02-11  182                __field(gfp_t, gfp_mask)
> a5508cd8 Vlastimil Babka 2016-07-28  183                __field(int, prio)
> 837d026d Joonsoo Kim     2015-02-11  184        ),
> 837d026d Joonsoo Kim     2015-02-11  185
> 837d026d Joonsoo Kim     2015-02-11  186        TP_fast_assign(
> 837d026d Joonsoo Kim     2015-02-11  187                __entry->order = order;
> 837d026d Joonsoo Kim     2015-02-11  188                __entry->gfp_mask = gfp_mask;
> a5508cd8 Vlastimil Babka 2016-07-28  189                __entry->prio = prio;
> 837d026d Joonsoo Kim     2015-02-11  190        ),
> 837d026d Joonsoo Kim     2015-02-11  191
> 91811e0d Yafang Shao     2019-03-02  192        TP_printk("order=%d gfp_mask=%s priority=%d",
> 837d026d Joonsoo Kim     2015-02-11  193                __entry->order,
> 91811e0d Yafang Shao     2019-03-02  194                show_gfp_flags(__entry->gfp_mask),
> a5508cd8 Vlastimil Babka 2016-07-28  195                __entry->prio)
> 837d026d Joonsoo Kim     2015-02-11  196  );
> 837d026d Joonsoo Kim     2015-02-11  197
>
> :::::: The code at line 171 was first introduced by commit
> :::::: 837d026d560c5ef26abeca0441713d82e4e82cad mm/compaction: more trace to understand when/why compaction start/finish
>
> :::::: TO: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> :::::: CC: Linus Torvalds <torvalds@linux-foundation.org>
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

Seems this warning isn't introduced by my patch.
My patch is fine.

I will try to investigate how this warning is introduced.

Thanks
Yafang

