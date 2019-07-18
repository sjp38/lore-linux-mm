Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C566AC7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:49:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84EF1208C0
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 20:49:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84EF1208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F7F48E0005; Thu, 18 Jul 2019 16:49:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 281A78E0001; Thu, 18 Jul 2019 16:49:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FAE08E0005; Thu, 18 Jul 2019 16:49:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA0B88E0001
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 16:49:13 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id x22so7359841vsj.1
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 13:49:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=o9fAs0BIsCht32ONx/0UXcxnVez5wwFBCFk4BBkFPO8=;
        b=FqjZPskvc6/wkTB0Ahf3glp2m7FL5GLEpNlE5GhkOstY6z3rqTqkOe8tFTEnW2B3+F
         Djn83UIlMeYgpyUXmoFtwH9boiXbadlMARNjEILxCGJRmY7hKSDxkAEEF0SyuvUvaw07
         gGLcmQ6ZmDakL7QI+8i9pg7Cnx2SmmP46BxAujByYVjuHSW6C/BCW5DgqF4AkqjwygLS
         7BNAAgEf1q6gMV6ZHLewIzZOR7RZttKNph1S6Tbr5czTSt3Pwb+ocyO1CHZiD3UGBgTO
         9ojHbJzIWqelqNa2W3LGLsjaXFMgxA7p3q1/pnI+6sc1pVYVULcc/RPitJVpMytEYeLM
         0xmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVZitExjJ1ugMOJXtPTTP61gYmbLv8MUDZR+JyHIbJ0SMR52BI9
	HtMgwJOwY/GyHR/99uXD3q6W7tu4gZxyi2TLqvelCoQvALk4dHMQP5Zmfl03gWFxXRchmQWjl37
	HWveJUnosmLR+715Xn6p0KL9CHXRzii3WPGypVWOne/eIGl/aEOo/Lw6mIl8xvhdLfg==
X-Received: by 2002:a67:d590:: with SMTP id m16mr31040354vsj.76.1563482953658;
        Thu, 18 Jul 2019 13:49:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7LZP0aOTjZWhbulisUl8ZKk7isOkBP1gRhWOg0/6wudjk6LYVlRiCUoc5MnluR3LuN3nR
X-Received: by 2002:a67:d590:: with SMTP id m16mr31040322vsj.76.1563482953130;
        Thu, 18 Jul 2019 13:49:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563482953; cv=none;
        d=google.com; s=arc-20160816;
        b=LHGEoJM8ZmVyzcwyNVc3UG+U5XVTcV0/PhN3w6cF97ZuxzSYVCwr5iGltEZyV5oFCc
         N5PQnRJLfu221D5LmYM3V6/+oSEG/jv4Me8mYp3f7ihvQe1qpmSmHVAzdQ9ZRpsx9c7r
         o5BNzj5XAiqG4r3rA1Noxt+/Fn90Fy2Ye/L/TwuuSyjUy+Ha69Hms4WmQ0OJ5ROJbTr9
         aatR3GzPmtKLIDcRJx1RSriUEbA7GhIu/d6t/WHa6t/XFrIkYAjT3jjStm/thAaXBbAT
         hq5JIB3a1AZSg5G7ou5HJCJ/kpAz7a5V5h8txoiC9ZhPGk6nDbH+/XSaixctbixzEjQv
         Xtcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=o9fAs0BIsCht32ONx/0UXcxnVez5wwFBCFk4BBkFPO8=;
        b=S/AW2B/xzysXirLkzIkhRprQhn7lv7OERhe6sbmmtem4yttO+3nHIB1XE2kzm0i+Ak
         DvpPl/9bKqcxyh09CFadf7BOcNy9lAcCYD/EHi9s2lnr8vHnfcVJuF562wHW6YQ5hT+k
         EqYaHAePuclspkuNMgR+RBLZATGdWd5AJwe8IHGjkSpCWIZCgaRtRlZ6kuICyQZ/UO5J
         458qdvfX3BxQ2asRps058SRGG2My5hry926TqdVrd0x9HzuU1g4Pb5vWzO3dQxLmAvw8
         05WveFi675N6r4ciDBOKDKNuaenrzbENf8JxbiXFjtY1C8lVgs0zWjdvATlhUVCzLEOs
         cyhg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x18si480134uap.102.2019.07.18.13.49.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 13:49:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 40A2230B8E03;
	Thu, 18 Jul 2019 20:49:12 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id D4D7F19D7A;
	Thu, 18 Jul 2019 20:48:57 +0000 (UTC)
