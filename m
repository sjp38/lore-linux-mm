Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D92ECC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 15:44:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D01F278CE
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 15:44:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="FeiRgswe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D01F278CE
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1724B6B000D; Mon,  3 Jun 2019 11:44:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 123E96B000E; Mon,  3 Jun 2019 11:44:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2C226B0010; Mon,  3 Jun 2019 11:44:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id C9B1F6B000D
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 11:44:12 -0400 (EDT)
Received: by mail-vs1-f71.google.com with SMTP id r18so5227556vsk.5
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 08:44:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Pxr2tsBIRKskeHWPSwMDss/AepFRvbtFu+kFFRUCb+Q=;
        b=ieXRdNA564qKcL9Fd3hIjSfDMnLqFg4Viu9/Yo8ZRwUWkpZrfqavbug4Mormk3Byai
         jU7+ycTAbXSTM1dRyEWeBdgmece94GutB47ng0ax2/Nq//eJdJptUMRy8MsPqVCf+9z6
         3h5Qulwjr+iQZRK440GATMsvUSu+sSuGdW4G4QyKFmd/fwP3YSddMGIYYh51sZr1chGS
         g1xNGeyXdKcKNDcpdFrh2eQ84DthfDHs9oDTOnoXg2Cdbw4bBqtNoa1lT9RhycSa4xht
         OuMMA9Kv2XhEVrahsB9loMx8n86QwvqKtLt6HaRNw7OaGSx8tb79PXRPcFC+PyGi45fI
         19aQ==
X-Gm-Message-State: APjAAAVHXgfSrBiCvn9VXqBlpMVFcQr7ZidKbEKtAkfNUwLe/G8DLfTZ
	OAiC7hcBbHh3MqFaF1VZKGNCShWDMNHitTWTwYahn9vEpeEWvaflPS5hWZ1xPNi07XBJnXbqD0u
	NHM5j4ENdhxpCb6e+WggwdqOaVqhbz3i5gp1aRP2Tlph+XjG8gBCFZDR6YEZQmQRzTA==
X-Received: by 2002:a67:1585:: with SMTP id 127mr6340148vsv.162.1559576652497;
        Mon, 03 Jun 2019 08:44:12 -0700 (PDT)
X-Received: by 2002:a67:1585:: with SMTP id 127mr6340128vsv.162.1559576651841;
        Mon, 03 Jun 2019 08:44:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559576651; cv=none;
        d=google.com; s=arc-20160816;
        b=y//QFIzNl8jSx9odxaQOAqvlBzT3UMz5I7ZpzAK/i8s9kSSCSr1W2zTy11vPrDl+gl
         lRCgBlSouT65QaqinILirmKCz1BdZEx1DLhIPbMTj63ZN/qqk8n+TPmbp4QSFK+qLeUa
         jEi2yNKtzn5g0SCUI6u2HCNutrUFVdO7huGvFR7+hBepjGD0H2dvuMk31aUox7PcEqp2
         Ap8EJgwpStkBj5l3LV0+qdZ20iiTg48m/w102BxpbKvozjhIkAOU1XPdB2RI8Fl4xMyJ
         W0eJNdP1OdgMCX/j9Nhq+ABS8zj0m4YkkryJYMxuHdxBMMn0u0oYZhH1A4fAdYW9H5xf
         tgNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Pxr2tsBIRKskeHWPSwMDss/AepFRvbtFu+kFFRUCb+Q=;
        b=zfNBqHfquWtNHV5pf8gRDEPwwXtyoZOgEWBCz75vD3R3udOJkMFaO2la6qPdYQuzZf
         ax3mLxkP0H3BZgZBWMoIsoZs3ogZzZUQSg3jRnvEqQ0o4Eu4ic4fwwbLcu21tmJQ8NQt
         muzLwkkfBlQyGVRqWQIKpEDmklCJ3zhRq/m7LfN1SnMAgZAHoNnmiFehucfpm2K7lTYI
         amoJ5KU3eGrxneDzxYS76w0gPKTzQOgdUJUXr1FeAaIomdlFRxfW7j8cRJQBwwydRJqo
         /fie0tSWgoiVpdmCSRz8WjkhOujsMExNZlQ9S50QJMASRH69ixM/X0Oo+4iBGxRErziK
         ogqg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FeiRgswe;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f22sor1073508uao.34.2019.06.03.08.44.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 08:44:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=FeiRgswe;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Pxr2tsBIRKskeHWPSwMDss/AepFRvbtFu+kFFRUCb+Q=;
        b=FeiRgsweRwTNxjLQEZKDRVMSsebGvhERPWsd1c7KGoMTjJVDnHHl1PLX97BQ+pii77
         hXtgyY75bU/8TkqS3pgzN5I5hTHdt4eK7NIYTXesu+y8UAKBHgjB0t9mjdZt3w+naCKT
         rM9EkwPnii6j9iaJgVUuZV9kmbIImg2XC97jJMlaEswKCY5ECylPsSlPW/geZgkeQ6uC
         dSkTIW8/omAz6+vXCb/USUR0sqDwhsiGnB6pp2PyqiyEsckbAVuvNkDzmpDyALKbtt/p
         PfvvZJYgSqX83KJQk1Sl9u3JzNGJUxILFZ7nxCKabg0SZXDzVVCf5/7Tg4QlIB3fGbEx
         ZYCw==
