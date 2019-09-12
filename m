Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C53BAC4CEC6
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 17:21:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DBBD2067D
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 17:21:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fic/yNRo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DBBD2067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C3ED6B0003; Thu, 12 Sep 2019 13:21:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2757C6B0006; Thu, 12 Sep 2019 13:21:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1646E6B0007; Thu, 12 Sep 2019 13:21:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0059.hostedemail.com [216.40.44.59])
	by kanga.kvack.org (Postfix) with ESMTP id E3A226B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 13:21:30 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 80F7C8243763
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 17:21:30 +0000 (UTC)
X-FDA: 75926935140.21.show17_81842527a3c5b
X-HE-Tag: show17_81842527a3c5b
X-Filterd-Recvd-Size: 6752
Received: from mail-pg1-f194.google.com (mail-pg1-f194.google.com [209.85.215.194])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 17:21:29 +0000 (UTC)
Received: by mail-pg1-f194.google.com with SMTP id w10so13833056pgj.7
        for <linux-mm@kvack.org>; Thu, 12 Sep 2019 10:21:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=7ELatS+qNwcqZFlGpoKi7iobXH6c8V+qxrhRPOrjs54=;
        b=fic/yNRoUbOshKf70uCLRttuKIFyNPCwbkyjVy7IaAkeyp9nOiqYEb2H5J8G6Hs3AH
         SaT2pHiD0cJBkcvWfdj5QRvUVKfC3uTwKIMrmxRMQnJ6QtDtZ9fK8cNcQCnDCk6OWL0r
         ie25/fC0n7gs7E2KLdSIX/xwj+GBedVQPOYJK2gYcmy2lY7U/sjaK1Bn28yF+aZUnG15
         ji0c6d/gqdBPDKYhKET84p010KEYjswZ6Kee8LyX2fb/sbgGFLsbvDjJ05gmyDOEdnt3
         f0SqN0YffMqViC6+4yTyNq9QHPeyvyasDNthkbw+tILxKD4/KLTEYPTflwMgrI7CvdLW
         /tXA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=7ELatS+qNwcqZFlGpoKi7iobXH6c8V+qxrhRPOrjs54=;
        b=MVroubxlRl5TvlkZ0M1ZnzzlY9HPm7V3sBFokdmgxNSJc3o9OSmUgf3p5ezhx2aUMr
         WWqVQur1yZOUq+Atvhcx5uUGryKQqIkEAXzasgUekO9yIj3q5UNkhiHpY/xYgwOg4rKi
         BVrmK2FzmeeGVuFO4x1uUrOugmEuSANydZsbPLTx1hiYiWglcCPkvCJ/liMOzuFXVBvg
         nf7IztTjiltpReeTmOgpHc7y//uyHhKSklKch6pIWqU5iJHc2ClAFSzWf4LrQB1L6kkc
         4r/rhR1OObnCjb3n3STlW57ieFrvJGykGXp0c1PId1NKzrkE9x/vD5pKjW2ENISEg7RF
         oqEQ==
X-Gm-Message-State: APjAAAXO3QCTz9FRbX4oCQgUrKh4vv6qvTy9TyhbDW88eNLPmqNok4ws
	7ey0iMFrULEMPM7vDfY3eWM=
X-Google-Smtp-Source: APXvYqyNX7lxxxME/8dFZo9+JTc1bHPD2IOSqYLwAAfvYJAiKIQRg83EKM9Vk+aVP1tSkjhJCil0qg==
X-Received: by 2002:a62:5ac1:: with SMTP id o184mr49440519pfb.67.1568308888895;
        Thu, 12 Sep 2019 10:21:28 -0700 (PDT)
Received: from google.com ([2620:15c:211:1:3e01:2939:5992:52da])
        by smtp.gmail.com with ESMTPSA id h70sm22082955pgc.36.2019.09.12.10.21.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 12 Sep 2019 10:21:27 -0700 (PDT)
Date: Thu, 12 Sep 2019 10:21:25 -0700
From: Minchan Kim <minchan@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: sunqiuyang <sunqiuyang@huawei.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: [PATCH 1/1] mm/migrate: fix list corruption in migration of
 non-LRU movable pages
