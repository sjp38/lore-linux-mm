Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21869C10F13
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 01:33:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F72121721
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 01:33:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uFVBzBn/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F72121721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0666A6B0010; Thu, 11 Apr 2019 21:33:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 015E16B026A; Thu, 11 Apr 2019 21:33:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E47146B026B; Thu, 11 Apr 2019 21:33:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id C60D26B0010
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 21:33:50 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id s24so6472391ioe.17
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 18:33:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=afm2gQKQ9IeGQx2pSJdzpkAY9emExLqLGJxnADAziCM=;
        b=NVSZ1fkEzYGNdxFsMmtrHjzBeLDvniQt+xlweEJuaKjRNQyXK4x1aKT2zNNULzBc53
         jlKdEavvuzbdB0wC+V+KSD2Tb44+yYCF0CmBA7cqEQVINrIiQsB2+L7sQRNzVhKN4gIw
         bQtLrjERklRkUBbI9w2UWjusrIs/QYcB1/uYVkmox0+4lYUVG5p9bkBdlB/cthTpeGbp
         4a5WNW9/MJ2iH7v/Spx3+Eh1N0duC70wHQSmCevPNEH2Iiuu3KrLMEeAJPtgwGCUknOy
         QNTRi9hvrMa3B4DrLylueIW0oaUXynwJ5ATTEMG9b25DXy01Qfw6w4yMVjX01aKPoQLM
         9Lqg==
X-Gm-Message-State: APjAAAU83dEK+Or++lYlAOaWa6Ncb/+PA6UXNTnTOZD5fZNCJ9fnRwMS
	L8XEo32iPEXfLtR1iADbf7+NkhqB+AFGB+YbPH+fZe+yTK26vRsHSIz8MeiKTTgbLK2RSfDlvbC
	SWmhVaYbijEH3XtOQppmwULLRGade5mn9mAgDYsR8CpqaLv5f1obpdiB/yO92pYYZEg==
X-Received: by 2002:a05:660c:20e:: with SMTP id y14mr10996141itj.17.1555032830490;
        Thu, 11 Apr 2019 18:33:50 -0700 (PDT)
X-Received: by 2002:a05:660c:20e:: with SMTP id y14mr10995895itj.17.1555032823865;
        Thu, 11 Apr 2019 18:33:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555032823; cv=none;
        d=google.com; s=arc-20160816;
        b=mm0lkWr4bVNIlI43ayb/txp28i+nYQRG5MIjLOibFFc08ugCpBMG0uB942I4v0bg3V
         /Y+OQWYXLdUPliyA+gTD/3S3k73Go2qCpjw3OYgbI1GtSR2eVBQBR9O/WEaFhPWwHWGO
         sU/pcoj1Kcm5FAeGqxzbhrQdkq/PNGnkO7211dkQ9bPLTadOCVtOex5e7+BH7DwvFsmc
         6P2kuek7kB2VYIxziRJ5exA5t63ob5h6aubawgixqSQPc01DWfx21ezCT2LExahEhp1s
         oiN17qheUkoixei1f2rampjaW9ER8ZI+gOnHxgpjW7frfu6fdkUWe/3Ilgq8vl9f41Or
         6xaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=afm2gQKQ9IeGQx2pSJdzpkAY9emExLqLGJxnADAziCM=;
        b=u7HlcgRfmQCUyx+20oEGnf8Ep9EPsQcBkNf00RWG+Q0CzEKo7Rsk1wc9p72t3tRY9t
         vvdnxQz96llT2UztbuowGb5xGDvKG8xw8IdJVUyxDZ0yn/WCxNRUP2wiLzZNACrvG+3u
         ZhF5yp7XbuIlP2W96r3HJdOa/y5+VQxS50W7mZP4xtf2EQpbTLZaBNk0OtpWpNHwvOwy
         x7fgt9pa+Vouyf+3Y/h+AHKO9KDqvwMbLIXdo8WojfCMreQBDdnO/jsKMnwhbRMIGSRF
         0S4AiARTKPsAY48MGZfgisngOlh0LfovAVeuzRuJ3c2BJ9ZwpTIxabonXGcHKbc+pTxl
         14lg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="uFVBzBn/";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h76sor11952325ith.32.2019.04.11.18.33.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 18:33:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="uFVBzBn/";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=afm2gQKQ9IeGQx2pSJdzpkAY9emExLqLGJxnADAziCM=;
        b=uFVBzBn/XKsdSbFAr75R43re28oYkar9/dySYhidvvklad41ZAe6tINRSBE012k4Vi
         1Mo/faG0MOcHQdGY0KozwvZnsAp4IRqA9mUcwYc7cJ0z1BAi3hj5bN6x5yueg+8Bk0FF
         LHMzPWH4T4fC4j0wd5cHOAs937wk84PSrBp+qUgA9tscPdwWmTT0Yqfj6ro5pFnd8Gzs
         zNYDLNm4458mtYb6uKMxe8fXqKmw/sMYenDjpKkn9WZlJXJ7SLCNpQqpMnStN6xK94Gz
         KVBiEH5/VyD0C5ogMll20JGaiSiEjZNqfFVysaXTgWUVQVIaZYQEGPjJxK+yP0hRPqlh
         xq7A==