Date: Thu, 18 Jul 2019 16:48:56 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>,
	Dave Hansen <dave.hansen@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com,
	Rik van Riel <riel@surriel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	lcapitulino@redhat.com, wei.w.wang@intel.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Subject: Re: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
Message-ID: <20190718164656-mutt-send-email-mst@kernel.org>
References: <20190716115535-mutt-send-email-mst@kernel.org>
 <CAKgT0Ud47-cWu9VnAAD_Q2Fjia5gaWCz_L9HUF6PBhbugv6tCQ@mail.gmail.com>
 <20190716125845-mutt-send-email-mst@kernel.org>
 <CAKgT0UfgPdU1H5ZZ7GL7E=_oZNTzTwZN60Q-+2keBxDgQYODfg@mail.gmail.com>
 <20190717055804-mutt-send-email-mst@kernel.org>
 <CAKgT0Uf4iJxEx+3q_Vo9L1QPuv9PhZUv1=M9UCsn6_qs7rG4aw@mail.gmail.com>
 <20190718003211-mutt-send-email-mst@kernel.org>
 <CAKgT0UfQ3dtfjjm8wnNxX1+Azav6ws9zemH6KYc7RuyvyFo3fQ@mail.gmail.com>
 <20190718162040-mutt-send-email-mst@kernel.org>
 <CAKgT0UcKTzSYZnYsMQoG6pXhpDS7uLbDd31dqfojCSXQWSsX_A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0UcKTzSYZnYsMQoG6pXhpDS7uLbDd31dqfojCSXQWSsX_A@mail.gmail.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Thu, 18 Jul 2019 20:49:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 01:34:03PM -0700, Alexander Duyck wrote:
> On Thu, Jul 18, 2019 at 1:24 PM Michael S. Tsirkin <mst@redhat.com> wrote:
> >
> > On Thu, Jul 18, 2019 at 08:34:37AM -0700, Alexander Duyck wrote:
> > > > > > For example we allocate pages until shrinker kicks in.
> > > > > > Fair enough but in fact many it would be better to
> > > > > > do the reverse: trigger shrinker and then send as many
> > > > > > free pages as we can to host.
> > > > >
> > > > > I'm not sure I understand this last part.
> > > >
> > > > Oh basically what I am saying is this: one of the reasons to use page
> > > > hinting is when host is short on memory.  In that case, why don't we use
> > > > shrinker to ask kernel drivers to free up memory? Any memory freed could
> > > > then be reported to host.
> > >
> > > Didn't the balloon driver already have a feature like that where it
> > > could start shrinking memory if the host was under memory pressure? If
> > > so how would adding another one add much value.
> >
> > Well fundamentally the basic balloon inflate kind of does this, yes :)
> >
> > The difference with what I am suggesting is that balloon inflate tries
> > to aggressively achieve a specific goal of freed memory. We could have a
> > weaker "free as much as you can" that is still stronger than free page
> > hint which as you point out below does not try to free at all, just
> > hints what is already free.
> 
> Yes, but why wait until the host is low on memory?

It can come about for a variety of reasons, such as
other VMs being aggressive, or ours aggressively caching
stuff in memory.

> With my
> implementation we can perform the hints in the background for a low
> cost already. So why should we wait to free up memory when we could do
> it immediately. Why let things get to the state where the host is
> under memory pressure when the guests can be proactively freeing up
> the pages and improving performance as a result be reducing swap
> usage?

You are talking about sending free memory to host.
Fair enough but if you have drivers that aggressively
allocate memory then there won't be that much free guest
memory without invoking a shrinker.

-- 
MST

