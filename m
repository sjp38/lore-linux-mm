Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F91CC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 13:54:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D160520818
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 13:54:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="X2N1/pci"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D160520818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B2D86B000A; Thu, 11 Apr 2019 09:54:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 662EF6B000C; Thu, 11 Apr 2019 09:54:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 579026B000D; Thu, 11 Apr 2019 09:54:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 37F8F6B000A
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 09:54:50 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id z125so5507790itf.4
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 06:54:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=o/MsfMAHYzQWp2OC84o4NWsnGp91D9u3fiXBt7RZqIU=;
        b=gUyyxaAjNLdVBfeV7mbA25G1a7cZW/Q3IhAiYGDaabJltVlFmUWZnUfckK4mYIQs3j
         yqKhU6osrAznKhTTRnprQBnk5eDqaucBT5/cDL4r6FuAEpLLAhHQD7any4MSQ2zCvXaE
         Yip5+0KgNFramRMpgGHnD6e1W0gV3A+iclm1KvIr2lDg4zBVrKi3LFFDI3xi0fhwfuzC
         1NPIuMIohWF+bkmGXTEDMzx/fYOf5gcPUjzSRf2gGFRAjh/mtGsaqIGu9Iso13o70xMa
         /n9IqjZTFUD9VY3sZVADI9YbpCwEjJSFv32NYNDNvWy+ryxYJSoXoBY/VUEDl2Egsx90
         zLgw==
X-Gm-Message-State: APjAAAWxgyVVdqahOZm+3vHa4vOEJNy6Svxisx3dOTUZf2wuBUxv9Uqu
	eYc7Ft2swcaMHe0UN4EINblSCyBkpbeHbHJCEVNBdu9v1F1wuKzLKvk/QCp/FA99aJ8jQSrp+8Z
	C/eaAokklPPT58MCDAoEQpp0qaDxvp24iID2frtB3L3896jSF04R0v9G2IYzuOETCzg==
X-Received: by 2002:a05:660c:12d2:: with SMTP id k18mr7346914itd.33.1554990889964;
        Thu, 11 Apr 2019 06:54:49 -0700 (PDT)
X-Received: by 2002:a05:660c:12d2:: with SMTP id k18mr7346851itd.33.1554990888685;
        Thu, 11 Apr 2019 06:54:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554990888; cv=none;
        d=google.com; s=arc-20160816;
        b=o5ZbaXSK5Snz4eMF+Z6qBaf0QJKRxAFnWvuwrviReq61CaPNn8KUL9/CkVVRozOfwb
         CgK6M9yC6/DzYPU3WptT5y1cQkmxHBC/KyAC8ATHQ+b3d7ctPGxXeUT8zafJYfC7EXYk
         c3gWky2vC3NkLchILcud4F9rBbd3nwTCQjgrJRUUIAJQd6b8VzcA+X9CV7WEbYFGpDo7
         G8LL3/bxHXUH3j6WgsK3TyLxBMl/U0ULXYpXU2MVPB/E719Kk9F+DLgz01SUcmrvCTnL
         FZWi8blV6p9zMDxNLjS+pJD8AteMJ21ry0OraWGG+g3dy8W8xMbtLtRAG8kgCM8buDkw
         jV6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=o/MsfMAHYzQWp2OC84o4NWsnGp91D9u3fiXBt7RZqIU=;
        b=mWzvCgSyTIsmh5eGEuyAW9e75ijuHgwo0zViXB6uUZ43EKzBVLU75X59X8RS3m6iUZ
         S6ePAUVrgeOthTjpFMUAiZQnTih6JUZfuPTXy1WJP6eaYTeMTdvFsTJf7kyjVCGiIFTW
         yxK0Ez2p4UdTru+hQzzcKFS48NfvpIjbzdw2SYHjsHf2EM+qCkWABQb1tYCvixOY7CNQ
         2sEKS76k0EPPBryPITMy367RtuYYIAr5jVhhjVczflHW8XS+jqh5mRxhplysY4J/89So
         DUmq42h5J7knrgEFI3uT6hSj854lTk+cfzTgTp/p21wUf7bK6KEhN7z/z9sI3OffnkBO
         lrXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="X2N1/pci";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 69sor18342903jaa.7.2019.04.11.06.54.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 06:54:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="X2N1/pci";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=o/MsfMAHYzQWp2OC84o4NWsnGp91D9u3fiXBt7RZqIU=;
        b=X2N1/pcikngRHQm8TsVLovuqrPrUIr2YO1o2DU+zwZ8vn25R8xyQ2OsjGfV7WUnFv9
         sO+mEnOSZahcG8bBnPqQ9M6dgKqPnLnWZScq3m/SG/08PSKwgDA0QC29yAKm6+v02UEv
         wzEfdKineg48qG0J7swWOrhJisWvBqkz/Kgvf4GBb7HHwqQzw/EQpYtadKQKjJeALF9u
         BOquQGnsQTg/4LM6Fkc9pgx+5n1DDyW0u40XQSP3ilXVihTy2e2MLlRHwT6sAIvCYw6C
         0ane2VuXee4/rEkd83ip0qGdS8qOW38V9tV8HOak6xOvQdda8JxlEdTJa5v9tXXRkgDS
         2Gwg==
