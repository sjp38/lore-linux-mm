Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7F5AC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:59:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94D55208C4
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:59:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94D55208C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 312ED6B0003; Mon,  1 Jul 2019 04:59:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C3D68E0003; Mon,  1 Jul 2019 04:59:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B28F8E0002; Mon,  1 Jul 2019 04:59:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f78.google.com (mail-ed1-f78.google.com [209.85.208.78])
	by kanga.kvack.org (Postfix) with ESMTP id BFE556B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 04:59:23 -0400 (EDT)
Received: by mail-ed1-f78.google.com with SMTP id b33so16353207edc.17
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 01:59:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LEGcXfT/HJX4yO3feguoPG0J/A642eUZpfyIoGjGYvI=;
        b=rMJJKQaX2g8vNPfC9yaZJjga66HpQkMcM8AsAK3ecMWaGBOs9FFWi+7T1LvR/Ukj3o
         1bdR8xjltVlzdKreqfjcWYD2WJFo/ZpgqqDADYVU+Mwftp2uqklnYZtPU5uo00XCDhuv
         BGrOPIpkYMkdrmUtVyerX9Q7OTnApXBud5vDhKpqouKxl9PFjMv9OqnilKlKvUXEuGDa
         6sK5j/Hu+OKRpaTOxiqh0ewTm22fofS3/1RS31TIX3cTbAYfyBLHg5T6hu6wJKo1sCGS
         2L7IGJqQp/T4Hoh2qCZ4lyucE7s8kyTlGVP5fUy47KKRDOT0S5NDU3rgcjfOj6ko5kgh
         PvFQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Gm-Message-State: APjAAAVTWt5eNPdLa94KLLG88BS/GkXTZmc/N5rdvmMMKPQf81atnPHN
	vRKatsyqg3ISEos2AvTaAwvf/3KqIzJ/10uSJI2/s5MDZGdGJhNIZmQ7sT3YyPdlqu+2ehiKag4
	cbtBNQtI8dwI/n6EXzr/+Yq7l82db+0lZ0ykXcheR36my7jygLdbtb72ITO9HaA7xZg==
X-Received: by 2002:a17:906:2e59:: with SMTP id r25mr21467052eji.293.1561971563346;
        Mon, 01 Jul 2019 01:59:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvojIvPdr63QNFQndv79oDZjWt7q4kCCeHpVZmjb5BU6sRuDOWiwUEE4oSfnI+YMQR451I
X-Received: by 2002:a17:906:2e59:: with SMTP id r25mr21467011eji.293.1561971562575;
        Mon, 01 Jul 2019 01:59:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561971562; cv=none;
        d=google.com; s=arc-20160816;
        b=bocivSBYGZhrA9sOT4FZ8KiC3LWAOu1kqa+W2rhfy3PTg4TALK7rVTgwGC8xoh09l/
         CUoi1i01JUP+62ZwlCCjy3/VXo/5fnNbVMC71n56HWkBxIRZ50iOILchnkBeYnpQvnOO
         RWq0BYVvk+vYqJohxYbEP2jKJSV5mzxKiGWeeSn6jCaCZ+dWWiDOO3wDD+4/dZETRelm
         3qD4LMe+6Tf9Bp7bcZ1D4xw2eSHmFsvCYofMLlS77X1RKKCuHasnl3IzJ4PFHE9UH3Hw
         lD5VEq19xsoJyEeqgxZ5ZTsUmyggbK3RkJWF/7wJA/eUmcUWXcGJl5WiMPAp5ug1uJMH
         N0qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LEGcXfT/HJX4yO3feguoPG0J/A642eUZpfyIoGjGYvI=;
        b=EcNz59VPVsmr/FKWJPr8jWT+L4t1WsnA577DGgE1W+hikPHcv3Yk90wEQNlaQM0g0k
         Sk8V8O4GUccXCOs8fIl75U2iMmCCH6Nti5x1DFPVM5iCQaKMKkurh1yOj5y84fTlrn5w
         j6ZkWSEcYarh72qUO0sPei0de/WFPs1w5lcglMEL5j0CmJrXkZ4fXwxdeW9XLgjsGI4s
         +NsdxYF0yi9Q4TO9b7rnZvho3xjtV5uHH+j1ytXE+/nLBMpda3QS88u0YSlB+IFbQhOr
         Hb428NkyNels0Mku3FWvIxEYKJSnGEWgJWgBOKU+JwbiVcCs552S8wMVx+r4UijbDXYd
         li6A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a49si8445551edd.383.2019.07.01.01.59.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 01:59:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=mgorman@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 297ADAD2A;
	Mon,  1 Jul 2019 08:59:22 +0000 (UTC)
Date: Mon, 1 Jul 2019 09:59:20 +0100
From: Mel Gorman <mgorman@suse.de>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Question] Should direct reclaim time be bounded?
Message-ID: <20190701085920.GB2812@suse.de>
References: <d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com>
 <20190423071953.GC25106@dhcp22.suse.cz>
 <eac582cf-2f76-4da1-1127-6bb5c8c959e4@oracle.com>
 <04329fea-cd34-4107-d1d4-b2098ebab0ec@suse.cz>
 <dede2f84-90bf-347a-2a17-fb6b521bf573@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <dede2f84-90bf-347a-2a17-fb6b521bf573@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 11:20:42AM -0700, Mike Kravetz wrote:
> On 4/24/19 7:35 AM, Vlastimil Babka wrote:
> > On 4/23/19 6:39 PM, Mike Kravetz wrote:
> >>> That being said, I do not think __GFP_RETRY_MAYFAIL is wrong here. It
> >>> looks like there is something wrong in the reclaim going on.
> >>
> >> Ok, I will start digging into that.  Just wanted to make sure before I got
> >> into it too deep.
> >>
> >> BTW - This is very easy to reproduce.  Just try to allocate more huge pages
> >> than will fit into memory.  I see this 'reclaim taking forever' behavior on
> >> v5.1-rc5-mmotm-2019-04-19-14-53.  Looks like it was there in v5.0 as well.
> > 
> > I'd suspect this in should_continue_reclaim():
> > 
> >         /* Consider stopping depending on scan and reclaim activity */
> >         if (sc->gfp_mask & __GFP_RETRY_MAYFAIL) {
> >                 /*
> >                  * For __GFP_RETRY_MAYFAIL allocations, stop reclaiming if the
> >                  * full LRU list has been scanned and we are still failing
> >                  * to reclaim pages. This full LRU scan is potentially
> >                  * expensive but a __GFP_RETRY_MAYFAIL caller really wants to succeed
> >                  */
> >                 if (!nr_reclaimed && !nr_scanned)
> >                         return false;
> > 
> > And that for some reason, nr_scanned never becomes zero. But it's hard
> > to figure out through all the layers of functions :/
> 
> I got back to looking into the direct reclaim/compaction stalls when
> trying to allocate huge pages.  As previously mentioned, the code is
> looping for a long time in shrink_node().  The routine
> should_continue_reclaim() returns true perhaps more often than it should.
> 
> As Vlastmil guessed, my debug code output below shows nr_scanned is remaining
> non-zero for quite a while.  This was on v5.2-rc6.
> 

I think it would be reasonable to have should_continue_reclaim allow an
exit if scanning at higher priority than DEF_PRIORITY - 2, nr_scanned is
less than SWAP_CLUSTER_MAX and no pages are being reclaimed.

-- 
Mel Gorman
SUSE Labs

