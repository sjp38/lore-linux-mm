Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CF25C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 23:39:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C8A9621872
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 23:39:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C8A9621872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AB628E000C; Fri,  1 Feb 2019 18:39:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 459848E0001; Fri,  1 Feb 2019 18:39:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36FE58E000C; Fri,  1 Feb 2019 18:39:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id ECF0F8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 18:39:09 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id f125so5831772pgc.20
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 15:39:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yJL58k6j9CfudRSOwvutkIcAOqj7ljyp9/qO12DG5jg=;
        b=t5RDyyw2P6cFNzniH4sAT+29KsXvJYPN90dJL9oJdGJsxDx2c3cS3xLeg/Io494sZb
         /cbz9x3+S43rmaU9TsBISETAcQzFAsc8KvJMDw3gj+AhIZIzgBtssvTut4sT74kcBdEv
         G+MekAG8EYbujZ0uhe9QTxYTGdGDpgpPLiogf/Jpd70uB2F3CFxjgvYyJsB/vtpwh5uu
         BvkSWi9jnTwOsnWHZH3MnMO54zLuMeY4y8TDcpakYJA1VZLIY9NUA4cL/oAHT+QI4o1E
         lLgzPgSE1GXO6H+RM73XgfLAh2+u+filwLJ3IGfkmr/2oyQ+9m3Fuu63PyZrf/QY+r+C
         I32A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AJcUukeX2cVVDU445AbIufwCvoJJBNC+WlittLfjx1dcnYkycT7R5PSI
	e/2nnT0xRfGVBC1IRuGJMPPxLUKZVt2a7nO9cMsl2ncoVDNDUDB3pXaWLtx9SdJupUZE8A3DtCB
	HVrATy7nSsiZpt4vhem1aIk1hIIs5fg1KE8PItJBOKBUdkaNws4KQLI73egt9Zv4=
X-Received: by 2002:a63:e84c:: with SMTP id a12mr37126115pgk.241.1549064349591;
        Fri, 01 Feb 2019 15:39:09 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5Dg0tcuByUJ/DFuZlGDrruYlPQWcwPHIcOEvKOrFdp+iILkFzZUdcWj/3k84otvyE2/aeS
X-Received: by 2002:a63:e84c:: with SMTP id a12mr37126064pgk.241.1549064348769;
        Fri, 01 Feb 2019 15:39:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549064348; cv=none;
        d=google.com; s=arc-20160816;
        b=hsk50UeeJf0vXefM+O9BQ0g0vvzZfs3SmNj+iRzL7+A5ebPC6Cyj7liHkKRYwrWVdq
         jFs9TosBq15oMZfd8Lh6wskHONasoOxxzz+KcrEKIOhMsTLVIW0+6MiIEse1T29tKcAa
         SDCsyPwA7Ha7HgUYVrnE3/KOUzdMZkPxY8rlyYj5Jc8DIms6vJA7Q7P4T3nT1TbvY95f
         svx+/8Xh8yBlnWE3yZ0TTPz9KgOJFYuERSUfLaoasPi2ILChcJt4B3XEQtBRkUi+5AyI
         578JtYcX8apkhL1WgnmquzKKz/1SBbs4Qtowdic3gV4i4kRIiDvYuLMGpsnrt3TDEAdQ
         a0HA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yJL58k6j9CfudRSOwvutkIcAOqj7ljyp9/qO12DG5jg=;
        b=DXaz8ufu7W02Rw3MKZBxzkyntP+nB8tBSqAeK0VF7zzaMyaF3cqn2hxn8N5VWd6RS+
         khNLwnbAmVUZXpbdLfE7Lxdit+aTmdY1WQnPkJ4qKFVvwp88nuTztHUE9lxL4SdS4iI3
         S7uswZEKTtxeYEduaZ97dlBSZjs3WT9pxu4WXj+o7UQKbYeLxGnlY2ZIrrhfTtyIaOan
         VSkKqkjYd/9L0/g+WdLLoW2A+q9/N0fTC+NGc6SOmP3GjdqNz5nep2vEdHA2EbPuTQvX
         3Bm9hHk1CSIttH9L7eMoBQRSHs6VXvp+26SpHbMxq18uwQZzbmj59XO4U8PjCrCIH44Z
         8h6A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail03.adl2.internode.on.net (ipmail03.adl2.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id l66si8592453pfi.5.2019.02.01.15.39.07
        for <linux-mm@kvack.org>;
        Fri, 01 Feb 2019 15:39:08 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.141;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.141 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail03.adl2.internode.on.net with ESMTP; 02 Feb 2019 10:09:06 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gpiOn-0004mk-3p; Sat, 02 Feb 2019 10:39:05 +1100
Date: Sat, 2 Feb 2019 10:39:05 +1100
From: Dave Chinner <david@fromorbit.com>
To: Chris Mason <clm@fb.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	"linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>,
	Roman Gushchin <guro@fb.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"mhocko@kernel.org" <mhocko@kernel.org>,
	"vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/2] Revert "mm: don't reclaim inodes with many attached
 pages"
Message-ID: <20190201233905.GW6173@dastard>
References: <20190130041707.27750-1-david@fromorbit.com>
 <20190130041707.27750-2-david@fromorbit.com>
 <25EAF93D-BC63-4409-AF21-F45B2DDF5D66@fb.com>
 <20190131013403.GI4205@dastard>
 <E8895615-9DDA-4FC5-A3AB-1BE593138A89@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E8895615-9DDA-4FC5-A3AB-1BE593138A89@fb.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 03:48:11PM +0000, Chris Mason wrote:
> On 30 Jan 2019, at 20:34, Dave Chinner wrote:
> 
> > On Wed, Jan 30, 2019 at 12:21:07PM +0000, Chris Mason wrote:
> >>
> >>
> >> On 29 Jan 2019, at 23:17, Dave Chinner wrote:
> >>
> >>> From: Dave Chinner <dchinner@redhat.com>
> >>>
> >>> This reverts commit a76cf1a474d7dbcd9336b5f5afb0162baa142cf0.
> >>>
> >>> This change causes serious changes to page cache and inode cache
> >>> behaviour and balance, resulting in major performance regressions
> >>> when combining worklaods such as large file copies and kernel
> >>> compiles.
> >>>
> >>> https://bugzilla.kernel.org/show_bug.cgi?id=202441
> >>
> >> I'm a little confused by the latest comment in the bz:
> >>
> >> https://bugzilla.kernel.org/show_bug.cgi?id=202441#c24
> >
> > Which says the first patch that changed the shrinker behaviour is
> > the underlying cause of the regression.
> >
> >> Are these reverts sufficient?
> >
> > I think so.
> 
> Based on the latest comment:
> 
> "If I had been less strict in my testing I probably would have 
> discovered that the problem was present earlier than 4.19.3. Mr Gushins 
> commit made it more visible.
> I'm going back to work after two days off, so I might not be able to 
> respond inside your working hours, but I'll keep checking in on this as 
> I get a chance."
> 
> I don't think the reverts are sufficient.

Roger has tested the two reverts more heavily against 5.0.0-rc3.
Without the reverts, the machine locks up hard. With the two reverts
applied, it runs along smoothly under extremely heavy load.

https://bugzilla.kernel.org/show_bug.cgi?id=202441#c26

So, yes, these changes need to be reverted.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

