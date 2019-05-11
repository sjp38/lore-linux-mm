Return-Path: <SRS0=ybLw=TL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04828C46470
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 04:10:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B93E9217F9
	for <linux-mm@archiver.kernel.org>; Sat, 11 May 2019 04:10:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WrAicx2d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B93E9217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54D5A6B0006; Sat, 11 May 2019 00:10:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D4E36B0007; Sat, 11 May 2019 00:10:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C4076B0008; Sat, 11 May 2019 00:10:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 18DCE6B0006
	for <linux-mm@kvack.org>; Sat, 11 May 2019 00:10:06 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id y62so7085639itd.6
        for <linux-mm@kvack.org>; Fri, 10 May 2019 21:10:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=gZ9xWFVonfSWOeedDrbddVsWW/90+f1Lep6wrJrzXd0=;
        b=AzFLtpBWp0A/82vHHQD4wZ2Ira+oIIeY0WgxePSbZy9VTFPsBDveZhlsKLWkXgQFbU
         C55PA/HfzGMk1nleIj5g2xcK8CmiQgfc+VOpoM/BudmdwswWURKZzL1V2IrM+/wceSp5
         c+QvXrYur1AZqEsFow2AKUSSlrYIfp0wmOwjwd75SrKV7nKTkT/JMm/BbDyXgw3T4ctv
         YUAgO2ZjO0AJ8/tw6vzFAbgr3FmlLom7ld8rWp8WEScHONmVES+9Nawi3i1tdjkjDsLm
         TCmJLbM2vzui+KBEXuVkz7HdSaMqqsBLiInZBwdaCkL9YiKC4bvlYW0n0G3F6GTBJUv7
         jiDw==
X-Gm-Message-State: APjAAAXHi6ApuVlB3BfJCg4ZZ6hEn8Xw3PJa05gBojY5Bz/2u7r+mHGQ
	EPYvHfn1SyairfCxHSfPimrrcH/s60yIIxCNySIJZHCetWjf3iMXRL4aYc2cusEmnrKbfUKbJU0
	NwBpmnZY61por6wwmx76TT38ON+aHb2AXeCDMemUtqyWS4bJnrPtD7wSQfXDmaHlovA==
X-Received: by 2002:a5e:df4a:: with SMTP id g10mr8631701ioq.94.1557547805871;
        Fri, 10 May 2019 21:10:05 -0700 (PDT)
X-Received: by 2002:a5e:df4a:: with SMTP id g10mr8631677ioq.94.1557547804763;
        Fri, 10 May 2019 21:10:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557547804; cv=none;
        d=google.com; s=arc-20160816;
        b=SXmW7UrhGe3vd0vmhL2OAXVYKBuWxCgrq+osA5QyHevnhxPDMJBJI+/FtV2BY5T3tA
         29naVnYUxTwDJtZlxntZZEs638B74zBdDK/TqmbCCBEYyj/fw+sslQM+wxc6xGmYSIsV
         ouPYxu1sJtM5jJd7rIY5IknDUBOH3QoRJ7/crhJ5gSZN7CkFTEEUSxJi8i6YIAAxsJyk
         Dir0nVTe3n5o2kPVxunzvI8QChFeTaD2ro+Tujb1TRXXKd+FdXryOMhi+VzAIrcxOGFS
         HOSaorIxewn1X8ZZVTdfBQD3qhVWsT80ETANplimEhOlqrDGsswKeRZxOBXMQOluvxiF
         PSZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=gZ9xWFVonfSWOeedDrbddVsWW/90+f1Lep6wrJrzXd0=;
        b=zQK/jn1fUS9Q5L90d3DkH+z1tRwi22b0qp+QDSOyI5H1Pqfb7mQkDDOOIvBWfTK9gy
         QKLesEDio48HqRmRSgvUqbFqiyTIef7WrnpOIPLuakYzwF/t+7hRl/2yEWcZ9SU3/cLF
         z8nqrX+pKt68y96LL2MccTTGZmLXxxFMQyETvbucQbCTAxGLqvmW748YDw2e2P265Nod
         rDzr6nOkmzeJaIipdq08XGCi0HvwjhNecNTvehZRxQF6rL1btoFRFxjde0xk2LZ1MC0H
         NUm79QUyd4c8TG7CzAzbn/CE5+m4hngXF25OmtXTviwzUzAwzBk3V1UAiqQsJmdfafuB
         SOtg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WrAicx2d;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o129sor10226688ito.24.2019.05.10.21.10.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 May 2019 21:10:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=WrAicx2d;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gZ9xWFVonfSWOeedDrbddVsWW/90+f1Lep6wrJrzXd0=;
        b=WrAicx2dt3Kys4ZYx+qN0emWJsBCRP2UnXTZ1rKAJnnJneTbFYRGkUE4WTQqRD3/Aw
         PKc574CF0CRTgg7H/cUEyduqP1yFUo57zU6bA3SpbmjMe+ieCD5G9v+xU8tfuLXFdwmw
         TQQRqx4LLb1x+G3kPRU7oxP2+x0abm10LsagTGk8xckv//ReuD4GzYydxOrofns9Ho77
         OBgz/aU8aYNlnN1436QtZcwQ3BRZybsebzcTSf/SPVsZkxWVSJM71gq1Eggqu511xgAj
         DbYr1DUEy/GJFuNLzDp3hTzExQy3WN0V1FD4iQg3SorQVmsyXqRp8RRMP1NBxWrwzSsJ
         u//A==
X-Google-Smtp-Source: APXvYqziJYNnx3s7eyc0jYQpIwUY5Kf5xtPUTCHayN9C7SLhdHdv/v73C1zpUDCgiajORqxAfR+jkL+1cxrZnaCd4OE=
X-Received: by 2002:a24:9f86:: with SMTP id c128mr9519107ite.154.1557547804563;
 Fri, 10 May 2019 21:10:04 -0700 (PDT)
MIME-Version: 1.0
References: <1557447392-61607-1-git-send-email-yang.shi@linux.alibaba.com>
 <87y33fjbvr.fsf@yhuang-dev.intel.com> <20190510163612.GA23417@bombadil.infradead.org>
In-Reply-To: <20190510163612.GA23417@bombadil.infradead.org>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Sat, 11 May 2019 12:09:57 +0800
Message-ID: <CALOAHbCs62ynCEeTqAr7wx2TerFmK1ZBp_9r5jh-oP36tGMXDg@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: correct nr_reclaimed for THP
To: Matthew Wilcox <willy@infradead.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Yang Shi <yang.shi@linux.alibaba.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, mgorman@techsingularity.net, 
	kirill.shutemov@linux.intel.com, Hugh Dickins <hughd@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, May 11, 2019 at 12:36 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Fri, May 10, 2019 at 10:12:40AM +0800, Huang, Ying wrote:
> > > +           nr_reclaimed += (1 << compound_order(page));
> >
> > How about to change this to
> >
> >
> >         nr_reclaimed += hpage_nr_pages(page);
>
> Please don't.  That embeds the knowledge that we can only swap out either
> normal pages or THP sized pages.

Agreed.
compound_order() is more general than hpage_nr_pages().
It seems to me that hpage_nr_pages() is a little  abuse in lots of places.

Thanks
Yafang

