Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54E3EC43381
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 07:54:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10BBA2084C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 07:54:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Jp+tSC8K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10BBA2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2FE56B026B; Tue,  2 Apr 2019 03:54:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9DE6F6B026C; Tue,  2 Apr 2019 03:54:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F4136B026D; Tue,  2 Apr 2019 03:54:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 704EE6B026B
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 03:54:46 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id a64so2087900ith.0
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 00:54:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=fVRLBEFJAHoY/K/5EzGGyJBatAKnecX/Sq5cGdSYc0s=;
        b=oG9KjYPoz5G/jkFd3GOo00FdihQM49fdLtQ91xF72fMU3tvtrng6GlSgIrFV69IjPF
         yiQfEVn5HcwU4BiIXybSovntShEEOuedFa9Euw3D9iBJ729IgGlobwHGzrgaenP0ALpX
         WR80pewhBP6/F9/iv6znOajDy/GvcGIXrBIdxidulNfktaTLzMDDMtV/GhStnKwMw/Yz
         joGu6p/2OtoY4onjXqyJKqlGQVEYCkGucZIYvf8ne0Q2TRFzjp6nFgq0sVhJRszWjQ/q
         ha4W6xArcB1Tz88O6cKgVVBAXwUWA0eL16vo9gsBUlUK3wdPrw2K0w71aAa71sPuloIA
         GUhQ==
X-Gm-Message-State: APjAAAWJ6g/9wmEJM7jYTXS/ZguhrJX5P811wQsQa/W2NRcgLCQW/pyb
	fJC3Y/CHI9t5p8+Xn7JJdYCUiqlnti3yQGty5VI3rjZOWG7dWcANNIKZMqfQnChSQnkVjnvbCJ+
	4FAvJlJd6PTaUhSVRLoz3ZbgG2XdQuufjuAusfjIm4bqlvevYfv0zFB0TQBMm6kxcTg==
X-Received: by 2002:a24:65c8:: with SMTP id u191mr1338061itb.137.1554191686132;
        Tue, 02 Apr 2019 00:54:46 -0700 (PDT)
X-Received: by 2002:a24:65c8:: with SMTP id u191mr1338045itb.137.1554191685550;
        Tue, 02 Apr 2019 00:54:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554191685; cv=none;
        d=google.com; s=arc-20160816;
        b=Drfh497y3GIBZiMfhelMobq7LxoFflXdDWr7LBJr3s7v7IFJ3M7FpqsDhqsIzDxKPw
         O4AENXCkzIUe1mkaUYViUszNCx/tevurySYeHGzrAgDNdSiuutDzQA6TOo4PSJ1rLtDB
         RH1+zVHKOaUu7j6yXNn4QMbNh3yuuiNrIoup5q/BL1ZqGZPJmR7PEOfy0deK9YqHsnQO
         mxNLXYWjq4eVTtnv49oyArzv4eRFi1n85g76dCDrkN71Iw76Ti25La/KgDvp2I0NaTlh
         ytkY4sn36clPdEGaKJfca2ChwOs8hdlVjEr0pPzJKlX1M9RqdszwSkF6cDwjdMG694PK
         M6qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fVRLBEFJAHoY/K/5EzGGyJBatAKnecX/Sq5cGdSYc0s=;
        b=QZrHWfBUiQGu26uExMF43OvVTIHxUQTFKGSYYDt+XJYdVOrwz7YhZ/JkIJWiS0rtVN
         PpYD98yItw8h14LTRlJBMi+SYtHneoMLD3gezUULExjuW+CLIFuW+zhL0ymO38HyZU4k
         d+wsxjQd/uCWx157PUAfoa6LUCmixhbViYuPme554eFGot50+G1ZRiMdGdh7QdxhxO0I
         ys4ZxSUByyl3G5L1KVyZHXy0dBBnHu+p3RE73/Lp5Cpl4gI3yhTBuf3ZLRDfzovrvaHs
         D2XslwJrNsM0ZF91N/UuRRMNGf1fd9YH0lmiEXFyDBuhRXN7RszXZPWisQVeY+fvaMmL
         0jYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Jp+tSC8K;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l22sor7708966iob.74.2019.04.02.00.54.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 00:54:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Jp+tSC8K;
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fVRLBEFJAHoY/K/5EzGGyJBatAKnecX/Sq5cGdSYc0s=;
        b=Jp+tSC8KXs59bN3V9va6En1vKRiMgE/EUonl64nULWgG61luh1ha6SbwdKCZEXepZN
         qoYb4rOUGISKgbtZWVsB+6xA3ivmiqMJkuEtqRIA9ArE9X5e/gCd8hLzsHdrRotPeS/e
         s0AJdIZ3gRN0FQU7xIXivtcY6zGmC8fpBedeHqHFu6V708FTKY/yAqjCuR1DF2SKKt7p
         Td7GviYLJOqlfkaojRwJpI6uBcJZQkOq/Tc6tUZ6vwD/z0O0ow40fO8rhH2BKxDpjQY8
         zwqTsJ0aHoyMTxvLjSII/8Vn5WTm4T0yiluWkS+1Gjd+tch2uJa4+r5RTbK4C53ITOqC
         ZB4Q==