Message-ID: <20190912172125.GB119788@google.com>
References: <20190903082746.20736-1-sunqiuyang@huawei.com>
 <20190903131737.GB18939@dhcp22.suse.cz>
 <157FC541501A9C4C862B2F16FFE316DC190C1B09@dggeml512-mbx.china.huawei.com>
 <20190904063836.GD3838@dhcp22.suse.cz>
 <157FC541501A9C4C862B2F16FFE316DC190C2EBD@dggeml512-mbx.china.huawei.com>
 <20190904081408.GF3838@dhcp22.suse.cz>
 <157FC541501A9C4C862B2F16FFE316DC190C3402@dggeml512-mbx.china.huawei.com>
 <20190904125226.GV3838@dhcp22.suse.cz>
 <157FC541501A9C4C862B2F16FFE316DC190C5990@dggeml512-mbx.china.huawei.com>
 <20190909084029.GE27159@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190909084029.GE27159@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 09, 2019 at 10:40:29AM +0200, Michal Hocko wrote:
> On Thu 05-09-19 01:44:12, sunqiuyang wrote:
> > > 
> > > ________________________________________
> > > From: Michal Hocko [mhocko@kernel.org]
> > > Sent: Wednesday, September 04, 2019 20:52
> > > To: sunqiuyang
> > > Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org
> > > Subject: Re: [PATCH 1/1] mm/migrate: fix list corruption in migration of non-LRU movable pages
> > > 
> > > On Wed 04-09-19 12:19:11, sunqiuyang wrote:
> > > > > Do not top post please
> > > > >
> > > > > On Wed 04-09-19 07:27:25, sunqiuyang wrote:
> > > > > > isolate_migratepages_block() from another thread may try to isolate the page again:
> > > > > >
> > > > > > for (; low_pfn < end_pfn; low_pfn++) {
> > > > > >   /* ... */
> > > > > >   page = pfn_to_page(low_pfn);
> > > > > >  /* ... */
> > > > > >   if (!PageLRU(page)) {
> > > > > >     if (unlikely(__PageMovable(page)) && !PageIsolated(page)) {
> > > > > >         /* ... */
> > > > > >         if (!isolate_movable_page(page, isolate_mode))
> > > > > >           goto isolate_success;
> > > > > >       /*... */
> > > > > > isolate_success:
> > > > > >      list_add(&page->lru, &cc->migratepages);
> > > > > >
> > > > > > And this page will be added to another list.
> > > > > > Or, do you see any reason that the page cannot go through this path?
> > > > >
> > > > > The page shouldn't be __PageMovable after the migration is done. All the
> > > > > state should have been transfered to the new page IIUC.
> > > > >
> > > >
> > > > I don't see where page->mapping is modified after the migration is done.

Look at __ClearPageMovable which modify page->mapping.
Once driver is migrated the page successfully, it should call __ClearPageMovable.
To not consume new a page flag at that time, this flag is stored at page->mapping
since we already have squeezed several flags in there.

> > > >
> > > > Actually, the last comment in move_to_new_page() says,
> > > > "Anonymous and movable page->mapping will be cleard by
> > > > free_pages_prepare so don't reset it here for keeping
> > > > the type to work PageAnon, for example. "
> > > >
> > > > Or did I miss something? Thanks,
> > > 
> > > This talks about mapping rather than flags stored in the mapping.
> > > I can see that in tree migration handlers (z3fold_page_migrate,
> > > vmballoon_migratepage via balloon_page_delete, zs_page_migrate via
> > > reset_page) all reset the movable flag. I am not sure whether that is a
> > > documented requirement or just a coincidence. Maybe it should be
> > > documented. I would like to hear from Minchan.

It is intended. See Documentation/vm/page_migration.rst

   After isolation, VM calls migratepage of driver with isolated page.
   The function of migratepage is to move content of the old page to new page
   and set up fields of struct page newpage. Keep in mind that you should
   indicate to the VM the oldpage is no longer movable via __ClearPageMovable()
   under page_lock if you migrated the oldpage successfully and returns
   MIGRATEPAGE_SUCCESS.

Thanks.

