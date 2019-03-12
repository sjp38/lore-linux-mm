Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23FACC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 08:33:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0368214AF
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 08:33:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="c9Pw/BUG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0368214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 680DB8E0003; Tue, 12 Mar 2019 04:33:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 630CB8E0002; Tue, 12 Mar 2019 04:33:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 546D98E0003; Tue, 12 Mar 2019 04:33:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 350E98E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 04:33:57 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id p143so1255841iod.19
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 01:33:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=YEwima1en/rfu+xXGp5+7DOkwf9kFR3V4q3sCPOcFD8=;
        b=HrmXYZEjv5D3cKXjigqEeTV5GlFu1HOIDup3ObCwgizoDOxEztgcw25Rv/XuYfmi52
         XtqG7zxQgnjw+2Ctnl6pbh5mGCD572AsZ6d7LIZebNpttP2OOTpK2LDdmOy9Vg7eMx9H
         4W/naQ8wVhu+jKyP1Par8AA/iM1jw2r1NzJO9/QTPhLz18eP1QBDDHcNv92QGZMiL6GB
         de5Mfsw77Br5c7OWvtlsN3UOAocUMUkBfCRg22IXq5NJcYADFo9uPCLgZw9K810mMsO9
         z2hXEBKmhgpD4cmiAh/YJHoneyRJpibJwYjUlmNYzDhlrkLWvfZ4ZcAXePhEFnoohnxR
         gqsw==
X-Gm-Message-State: APjAAAW12Tg9ClbTFhz+VufqzBn0Uc/WUS9uF/zw5MFiM7OoVFF10br3
	nMhqKzqwpELf0yzo6no/GsFuODN/J+fR/YQVUdfji3+ZG2S/VfZEKpLkRHwpqIMR8pbPUVPjvlv
	IZ/Zr3Yc6iV+ezX+TNNXK+sB6WK8cWjngHRz76w0TM2PUJQ4i72VOWBw9q4LI8hZcJp4T+Yc/mS
	RT8exmpzojn34HSU0TBOYogcgITmmu3ktLIf0YKWF4HwORbCKZe1RxiNPrb7VbYkbSIyJD4REge
	ff5qa9c70ACLXFA3m70dPSZANAFevdN8d7Ofdp60s8Xj3vEhKbHf37iomADXV6MIl0Pk8sN62O1
	hfzYW0tAHTspRbUntjgWunsjXQuZ5iC0hKoidPwomzyoVPW9bF/RhAFB7kCLgYtj0me+UDfcAKk
	J
X-Received: by 2002:a02:6a0b:: with SMTP id l11mr20653238jac.138.1552379636872;
        Tue, 12 Mar 2019 01:33:56 -0700 (PDT)
X-Received: by 2002:a02:6a0b:: with SMTP id l11mr20653208jac.138.1552379635800;
        Tue, 12 Mar 2019 01:33:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552379635; cv=none;
        d=google.com; s=arc-20160816;
        b=zXSzbnA/WHKVlMTtKMeIilQRl4xNbd9E0HKj2Loy5uSHPZ+wxoL2+PK4DULYxE9kiK
         Bna85ZRiab0lutCujS+l71VLqpycZ+89ZbR04qOefUCTanroEgEHiEB6lKdvzy/uekyC
         MhGsARY2+SR8sIU78E9v4FbvnitrBVyiESVdyivHWeJZTqjnzTzAjAa9VVrjd/dTkJKI
         YMfZdYx2rIoV0zLyav8lGfc5C0wBVeIjaC5BM3I83F7e0+/DWHMWPx06TOgnadxs1YgG
         7bM1hyh04qOqp7SYw9ilU7lEKYZBm665pwWNAbwBcvzfKkL6YYtzsBL8FRxN0d08dePc
         6DWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=YEwima1en/rfu+xXGp5+7DOkwf9kFR3V4q3sCPOcFD8=;
        b=Lx50A/g95PK/mYMo7ew5PxXutBnlUKS0jskTcxVC3NiaA1A9wlnkellpIwTwCrzGBb
         O4Bb07Q1m2SIYh8Mq9FEPVEaaGiX6S7FbmxVaTkxJQnkK6NDft8/xMrmIvV2nSv0yoVv
         yFBzogpT28vmiHtvJ74kKyaMbHbR8Vuw49tDDm856l1TS5wTZAErHo6ts3xBgD3aRb2q
         GG7iWqMfsaVPgMv23ni3ETm8358LlfCp70G1WhloA3SFNmzXR5LRy6xpuY30WB2NPW58
         a8lkL+wZHwEdJR+fL3zS13qRK2aZlj+5CQhJN87uYiShMDCs0NFkECkFv3Z8nmCEt4pL
         J8kg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="c9Pw/BUG";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w134sor2598063ita.20.2019.03.12.01.33.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 01:33:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="c9Pw/BUG";
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=YEwima1en/rfu+xXGp5+7DOkwf9kFR3V4q3sCPOcFD8=;
        b=c9Pw/BUG7U//keB9Pw5lBa8+1Z3vltXWSdu4JBopTK8zz/JzXbBlYeMcsE03jV8oYC
         Rt7otQygDIxmuFhLmwO9tTAeWfmY2v1aBP8iYmTI1vo4eKRvpVBvcs/o+szG5FiWmSLT
         pONVm/WI66XmyqqVl9JEgJvyDFvfdq1WwCW4pGYM1JR6EsqzVM20FGlP1Ag5ODFbXxzW
         XKk3NouSp7CJJL+3aPU7SdJeT2dBDe6tf2D0dNg3cEZZWu0EBoEoKq/tkb5wG3sfX0Yi
         k4KPHztiOfASHaIPzLM0hfkKqlkNwlyrzb3n5+dVtiPTWy5hITyxFqWCcNuQLbgyQZne
         ZLBQ==