X-Google-Smtp-Source: APXvYqzsGFuogadboqKMrmzXjrqwss0e7hgtnpNQeT6udYT4CHn1L2tGEFYr80gO3Ldd2aCl2+2o0G7K9NN1bZmZVqY=
X-Received: by 2002:a5d:8c98:: with SMTP id g24mr1243535ion.35.1554191685290;
 Tue, 02 Apr 2019 00:54:45 -0700 (PDT)
MIME-Version: 1.0
References: <1554185720-26404-1-git-send-email-laoar.shao@gmail.com>
 <20190402072351.GN28293@dhcp22.suse.cz> <CALOAHbASRo1xdkG62K3sAAYbApD5yTt6GEnCAZo1ZSop=ORj6w@mail.gmail.com>
 <20190402074459.GP28293@dhcp22.suse.cz>
In-Reply-To: <20190402074459.GP28293@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 2 Apr 2019 15:54:09 +0800
Message-ID: <CALOAHbBs4MJhJKg2dLF91TeKgr5s6Z91TgMJXLH+66ZBqbS4hA@mail.gmail.com>
Subject: Re: [PATCH] mm: add vm event for page cache miss
To: Michal Hocko <mhocko@suse.com>
Cc: willy@infradead.org, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, 
	Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 2, 2019 at 3:45 PM Michal Hocko <mhocko@suse.com> wrote:
>
> On Tue 02-04-19 15:38:02, Yafang Shao wrote:
> > On Tue, Apr 2, 2019 at 3:23 PM Michal Hocko <mhocko@suse.com> wrote:
> > >
> > > On Tue 02-04-19 14:15:20, Yafang Shao wrote:
> > > > We found that some latency spike was caused by page cache miss on our
> > > > database server.
> > > > So we decide to measure the page cache miss.
> > > > Currently the kernel is lack of this facility for measuring it.
> > >
> > > What are you going to use this information for?
> > >
> >
> > With this counter, we can monitor pgcachemiss per second and this can
> > give us some informaton that
> > whether the database performance issue is releated with pgcachemiss.
> > For example, if this value increase suddently, it always cause latency spike.
> >
> > What's more, I also want to measure how long this page cache miss may cause,
> > but this seems more complex to implement.
>
> Aren't tracepoints a better fit with this usecase? You not only get the
> count of misses but also the latency. Btw. latency might be caused also
> for the minor fault when you hit lock contention.
> >

I have think about tracepoints before, the reason why I don't choose
it is that the implementation is a little more complex.
I will rethinking it.

> >
> > > > This patch introduces a new vm counter PGCACHEMISS for this purpose.
> > > > This counter will be incremented in bellow scenario,
> > > > - page cache miss in generic file read routine
> > > > - read access page cache miss in mmap
> > > > - read access page cache miss in swapin
> > > >
> > > > NB, readahead routine is not counted because it won't stall the
> > > > application directly.
> > >
> > > Doesn't this partially open the side channel we have closed for mincore
> > > just recently?
> > >
> >
> > Seems I missed this dicussion.
> > Could you pls. give a reference to it?
>
> The long thread starts here http://lkml.kernel.org/r/nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm
> --
> Michal Hocko
> SUSE Labs

