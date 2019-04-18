Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29178C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:25:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAC3A2083D
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:25:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAC3A2083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4AF5B6B0005; Thu, 18 Apr 2019 11:25:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 45F576B0006; Thu, 18 Apr 2019 11:25:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39BE26B0007; Thu, 18 Apr 2019 11:25:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 07A836B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:25:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p88so1418139edd.17
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:25:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ymTEL7c3KS6hTf10T2A0jF+X5e8z/T/9OQFqo0Qs87g=;
        b=ehCxNE3EX+pOhx4WzB1fIBQHwrC+MRIiMDPqGPvFV6Ut1Yk/gjIx59Bnzc4McDfMET
         puImwntf/HEWbRc55KQPYlY/A4BwgoDEFQWsZViWVX5wDjX6/hM5dwxX/XjfAfbyPyYa
         7FcvYwaC3otnfIlYe14a+8xXIg7ZYUAjobKaVx+uD7apgwxElh29YenluoMYU6mDSMxZ
         MN/axB1OBKQr8xp1HwtrlrEwOR7wh3DRZ26UjVWJtW9joBZuG/rRbyLt9CMNzuRIWVdZ
         kdZi/nXEsGl7C/bjAZLuskX3C6rByEq9dljgDAPEVPS0cGxBX4Zda55zDPTltcyXsU9T
         K8DQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.231 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAUMjSRsgqxSXkVhJPBMrKhxtVXATueIiF08K4Qk6PfGUcsjEHy8
	GIyJjnaAu6uXdWQ2aB+FLRV9KbP3d+Fidgo70cB8oxUxknqxeKMIZ3AhN+3ub0xdwLDtmVufFKg
	jvNlXUSIMDNtkgDGg8BtxHelJSiG/P697dRbKLeDyWgGeJRUtKp0UeHNCUQ3tb7KlTg==
X-Received: by 2002:a17:906:af6d:: with SMTP id os13mr51671043ejb.222.1555601114579;
        Thu, 18 Apr 2019 08:25:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4JPdLCCBNHOAItSmb70vllNaw5Rs9OABGiYUBst3yLdVKtJra4XLP17MKNg6OfIXLRRYC
X-Received: by 2002:a17:906:af6d:: with SMTP id os13mr51671010ejb.222.1555601113747;
        Thu, 18 Apr 2019 08:25:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555601113; cv=none;
        d=google.com; s=arc-20160816;
        b=GT7XeMW2mgpucn8wvC6xEvEdF7ATinKlckRERJpzUr+Swl1z2p2Y/q4C8USn0qi5+i
         vWSe3yt7w+k8PfpFUJQ05CdGYalIOZN6qgW/pa0xhP+28RCDNPux6McfdiRIvTL2ALwL
         sluz4qiBAcn41CjffH6RdF42NIKdDMG09zM/ZMi1M9+bwjT+1b24E8dMxpM25J9L5CnF
         kOPw4NT+r8A06gjG35M7QQOydUHvbPr4hgBbz1/2K02LfIjRTiyaqCu8JorPG1YzdHPC
         ioO89APmGfMm7FBjeJllwGithOMck1G7Sj2yl5xMxTBloKFPCuakXbewDmpw3vh6Gi5Z
         hkAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ymTEL7c3KS6hTf10T2A0jF+X5e8z/T/9OQFqo0Qs87g=;
        b=iVNbrC78PJEvWrtwRU92oSPOIRxmarFAhhamF+fUJ3oQnDSyK6mKETdu54K7NnRAWo
         V0dCZRyorHwafl+AvBNEaKg8A9ffgIKmeksRjiH9RgC24zLGO8T4kVQx6gJQZXD1ETtK
         H4SCEJHUWE3f1Sqe0O6X6+eRDIoCx2fbUZtNBMIA4/3MT05FjZAqLviARwpKDxiV1XUl
         LddYs1fgtTLc+LdlYD3kPYlbrCkjh4rAh7r85FxB0lEB8GKA5TCZwXyjlrJkxOIP69KT
         uF/QDk2PB124MAiSRPPq5Wce4s+VwZ06GqAcPq2xF+/TyRj4J8Q5jD9QPB/SqwlRueLO
         zfqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.231 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp14.blacknight.com (outbound-smtp14.blacknight.com. [46.22.139.231])
        by mx.google.com with ESMTPS id l44si1029066edb.440.2019.04.18.08.25.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 08:25:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.231 as permitted sender) client-ip=46.22.139.231;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.231 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (unknown [81.17.254.16])
	by outbound-smtp14.blacknight.com (Postfix) with ESMTPS id 437DF1C29F5
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 16:25:13 +0100 (IST)
Received: (qmail 28606 invoked from network); 18 Apr 2019 15:25:13 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 18 Apr 2019 15:25:13 -0000
Date: Thu, 18 Apr 2019 16:25:11 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Matthew Wilcox <willy@infradead.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Li Wang <liwang@redhat.com>,
	Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>
Subject: Re: v5.1-rc5 s390x WARNING
Message-ID: <20190418152511.GG18914@techsingularity.net>
References: <CAEemH2fh2goOS7WuRUaVBEN2SSBX0LOv=+LGZwkpjAebS6MFuQ@mail.gmail.com>
 <73fbe83d-97d8-c05f-38fa-5e1a0eec3c10@suse.cz>
 <20190418135452.GF18914@techsingularity.net>
 <20190418143711.GF7751@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190418143711.GF7751@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 07:37:12AM -0700, Matthew Wilcox wrote:
> On Thu, Apr 18, 2019 at 02:54:52PM +0100, Mel Gorman wrote:
> > > > [ 1422.124060] WARNING: CPU: 0 PID: 9783 at mm/page_alloc.c:3777 __alloc_pages_irect_compact+0x182/0x190
> 
> We lost a character here?  "_irect_" should surely be "_direct_"
> 

It confused me too but that was the bug report so I preserved the message
I was given.

-- 
Mel Gorman
SUSE Labs

