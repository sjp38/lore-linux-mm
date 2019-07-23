Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03254C76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 20:44:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C712A218D4
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 20:44:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C712A218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D93D6B0006; Tue, 23 Jul 2019 16:44:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58B6F6B0007; Tue, 23 Jul 2019 16:44:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42AE18E0002; Tue, 23 Jul 2019 16:44:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0BFDB6B0006
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 16:44:20 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id n4so22175687plp.4
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:44:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=H8aBQSEsaZTZGo2ZUFNcO061YVsDJZ8lUI05+51bAoM=;
        b=B18t57HLhNT3fw8xoiT81eD8S9PEjqwCbkhQbRs1SL2DQwSq14yO4r5rQ737QbHKaB
         zdQp9XCQ3okRTbqS9C9dVCC29H9oPYsz8aeEeegucgyeaQfAWRu2o9JgFN76jvFgfZaF
         glvsmczbG9oNxy7OVnnZa5iyQxvcMuHfklUV+vqx0Rjqxt2wA3j324Jmq5Q41Hn6pa8p
         Z7xvrVP/bpZvp0Rr7k0p2qiUSDeQxGwLFWnIQujY2CPbTB8ZKPEMb72I4a8XSF9sf98o
         jRpGyl8rstpYDJQo2T9jzPFmcISI9AYM6TWhS92siOzPwmJg9KqOJrvU0Owrs+uItgRx
         RlDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXXu8a95Xdi5h+WDzLt5Sm9suA/FSXV13CKRqevAromG21j2i2V
	gGLFkEqVASfu3HAUfV+mGbteCB07YHcjFPQYarLxwhJnAq8Qq1Vv5l9Q86CnUjr9tQUBPyiQ5EM
	aUXFUwTS1WGjkF4nH1yn4BKr5sCEeaMXD6QFsb/Uyj6iWt+w8s28ufl5FGgc3M2BuOg==
X-Received: by 2002:a17:90a:346c:: with SMTP id o99mr82388424pjb.20.1563914659722;
        Tue, 23 Jul 2019 13:44:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWfo+MpKD0V4LZPPOptFBrFZG2zJ2KKojRfQFwSJSOJ0fJIMSdekeBM2bABrWlNMLyBnxg
X-Received: by 2002:a17:90a:346c:: with SMTP id o99mr82388395pjb.20.1563914659086;
        Tue, 23 Jul 2019 13:44:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563914659; cv=none;
        d=google.com; s=arc-20160816;
        b=kQMDunqI5izqcGpbIhlwjC80W7X8GnX6WRzPMrQekgJA4V9W4LiJvMq+OYjEmi8cqp
         PUBPpOWdGDgy91/QFJs27cD6YEUpBK0HoGP/iOiVT9Lqa5LQYPHwAh904R5PEjO8fxmE
         HfgR+G5vAh71fAuedpD2JU9ci/2G3NaClKUt+fPKUsFuJOrqTly6UuDrPsWZEVnG6oBH
         gcxxiPt6oeVAlv/5F2QL0J6+5jMdY6hHulzjZYi3DcUc62ZVLTaYJO1TaflHjB+CvAEC
         8YyEHydhgFmJiaouoTLEloABNY3QFcQzVCK8DFfjnT6m6A8/iKHWufE7Mtqj5I4Gz+32
         Gu9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=H8aBQSEsaZTZGo2ZUFNcO061YVsDJZ8lUI05+51bAoM=;
        b=loKFLSOCFJS0LJz3P/WwmFPrgozoczOLL5BEnetxBPWnpVh4eFqaf6tAau7e3I9Lj+
         HxKrHfMoY4f8sDA/haoKhyicoWnNKvYb4DuMkLserhINCuWtCBiZXtHodEvps0G2MygF
         ABaXs1PUeOfVPkDPt9TH+VkrwJigx/OLQwBgGRAaqlOYMD+8I9Y9K4H7kkBeMuaZoFbB
         hn+zW7lldW7lG4ZPczON+yDi4BoBNuhmYKpeNapQYjrYPLms7/8ufwThVV+G6uKl0aT4
         tJftVVGnbYGiH6rgHHFHL+Fbio7oKDL6qqewL3XO+hpJOfnq8XHmMhYmKfuQBMaA5o9E
         ey5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 102si11490273plf.250.2019.07.23.13.44.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 13:44:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Jul 2019 13:44:18 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,300,1559545200"; 
   d="scan'208";a="368558615"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by fmsmga005.fm.intel.com with ESMTP; 23 Jul 2019 13:44:17 -0700
Date: Tue, 23 Jul 2019 13:44:16 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Atul Gupta <atul.gupta@chelsio.com>, linux-crypto@vger.kernel.org
Subject: Re: [PATCH v2 1/3] mm: Introduce page_size()
Message-ID: <20190723204416.GA27491@iweiny-DESK2.sc.intel.com>
References: <20190721104612.19120-1-willy@infradead.org>
 <20190721104612.19120-2-willy@infradead.org>
 <20190723004307.GB10284@iweiny-DESK2.sc.intel.com>
 <20190723160248.GK363@bombadil.infradead.org>
 <20190723175838.GA29729@iweiny-DESK2.sc.intel.com>
 <20190723181413.GN363@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723181413.GN363@bombadil.infradead.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000010, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 11:14:13AM -0700, Matthew Wilcox wrote:
> On Tue, Jul 23, 2019 at 10:58:38AM -0700, Ira Weiny wrote:
> > > @@ -1092,7 +1092,7 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
> > >  			if (page && off == pg_size) {
> > >  				put_page(page);
> > >  				TCP_PAGE(sk) = page = NULL;
> > > -				pg_size = PAGE_SIZE;
> > > +				pg_size = 0;
> > 
> > Yea...  I was not sure about this one at first...  :-/
> 
> I'm not sure we actually need to change pg_size here, but it seemed
> appropriate to set it back to 0.
> 
> > >  							   __GFP_NORETRY,
> > >  							   order);
> > > -					if (page)
> > > -						pg_size <<= order;
> > >  				}
> > >  				if (!page) {
> > >  					page = alloc_page(gfp);
> > > -					pg_size = PAGE_SIZE;
> > >  				}
> > >  				if (!page)
> > >  					goto wait_for_memory;
> > 
> > Side note: why 2 checks for !page?
> 
> Because page is assigned to after the first check ...

Ah yea duh!  Sorry it is a bit hard to follow.

Ira

