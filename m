Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0324C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:36:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A57C206DF
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:36:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="GiML85P6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A57C206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAA716B0007; Mon, 25 Mar 2019 18:36:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E58856B0008; Mon, 25 Mar 2019 18:36:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6F816B000A; Mon, 25 Mar 2019 18:36:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABAB56B0007
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 18:36:41 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id v10so4489262oie.4
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 15:36:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=sTcPY30C0OSYzeNRaa/EPMGmie/8U7JXyLn50zJf1Pw=;
        b=B7QzRJcn4zzSQ6V5n9mbmIVCes/a7EQ+fRcRl/zJTiUE+dZQNJyoRiGtvDwIN6LVoA
         tvp0bBZROelwvbbSP78HgwVo04OCIhrrbkyy0PypxFxiCoeA42re36KWomOwxuT1T5bK
         Sbc8y3Nn2WN5qfX6nwr8XylXafrRTHuuJp/wH/X5DGz16KGi5+uG2nV9yNcmXkaTMtjS
         FbkV+g/vWXHLD9HX/8XZYRLHNnqLSoDRQyhHNlu4JNKnQyDexADoeGorwIIiRI56M9vl
         f+2QPdjQ3OHhTrnk6ddlH3aLx8FWlPpgClGplbEIBZYhwdrbkDRvH+3E+onVjbOcagz1
         TTXw==
X-Gm-Message-State: APjAAAUprnSNyEeQS1JftFVAD/ppzlhA0HG36EfpxgeJGroyHMxCSbu6
	G1c/0N9yPbxEmMlNAAtmCMW28mI3mlWjlGNUM4g0VBPAfuwvdLxsUCRt6ab/N4APUoqHrHaG9gu
	oMPOczim4eBZ0MopSddk/vKsd+t327n6iSnYnIvO+TnXzEjr1FgfX33m5tsdGbny2+A==
X-Received: by 2002:a9d:4c8d:: with SMTP id m13mr410242otf.145.1553553401435;
        Mon, 25 Mar 2019 15:36:41 -0700 (PDT)
X-Received: by 2002:a9d:4c8d:: with SMTP id m13mr410207otf.145.1553553400887;
        Mon, 25 Mar 2019 15:36:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553553400; cv=none;
        d=google.com; s=arc-20160816;
        b=zZKU0neeIwDajGFHMbLDX1zuArgoxptBAK9q7ip/11jmj0plyTbU9kUiTT3UV8XG6d
         kkVCaI0JO6JpyCZBTmy0Z89UWrtduWqMLyOJoHF5KPlDJtxDm0lwNg94GWqIXVezsOtE
         1ydyaCylqNt+2g6AGPlMrfhfHE3vtwh22F6Y+tz4jtcRGEq8bUwl5APMiB6POGlwy+YU
         bhJVSOtY2E0DT+RmXadCxkbaTGxdb1i/xaIn8Xoxdf/ubxRFnAHl+mn7U8IMb49mGV0U
         f1TZPxSXO0qcuCIiSOW+QLIjIWlQW/cW263yvMQqNPBA0hvEdHuuhLU154Wd+8w8BsSk
         67LQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=sTcPY30C0OSYzeNRaa/EPMGmie/8U7JXyLn50zJf1Pw=;
        b=meOQ6DW+OQ39MKKSOsNz6M6/z4sPFqRnoqxTh+9Kic79EE0aOSObADbb+qAf+q9YXU
         somiXWmUH9zjuDB0INtwvvX1Fu3CkG+96zTGOUBaYqG0msVAhbvqSUDBQy0JRgPn5nzH
         FJedXr9ooE1Aj2HY4BDIQ9xl1wS9hL9dtj05M5sLOrnddej/OE3wRmreC6RPM5wa8irv
         7+b7VAmFphfEH5Ayxr7y2AhMX6vnm24s/S8WrYU6wh0ZXh8DO/mhVPhjbommhfzT52TG
         kMTSFhbRtn2O5/ChZ+cSRYMoHB9PMouaMxi8vD2ksb19UcUWktU94yClJF1ri3w6d1x0
         e/sA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=GiML85P6;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i2sor11164965otl.82.2019.03.25.15.36.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 15:36:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=GiML85P6;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=sTcPY30C0OSYzeNRaa/EPMGmie/8U7JXyLn50zJf1Pw=;
        b=GiML85P6LCslgtDlslKCCUhWvbv1y+nvEc56Q0X8Qjel5DMzDzfar6+H7s6fmu2h3d
         dLEyyqXH0XMmCTgsIn3yhKqlcM+JBYc0UTK5/fEknfFXNcWh7vZB4qk8YZDtnv5IAp1l
         JJmvxmcMseSRffwnab8HmvfayPrxqWL01+eSLrgeJSA/9velnAvwDxgjJF0ugNsd/ZFW
         LpEP4qbgPu6yg3gM3ufLilvbIHnGxS7z2m60QKWTsLURCVB/tyWdotVRQdzsF7WEone8
         YAzkam1P/6bRoe78GssUpwMMiqKYpvFyZCQg0hkxWxLA+GhGDSF3+u1c5KgRvgkutwHN
         +uoQ==
X-Google-Smtp-Source: APXvYqxFqrAkIeS5L2WYBPBcjU2Ckw+9rPMAalcwIDZdE3acnVShZDDWo5M3SQr2UUBKcI362os2eQY4GbHhvkhCzss=
X-Received: by 2002:a9d:224a:: with SMTP id o68mr20655282ota.214.1553553400410;
 Mon, 25 Mar 2019 15:36:40 -0700 (PDT)
MIME-Version: 1.0
References: <20190317183438.2057-1-ira.weiny@intel.com> <20190317183438.2057-5-ira.weiny@intel.com>
 <CAA9_cmcx-Bqo=CFuSj7Xcap3e5uaAot2reL2T74C47Ut6_KtQw@mail.gmail.com>
 <20190325084225.GC16366@iweiny-DESK2.sc.intel.com> <20190325164713.GC9949@ziepe.ca>
 <20190325092314.GF16366@iweiny-DESK2.sc.intel.com> <20190325175150.GA21008@ziepe.ca>
 <20190325142125.GH16366@iweiny-DESK2.sc.intel.com>
In-Reply-To: <20190325142125.GH16366@iweiny-DESK2.sc.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 25 Mar 2019 15:36:28 -0700
Message-ID: <CAPcyv4hG8WDhsWinXHYkReHKS6gdQ3gAHMcfVWvuP4c4SYBzXQ@mail.gmail.com>
Subject: Re: [RESEND 4/7] mm/gup: Add FOLL_LONGTERM capability to GUP fast
To: Ira Weiny <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Andrew Morton <akpm@linux-foundation.org>, 
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	"David S. Miller" <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Rich Felker <dalias@libc.org>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Ralf Baechle <ralf@linux-mips.org>, 
	James Hogan <jhogan@kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mips@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, 
	linux-rdma <linux-rdma@vger.kernel.org>, 
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 3:22 PM Ira Weiny <ira.weiny@intel.com> wrote:
[..]
> FWIW this thread is making me think my original patch which simply implemented
> get_user_pages_fast_longterm() would be more clear.  There is some evidence
> that the GUP API was trending that way (see get_user_pages_remote).  That seems
> wrong but I don't know how to ensure users don't specify the wrong flag.

What about just making the existing get_user_pages_longterm() have a
fast path option?

