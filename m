Return-Path: <SRS0=KlKP=WU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 640A9C3A5A4
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 19:57:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AC272146E
	for <linux-mm@archiver.kernel.org>; Sat, 24 Aug 2019 19:57:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="xop1Vb8o"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AC272146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F0DC6B04E5; Sat, 24 Aug 2019 15:57:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69FBC6B04E7; Sat, 24 Aug 2019 15:57:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 58F176B04E8; Sat, 24 Aug 2019 15:57:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0136.hostedemail.com [216.40.44.136])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2586B04E5
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 15:57:53 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id E510C3CF9
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 19:57:52 +0000 (UTC)
X-FDA: 75858381984.15.room47_61dd1d759c24f
X-HE-Tag: room47_61dd1d759c24f
X-Filterd-Recvd-Size: 2674
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 24 Aug 2019 19:57:52 +0000 (UTC)
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D27962082E;
	Sat, 24 Aug 2019 19:57:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1566676671;
	bh=MarEzIq7oHZK8s3g0cjP9atdboVj3SRVugsL5q1dspM=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=xop1Vb8otLQ94HJ3aLg5YMDZc4cHNe23khfk5bWHO7WxQXhU3bXn9Tu/kTumbnWyv
	 GTFo16QqVwqvgVc2DG6/bsuH6Onrm/3Rs6XxCg0K1TPgROEevte596+voBLEpcw3X/
	 vcH/yzOFOug/xKPlGIL/RF+PkouyRD9maJIZsYpA=
Date: Sat, 24 Aug 2019 12:57:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Roman Gushchin <guro@fb.com>
Cc: Greg KH <greg@kroah.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
 Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team
 <Kernel-team@fb.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>,
 Yafang Shao <laoar.shao@gmail.com>
Subject: Re: [PATCH] Partially revert
 "mm/memcontrol.c: keep local VM counters in sync with the hierarchical ones"
Message-Id: <20190824125750.da9f0aac47cc0a362208f9ff@linux-foundation.org>
In-Reply-To: <20190817191518.GB11125@castle>
References: <20190817004726.2530670-1-guro@fb.com>
	<20190817063616.GA11747@kroah.com>
	<20190817191518.GB11125@castle>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 17 Aug 2019 19:15:23 +0000 Roman Gushchin <guro@fb.com> wrote:

> > > Fixes: 766a4c19d880 ("mm/memcontrol.c: keep local VM counters in sync with the hierarchical ones")
> > > Signed-off-by: Roman Gushchin <guro@fb.com>
> > > Cc: Yafang Shao <laoar.shao@gmail.com>
> > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > ---
> > >  mm/memcontrol.c | 8 +++-----
> > >  1 file changed, 3 insertions(+), 5 deletions(-)
> > 
> > <formletter>
> > 
> > This is not the correct way to submit patches for inclusion in the
> > stable kernel tree.  Please read:
> >     https://www.kernel.org/doc/html/latest/process/stable-kernel-rules.html
> > for how to do this properly.
> 
> Oh, I'm sorry, will read and follow next time. Thanks!

766a4c19d880 is not present in 5.2 so no -stable backport is needed, yes?

