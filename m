Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F95EC3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 11:59:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0FFCA215EA
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 11:59:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ut3y8nHD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0FFCA215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A96106B0266; Thu, 29 Aug 2019 07:59:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A468E6B0269; Thu, 29 Aug 2019 07:59:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9342F6B026A; Thu, 29 Aug 2019 07:59:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0137.hostedemail.com [216.40.44.137])
	by kanga.kvack.org (Postfix) with ESMTP id 6D2216B0266
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 07:59:45 -0400 (EDT)
Received: from smtpin15.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 218149070
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 11:59:45 +0000 (UTC)
X-FDA: 75875321130.15.wood38_8f4b4ba45df10
X-HE-Tag: wood38_8f4b4ba45df10
X-Filterd-Recvd-Size: 3121
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf31.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 11:59:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=hvvxWk91syqxpuQ6n+HNuHloyMZzn7A9DjJbU+vMf1E=; b=ut3y8nHDtL7vAft1lfDYM1LZ3
	74FoUkUqEumlTKEMnbZRh3f0+k9xPSX82zm9avCxYNEVxww2IxT9DqVZ2heumzfzk2EQupwaBPdNU
	2r48dsvvmOMTYXuBaTnMk+k+7qjW0JpXwcxRpihLJmcEWpg8p0QTJDkSOgG7NGrMgk21gx+ShZtNW
	j8Vaxq4coWoCzgxm8XDgE42UR1VUyX0DDTUKYfqdzMyLSQLSu1/dwlsqzJVfM9iNCvpSbEGvNWUkM
	h5kDjk1WR+KkLWkVFRQi1htAdAxcP8xSxfXJgxiqV/ZGIH33RMEpvnxetPBMPMLpJCJH894Rle29U
	MI+uIxyvA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1i3J5Y-0002qk-96; Thu, 29 Aug 2019 11:59:40 +0000
Date: Thu, 29 Aug 2019 04:59:40 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, mgorman@suse.de
Subject: Re: Truncate regression due to commit 69b6c1319b6
Message-ID: <20190829115940.GD6590@bombadil.infradead.org>
References: <20190226165628.GB24711@quack2.suse.cz>
 <20190226172744.GH11592@bombadil.infradead.org>
 <20190227112721.GB27119@quack2.suse.cz>
 <20190227122451.GJ11592@bombadil.infradead.org>
 <20190227165538.GD27119@quack2.suse.cz>
 <20190228225317.GM11592@bombadil.infradead.org>
 <20190314111012.GG16658@quack2.suse.cz>
 <20190531190431.GA15496@bombadil.infradead.org>
 <20190827132925.GA9061@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190827132925.GA9061@quack2.suse.cz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 27, 2019 at 03:29:25PM +0200, Jan Kara wrote:
> On Fri 31-05-19 12:04:31, Matthew Wilcox wrote:
> > On Thu, Mar 14, 2019 at 12:10:12PM +0100, Jan Kara wrote:
> > > On Thu 28-02-19 14:53:17, Matthew Wilcox wrote:
> > > > Here's what I'm currently looking at.  xas_store() becomes a wrapper
> > > > around xas_replace() and xas_replace() avoids the xas_init_marks() and
> > > > xas_load() calls:
> > > 
> > > This looks reasonable to me. Do you have some official series I could test
> > > or where do we stand?
> > 
> > Hi Jan,
> > 
> > Sorry for the delay; I've put this into the xarray tree:
> > 
> > http://git.infradead.org/users/willy/linux-dax.git/shortlog/refs/heads/xarray
> > 
> > I'm planning to ask Linus to pull it in about a week.
> 
> Hum, I still don't see these xarray changes (the change to use
> xas_replace() in particular) upstream. What has happened?

It had a bug and I decided to pull the patch for now rather than find
the bug ... this regression is still on my mind.  Thanks for the ping.