X-Google-Smtp-Source: APXvYqyM4TgUZuTHtz73x16s4ARd2g2xo8LP0SurIYdjBfzQc+moaQUywpruP697lVgxAfiXB7x7RIy5xcbwXet0Bi8=
X-Received: by 2002:a24:ba15:: with SMTP id p21mr9579383itf.66.1555032812298;
 Thu, 11 Apr 2019 18:33:32 -0700 (PDT)
MIME-Version: 1.0
References: <1554983991-16769-1-git-send-email-laoar.shao@gmail.com>
 <20190411122659.GW10383@dhcp22.suse.cz> <CALOAHbD7PwABb+OX=2JHzcTTLhv_-o8Wxk7hX-0+M5ZNUtokhA@mail.gmail.com>
 <20190411133300.GX10383@dhcp22.suse.cz> <CALOAHbBq8p63rxr5wGuZx5fv5bZ689A=wbioRn8RXfLYvbxCdw@mail.gmail.com>
 <20190411151039.GY10383@dhcp22.suse.cz>
In-Reply-To: <20190411151039.GY10383@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Fri, 12 Apr 2019 09:32:55 +0800
Message-ID: <CALOAHbBCGx-d-=Z0CdL+tzWRCCQ7Hd9CFqjMhLKbEofDfFpoMw@mail.gmail.com>
Subject: Re: [PATCH] mm/memcg: add allocstall to memory.stat
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>, 
	Andrew Morton <akpm@linux-foundation.org>, Cgroups <cgroups@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 11:10 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 11-04-19 21:54:22, Yafang Shao wrote:
> > On Thu, Apr 11, 2019 at 9:39 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Thu 11-04-19 20:41:32, Yafang Shao wrote:
> > > > On Thu, Apr 11, 2019 at 8:27 PM Michal Hocko <mhocko@kernel.org> wrote:
> > > > >
> > > > > On Thu 11-04-19 19:59:51, Yafang Shao wrote:
> > > > > > The current item 'pgscan' is for pages in the memcg,
> > > > > > which indicates how many pages owned by this memcg are scanned.
> > > > > > While these pages may not scanned by the taskes in this memcg, even for
> > > > > > PGSCAN_DIRECT.
> > > > > >
> > > > > > Sometimes we need an item to indicate whehter the tasks in this memcg
> > > > > > under memory pressure or not.
> > > > > > So this new item allocstall is added into memory.stat.
> > > > >
> > > > > We do have memcg events for that purpose and those can even tell whether
> > > > > the pressure is a result of high or hard limit. Why is this not
> > > > > sufficient?
> > > > >
> > > >
> > > > The MEMCG_HIGH and MEMCG_LOW may not be tiggered by the tasks in this
> > > > memcg neither.
> > > > They all reflect the memory status of a memcg, rather than tasks
> > > > activity in this memcg.
> > >
> > > I do not follow. Can you give me an example when does this matter? I
> >
> > For example, the tasks in this memcg may encounter direct page reclaim
> > due to system memory pressure,
> > meaning it is stalling in page alloc slow path.
> > At the same time, maybe there's no memory pressure in this memcg, I
> > mean, it could succussfully charge memcg.
>
> And that is exactly what those events aim for. They are measuring
> _where_ the memory pressure comes from.
>
> Can you please try to explain what do you want to achieve again?

To know the impact of this memory pressure.
The current events can tell us the source of this pressure, but can't
tell us the impact of this pressure.
The tracepoints are always off until we meet some issue and then turn it on;
while the event counter is more lightweight, and with it we can know
which memcg is suffering this pressure.

Thanks
Yafang