X-Google-Smtp-Source: APXvYqzC/biQeMQwwnleohw9UkPA9qCfiYB7Q+NAS71L23R0SboHrt/PF2NrayEW15/9pMefLmUdej7+yCs2uAGXatU=
X-Received: by 2002:ab0:6198:: with SMTP id h24mr3159945uan.41.1559576651190;
 Mon, 03 Jun 2019 08:44:11 -0700 (PDT)
MIME-Version: 1.0
References: <20190531064313.193437-1-minchan@kernel.org> <20190531064313.193437-2-minchan@kernel.org>
 <20190531084752.GI6896@dhcp22.suse.cz> <20190531133904.GC195463@google.com>
 <20190531140332.GT6896@dhcp22.suse.cz> <20190531143407.GB216592@google.com> <20190603071607.GB4531@dhcp22.suse.cz>
In-Reply-To: <20190603071607.GB4531@dhcp22.suse.cz>
From: Daniel Colascione <dancol@google.com>
Date: Mon, 3 Jun 2019 08:43:59 -0700
Message-ID: <CAKOZuetW1UsPP3fDm-zTBOiO_oWkkDwADu+Apy53abWNs-UcUA@mail.gmail.com>
Subject: Re: [RFCv2 1/6] mm: introduce MADV_COLD
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux API <linux-api@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, 
	Tim Murray <timmurray@google.com>, Joel Fernandes <joel@joelfernandes.org>, 
	Suren Baghdasaryan <surenb@google.com>, Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>, 
	Brian Geffon <bgeffon@google.com>, Jann Horn <jannh@google.com>, Oleg Nesterov <oleg@redhat.com>, 
	Christian Brauner <christian@brauner.io>, oleksandr@redhat.com, hdanton@sina.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 3, 2019 at 12:16 AM Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 31-05-19 23:34:07, Minchan Kim wrote:
> > On Fri, May 31, 2019 at 04:03:32PM +0200, Michal Hocko wrote:
> > > On Fri 31-05-19 22:39:04, Minchan Kim wrote:
> > > > On Fri, May 31, 2019 at 10:47:52AM +0200, Michal Hocko wrote:
> > > > > On Fri 31-05-19 15:43:08, Minchan Kim wrote:
> > > > > > When a process expects no accesses to a certain memory range, it could
> > > > > > give a hint to kernel that the pages can be reclaimed when memory pressure
> > > > > > happens but data should be preserved for future use.  This could reduce
> > > > > > workingset eviction so it ends up increasing performance.
> > > > > >
> > > > > > This patch introduces the new MADV_COLD hint to madvise(2) syscall.
> > > > > > MADV_COLD can be used by a process to mark a memory range as not expected
> > > > > > to be used in the near future. The hint can help kernel in deciding which
> > > > > > pages to evict early during memory pressure.
> > > > > >
> > > > > > Internally, it works via deactivating pages from active list to inactive's
> > > > > > head if the page is private because inactive list could be full of
> > > > > > used-once pages which are first candidate for the reclaiming and that's a
> > > > > > reason why MADV_FREE move pages to head of inactive LRU list. Therefore,
> > > > > > if the memory pressure happens, they will be reclaimed earlier than other
> > > > > > active pages unless there is no access until the time.
> > > > >
> > > > > [I am intentionally not looking at the implementation because below
> > > > > points should be clear from the changelog - sorry about nagging ;)]
> > > > >
> > > > > What kind of pages can be deactivated? Anonymous/File backed.
> > > > > Private/shared? If shared, are there any restrictions?
> > > >
> > > > Both file and private pages could be deactived from each active LRU
> > > > to each inactive LRU if the page has one map_count. In other words,
> > > >
> > > >     if (page_mapcount(page) <= 1)
> > > >         deactivate_page(page);
> > >
> > > Why do we restrict to pages that are single mapped?
> >
> > Because page table in one of process shared the page would have access bit
> > so finally we couldn't reclaim the page. The more process it is shared,
> > the more fail to reclaim.
>
> So what? In other words why should it be restricted solely based on the
> map count. I can see a reason to restrict based on the access
> permissions because we do not want to simplify all sorts of side channel
> attacks but memory reclaim is capable of reclaiming shared pages and so
> far I haven't heard any sound argument why madvise should skip those.
> Again if there are any reasons, then document them in the changelog.

Whether to reclaim shared pages is a policy decision best left to
userland, IMHO.