X-Google-Smtp-Source: APXvYqxKEJf9RgxTt4vArvuAtmJwEnVIju6+HZA5skOqNJpHjFOfEsNcpPA4S78uoFojK+BzehMs+pNqS6M3/fWMKiY=
X-Received: by 2002:a24:674a:: with SMTP id u71mr1441667itc.12.1552379635236;
 Tue, 12 Mar 2019 01:33:55 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000001fd5780583d1433f@google.com> <20190311163747.f56cceebd9c2661e4519bdfc@linux-foundation.org>
 <CACT4Y+byKQSOCte3JS9XOnyr+aVSEFtBvLxG2-HUrZX3-82Hcg@mail.gmail.com> <20190311232541.db8571d2e3e0ca636785f31f@linux-foundation.org>
In-Reply-To: <20190311232541.db8571d2e3e0ca636785f31f@linux-foundation.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 12 Mar 2019 09:33:44 +0100
Message-ID: <CACT4Y+Y0JdB-=yLLchw8icokn11iH2-XYoLJEOFKm6F88fJ3WQ@mail.gmail.com>
Subject: Re: KASAN: null-ptr-deref Read in reclaim_high
To: Andrew Morton <akpm@linux-foundation.org>
Cc: syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com>, 
	cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, Shakeel Butt <shakeelb@google.com>, 
	syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 7:25 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Tue, 12 Mar 2019 07:08:38 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:
>
> > On Tue, Mar 12, 2019 at 12:37 AM Andrew Morton
> > <akpm@linux-foundation.org> wrote:
> > >
> > > On Mon, 11 Mar 2019 06:08:01 -0700 syzbot <syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com> wrote:
> > >
> > > > syzbot has bisected this bug to:
> > > >
> > > > commit 29a4b8e275d1f10c51c7891362877ef6cffae9e7
> > > > Author: Shakeel Butt <shakeelb@google.com>
> > > > Date:   Wed Jan 9 22:02:21 2019 +0000
> > > >
> > > >      memcg: schedule high reclaim for remote memcgs on high_work
> > > >
> > > > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=155bf5db200000
> > > > start commit:   29a4b8e2 memcg: schedule high reclaim for remote memcgs on..
> > > > git tree:       linux-next
> > > > final crash:    https://syzkaller.appspot.com/x/report.txt?x=175bf5db200000
> > > > console output: https://syzkaller.appspot.com/x/log.txt?x=135bf5db200000
> > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=611f89e5b6868db
> > > > dashboard link: https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a
> > > > userspace arch: amd64
> > > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=14259017400000
> > > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=141630a0c00000
> > > >
> > > > Reported-by: syzbot+fa11f9da42b46cea3b4a@syzkaller.appspotmail.com
> > > > Fixes: 29a4b8e2 ("memcg: schedule high reclaim for remote memcgs on
> > > > high_work")
> > >
> > > The following patch
> > > memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
> > > might have fixed this.  Was it applied?
> >
> > Hi Andrew,
> >
> > You mean if the patch was applied during the bisection?
> > No, it wasn't. Bisection is very specifically done on the same tree
> > where the bug was hit. There are already too many factors that make
> > the result flaky/wrong/inconclusive without changing the tree state.
> > Now, if syzbot would know about any pending fix for this bug, then it
> > would not do the bisection at all. But it have not seen any patch in
> > upstream/linux-next with the Reported-by tag, nor it received any syz
> > fix commands for this bugs. Should have been it aware of the fix? How?
>
> memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch was
> added to linux-next on Jan 10.  I take it that this bug was hit when
> testing the entire linux-next tree, so we can assume that
> memcg-schedule-high-reclaim-for-remote-memcgs-on-high_work-v3.patch
> does not fix it, correct?
> In which case, over to Shakeel!

Jan 10 is exactly when this bug was reported:
https://groups.google.com/forum/#!msg/syzkaller-bugs/5YkhNUg2PFY/4-B5M7bDCAAJ
https://syzkaller.appspot.com/bug?extid=fa11f9da42b46cea3b4a

We don't know if that patch fixed the bug or not because nobody tested
the reproducer with that patch.

It seems that the problem here is that nobody associated the fix with
the bug report. So people looking at open bug reports will spend time
again and again debugging this just to find that this was fixed months
ago. syzbot also doesn't have a chance to realize that this is fixed
and bisection is not necessary anymore. It also won't confirm/disprove
that the fix actually fixes the bug because even if the crash will
continue to happen it will look like the old crash just continues to
happen, so nothing to notify about.

Associating fixes with bug reports solves all these problems for
humans and bots.

