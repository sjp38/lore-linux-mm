Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BCA2C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:35:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12067217F5
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 12:35:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12067217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B5DED8E0003; Tue, 26 Feb 2019 07:35:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B0F6F8E0001; Tue, 26 Feb 2019 07:35:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FDA68E0003; Tue, 26 Feb 2019 07:35:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 58F5C8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:35:23 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o9so5383510edh.10
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 04:35:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PqySPpNOMPzhLAHTb7fy2TggBB1kt/Lo9nRtUY3jyZk=;
        b=D1IyR948C4L7J3iBK9Y9RqrhlwPlO64H0GO55Jro3WdShV9fzekhhNvUKXYUBNQ90E
         5h5/Q7A8iIHVmcmbuutGrk5pbEthI6pk8WxxxNYQvMknkwhvSIExmXl6op/uhi+J/mqN
         whA9oRrS7ZccyNE2o4qYCe+xJON4KpfJsE793UEMd2GtTUB5OdN5L5MG8aZ7wYlSqk4a
         98+ieieDxHHp3hjRTzG1dYGgY/TqCDRQ/5eF2SzGrKEFdSMjzr2WGhu3K57mkysJTVgO
         CWEx9/bvF/yM92WfsIetKk2cwvlL+vynp5KyWxGTTpSoBRpWKU53LJ5v2OHVww3KUst4
         Yv7w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAua57Y6g97VKkWnqt4bhFCSgd9e5hkQVFs16zs6StcGkFds/ZYUy
	Oy9SpzYK4Lbq9bYbCXWRoki8OOI7/A8Mt3A49sf4gbgFQqq6cEMCegT6eB1KCgRls86slwxw6dP
	mu7aPc4rcMMVIGqXtO84wJZgr89rVqfkSlIONmOWgjxA7ac0Ik4++i/Z83Mrqnyw=
X-Received: by 2002:aa7:d7cc:: with SMTP id e12mr8644627eds.276.1551184522913;
        Tue, 26 Feb 2019 04:35:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYBtblhOn0MjTc+u8AWMnJ44C1bLwgQpxrXC8Xz64l0M39yK4QW/urufr7a7qpb392IzHsm
X-Received: by 2002:aa7:d7cc:: with SMTP id e12mr8644586eds.276.1551184522173;
        Tue, 26 Feb 2019 04:35:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551184522; cv=none;
        d=google.com; s=arc-20160816;
        b=brwgDKi+/Yy0ufx7Mb+qE0sPNV4XouiVKUYLEAyO4tfee/svbcaRd8Qv8Z4tnqE+Dc
         zOCaPnOvWPBQLIvWeWLwoo66QN9z88WAwxR88vrQTuItoPXLNnJ9hwbfD4yIjYgyiSZR
         ZrBgKuMhoO7maHk11yGi/kkfPzoM08QPHp1LPC8SLahylD8XL7PN5f5qli1QCTZX4cZx
         YrmK/ncJ0QQdVjI2ZcAHW+i2Yj/594IT0+cPMvy0DJN49TUA+pqdIBCr4bokoJMfKrBy
         LE5+eHTiiJ4blj82FwoMsPIoZrOGt49H6KKUT5VZgo7um/i+6pqCeV3bqIOcjJ2sgjVs
         ALbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PqySPpNOMPzhLAHTb7fy2TggBB1kt/Lo9nRtUY3jyZk=;
        b=lWJPfekOTT/F/coAuk77qM0y9d5yb7D8D0lpgtiPYQbpxOFmrMttC9otQYfWp3ytkv
         A8uPEQJXq1ou5FTpg7i4x2kaTvtJaWAWMfyEEPvOt+gfmPItNlC0GEzroWjTp4P01W8k
         +53DmxCXr4Di8u78YEKTRym772FuPP4lg3z0sbgvZK7U5vSxHZkxoR4UCuLWQimreDQ0
         rkkkOCIdL1koHUY4MoBbzuiU4/F97kA+DovvJTXfwcrsecQajD/1t87oD1w72fyFdnSx
         U0UtV/v5bclQZnpcVu+elGSHfxxHxlCl1KOHbqC5HCExGr7BcMpwPXyfEQl4GtMRbxP7
         Xm4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j14si302103ejt.254.2019.02.26.04.35.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 04:35:22 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 85013B603;
	Tue, 26 Feb 2019 12:35:21 +0000 (UTC)
Date: Tue, 26 Feb 2019 13:35:21 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/hotplug: fix an imbalance with DEBUG_PAGEALLOC
Message-ID: <20190226123521.GZ10588@dhcp22.suse.cz>
References: <20190225191710.48131-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190225191710.48131-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000038, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 25-02-19 14:17:10, Qian Cai wrote:
> When onlining memory pages, it calls kernel_unmap_linear_page(),
> However, it does not call kernel_map_linear_page() while offlining
> memory pages. As the result, it triggers a panic below while onlining on
> ppc64le as it checks if the pages are mapped before unmapping,
> Therefore, let it call kernel_map_linear_page() when setting all pages
> as reserved.

This really begs for much more explanation. All the pages should be
unmapped as they get freed AFAIR. So why do we need a special handing
here when this path only offlines free pages?

-- 
Michal Hocko
SUSE Labs

