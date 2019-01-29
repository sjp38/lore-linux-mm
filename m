Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7949CC282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:27:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39AE521852
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 19:27:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="YrvP+7Wj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39AE521852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D79138E0013; Tue, 29 Jan 2019 14:27:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D29CA8E0001; Tue, 29 Jan 2019 14:27:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C40428E0013; Tue, 29 Jan 2019 14:27:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C05A8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:27:18 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id h85so11323699oib.9
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:27:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=nET3Y86B4FJO24Nl8dIyjfW3/vMpVLUZO3awvOx1bRU=;
        b=Wgac9IL/GJIrucGvxzbDwruS4ycofIfadlEWIXAxWLFfGZY2uUycFsI63L4Rmztt+c
         c7I1/mEoWY5XMHYQLYJxzGqmuavhzKhgSg0/eB/XLhwZJotIXDuB5u72gYkV74ULW+RJ
         qKTIfH8iDn0lY2iU2MZZO8LEjpE8pDfrQG4T+grEGwHGttzUou40qPgLvy8NhaQsJs0G
         7RoeCMglPTbMoEeG8eYjwuWs9DwAQxw/LuXEbCtRPyxAa1o3QF4y0kfwyngeAFVzj7ep
         f6bQnWt5I8ycwjq2dEiCZwDjgu2u2TNSC0/rBRJxNc9q5335dXaeM/JShvxrPocm9uaX
         FOyQ==
X-Gm-Message-State: AJcUuke08WVD3KIOU+1+/8gD9myTd0Oo4sIUpOIGbtm2YqCDSxGyVTcW
	3ZS1F5V3AZMG32eqvPfDopljenLb3Dk+SjP8PHiSNspnQS2bhhIfkSjisDTyP7QRsY89fQ0fApF
	JWQFrlDAb9gN8K12CwTrq3Juzz3zPDOvNpZVFFWpl55+VKh1Z4IJKea/JfnnHNycfkALnlbmPyN
	cQIMCMFuiCwBLK1AygMSE/+VjA868SaeZIvJz63UNnQV2erZMnjufGq3xUqssK/rsu/lvUKriby
	ACSlerfzTzKeEUnjUo4KqtF2WONzjxNtsdIyUWujP4r+QS4NrxmJ5DRHX0T9OYiApx926NkTc15
	oFJpG9fVgAlEeHSYHmgYsshyn10wLW6QP9etwAgnJS7/Dm2OQ1v/PHwtjsPBeaJ1fWHUdlJNe9P
	7
X-Received: by 2002:a9d:e8c:: with SMTP id 12mr20954105otj.297.1548790038438;
        Tue, 29 Jan 2019 11:27:18 -0800 (PST)
X-Received: by 2002:a9d:e8c:: with SMTP id 12mr20954082otj.297.1548790037900;
        Tue, 29 Jan 2019 11:27:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548790037; cv=none;
        d=google.com; s=arc-20160816;
        b=Z2/5r9AFSSr8hmjjxWQdsvJ1glXGZXGTFAi+/e1BIXvvRLWQ+G7RGLpUSAGAQxDaUi
         SpPNqbkuq5MsJs8I+3YXOvvWLAqASYbHVTf0/U0ZNn2627hRe0HqkY2zVtTfwwwP2Ij9
         WrS+CcBFkiVJ7ENCBYAO49B8pudIG9sm78c+b5bFPo1g0YkPq7gBLVcuz9t68DU6V8x6
         XuK02waH4XEVsgbosW71ICxa2a3TZRP19T0yXxYhFgdAXPi3ziQgYzCGo8jmVwLJhk0X
         3OHRaF2MyOcKlo3lh0C0MQ3xByP5dLrgyg/AbkUtgXRmTymYPfITOZECzC5YJZPXVhGP
         z+ow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=nET3Y86B4FJO24Nl8dIyjfW3/vMpVLUZO3awvOx1bRU=;
        b=YKipFpNCDOHi0xvvw/UPOclNinsM9CMwkt9OddUICuRa0WA/fwkweVMPJa8CwnJKWD
         Rq7EuYno5/HnGZEwsgNuw8sogzT7g36gkX1mPi8KInmMdtofdB72Q77xVH6uVKMj1836
         qEJS54r7wxO53BNYVeCYYk378JrFnZxyr73AC+uZwJmfYmj+vDquie50YTgsS3FTpmRE
         ko/+p9weV4wtXUkYwt7kJr4Z/8GUc4ccuGQJoW2eNHrHDPStTB697TJ7DxVLLkumSNo1
         Og66yIuJlZFYeYicAQ2DCjBn9xW8jk2+34Y97NoitBIUrcoMRsXDzMMqjECkYc3y6gYb
         T0OA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=YrvP+7Wj;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 20sor7711353otg.112.2019.01.29.11.27.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 11:27:17 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=YrvP+7Wj;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nET3Y86B4FJO24Nl8dIyjfW3/vMpVLUZO3awvOx1bRU=;
        b=YrvP+7Wjt5mXzM5Ec+lXaUbBrMsan8PhJMu8/n3REzC244dMWImh79DE8soYLdE4fQ
         f43O9bbsZJjT/n6sD9CX+wRNOEe1bKTsrdEtEXZ1FroaS8b4DRL2618aCty2+21vQHtW
         TxaOLH9ZYrzqkFyAN83jHBCUFUgl5nwrL59QXbmgJp53RUXvls16PUCyrIKeg167f+0z
         /bR9pDiz5Hld4i/UkLrl921V/lb8WiuxunO910uZcA8UTjJa9PgDhCHTc4CLwUqItk/5
         3wkp0Y3DghWKwWuTTwave2IMtXKqkNrAAr7spDEjOgFJKXuURlD4oI+7FWUf5AWNLvsD
         0zrg==
X-Google-Smtp-Source: ALg8bN7SG3XMSqfla3KDK9bjtwYeb4iaklfQE03/7c+8/bunhAoLBZeuY7hkSaWpNWitfcRWCoa5pQe0fgpYoedjFNo=
X-Received: by 2002:a9d:5cc2:: with SMTP id r2mr20680714oti.367.1548790037656;
 Tue, 29 Jan 2019 11:27:17 -0800 (PST)
MIME-Version: 1.0
References: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154690327612.676627.7469591833063917773.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190125143044.GO3560@dhcp22.suse.cz>
In-Reply-To: <20190125143044.GO3560@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 29 Jan 2019 11:27:05 -0800
Message-ID: <CAPcyv4ga-SgWA1xVmYM2ZjT6ASfFYynP7YnJv5H9offEPYw+VA@mail.gmail.com>
Subject: Re: [PATCH v7 2/3] mm: Move buddy list manipulations into helpers
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Keith Busch <keith.busch@intel.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 25, 2019 at 6:31 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 07-01-19 15:21:16, Dan Williams wrote:
> > In preparation for runtime randomization of the zone lists, take all
> > (well, most of) the list_*() functions in the buddy allocator and put
> > them in helper functions. Provide a common control point for injecting
> > additional behavior when freeing pages.
>
> Looks good in general and it actually makes the code more readable.
> One nit below
>
> [...]
> > +static inline void rmv_page_order(struct page *page)
> > +{
> > +     __ClearPageBuddy(page);
> > +     set_page_private(page, 0);
> > +}
> > +
>
> I guess we do not really need this helper and simply squash it to its
> only user.

Ok.

>
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks.

>
> --
> Michal Hocko
> SUSE Labs