X-Google-Smtp-Source: APXvYqy2Vz+jjsQFCDER7RjMPsxrxpTcY59hFg15NcoNm73hcjmmQvdFsvW/NVIdimT/wZyVuByEpUStx01koENRbAs=
X-Received: by 2002:a02:c643:: with SMTP id k3mr35977638jan.19.1554990888457;
 Thu, 11 Apr 2019 06:54:48 -0700 (PDT)
MIME-Version: 1.0
References: <1554983991-16769-1-git-send-email-laoar.shao@gmail.com>
 <20190411122659.GW10383@dhcp22.suse.cz> <CALOAHbD7PwABb+OX=2JHzcTTLhv_-o8Wxk7hX-0+M5ZNUtokhA@mail.gmail.com>
 <20190411133300.GX10383@dhcp22.suse.cz>
In-Reply-To: <20190411133300.GX10383@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Thu, 11 Apr 2019 21:54:22 +0800
Message-ID: <CALOAHbBq8p63rxr5wGuZx5fv5bZ689A=wbioRn8RXfLYvbxCdw@mail.gmail.com>
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

On Thu, Apr 11, 2019 at 9:39 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 11-04-19 20:41:32, Yafang Shao wrote:
> > On Thu, Apr 11, 2019 at 8:27 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Thu 11-04-19 19:59:51, Yafang Shao wrote:
> > > > The current item 'pgscan' is for pages in the memcg,
> > > > which indicates how many pages owned by this memcg are scanned.
> > > > While these pages may not scanned by the taskes in this memcg, even for
> > > > PGSCAN_DIRECT.
> > > >
> > > > Sometimes we need an item to indicate whehter the tasks in this memcg
> > > > under memory pressure or not.
> > > > So this new item allocstall is added into memory.stat.
> > >
> > > We do have memcg events for that purpose and those can even tell whether
> > > the pressure is a result of high or hard limit. Why is this not
> > > sufficient?
> > >
> >
> > The MEMCG_HIGH and MEMCG_LOW may not be tiggered by the tasks in this
> > memcg neither.
> > They all reflect the memory status of a memcg, rather than tasks
> > activity in this memcg.
>
> I do not follow. Can you give me an example when does this matter? I

For example, the tasks in this memcg may encounter direct page reclaim
due to system memory pressure,
meaning it is stalling in page alloc slow path.
At the same time, maybe there's no memory pressure in this memcg, I
mean, it could succussfully charge memcg.


> thought it is more important to see that there is a reclaim activity
> for a specific memcg as you account for that memcg.
> If you want to see/measure a reclaim imposed latency on a task then
> the counter doesn't make so much sense as you have no way to match that
> to a task. We have tracepoints for that purpose.

By the way, I have submitted a patch for enhancement to the memcg
tracepoints serveral days ago,
pls. help take a look.

Thanks
Yafang

