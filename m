Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F4CAC3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 13:29:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09E7C20828
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 13:29:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09E7C20828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83AE26B0005; Tue, 27 Aug 2019 09:29:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EB7B6B0008; Tue, 27 Aug 2019 09:29:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 734536B000A; Tue, 27 Aug 2019 09:29:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0244.hostedemail.com [216.40.44.244])
	by kanga.kvack.org (Postfix) with ESMTP id 500506B0005
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 09:29:29 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 02533180AD7C1
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 13:29:29 +0000 (UTC)
X-FDA: 75868289658.22.cook08_52b540ba1da5f
X-HE-Tag: cook08_52b540ba1da5f
X-Filterd-Recvd-Size: 2221
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf23.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 13:29:28 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id EB238B066;
	Tue, 27 Aug 2019 13:29:26 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id DECC41E4362; Tue, 27 Aug 2019 15:29:25 +0200 (CEST)
Date: Tue, 27 Aug 2019 15:29:25 +0200
From: Jan Kara <jack@suse.cz>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org, mgorman@suse.de
Subject: Re: Truncate regression due to commit 69b6c1319b6
Message-ID: <20190827132925.GA9061@quack2.suse.cz>
References: <20190226165628.GB24711@quack2.suse.cz>
 <20190226172744.GH11592@bombadil.infradead.org>
 <20190227112721.GB27119@quack2.suse.cz>
 <20190227122451.GJ11592@bombadil.infradead.org>
 <20190227165538.GD27119@quack2.suse.cz>
 <20190228225317.GM11592@bombadil.infradead.org>
 <20190314111012.GG16658@quack2.suse.cz>
 <20190531190431.GA15496@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190531190431.GA15496@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 31-05-19 12:04:31, Matthew Wilcox wrote:
> On Thu, Mar 14, 2019 at 12:10:12PM +0100, Jan Kara wrote:
> > On Thu 28-02-19 14:53:17, Matthew Wilcox wrote:
> > > Here's what I'm currently looking at.  xas_store() becomes a wrapper
> > > around xas_replace() and xas_replace() avoids the xas_init_marks() and
> > > xas_load() calls:
> > 
> > This looks reasonable to me. Do you have some official series I could test
> > or where do we stand?
> 
> Hi Jan,
> 
> Sorry for the delay; I've put this into the xarray tree:
> 
> http://git.infradead.org/users/willy/linux-dax.git/shortlog/refs/heads/xarray
> 
> I'm planning to ask Linus to pull it in about a week.

Hum, I still don't see these xarray changes (the change to use
xas_replace() in particular) upstream. What has happened?

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

