Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B040C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:48:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67443218A4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:48:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67443218A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 019598E0003; Wed, 30 Jan 2019 12:48:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F09068E0001; Wed, 30 Jan 2019 12:48:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFACC8E0003; Wed, 30 Jan 2019 12:48:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9B94F8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:48:50 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c18so117688edt.23
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 09:48:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=FAICS1X5uNueQMhHI3a9DeQr2UwTRU34p4ZwdE7x/Bo=;
        b=UZDG+aAbZg0kxHCHzRft1CZA+arZZNCA2ETN+w8AwXohHMzVBA1ug6tivciRTRv8kW
         VRcvwwriuhMgBfnUj6jGgmQ1PiRT1gdIHU5+7ns/i5T1FCaF70CHVRwkateO1Y0d83MT
         931ncjjM5TDF+fa0OZk9L2jj1obTVEeZR7Ogp+m/earzaorqri3eYVpXySZG3lNC6o1c
         ATHeLHnbhxp6rKwD2ZenocPP9M/3r/ns8Zdfz7M3dlvsRXOnNS1a7Dho+m52D8Li+q4B
         KomZkEi39DvHCV1EpyIa9NKNeD5GuGhfvXRLz53/ztQkEHc7WpUcle6T9Yp8RJoLRK75
         8r9g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdyW7IyPxMnIrE4RGqvTIKPtW1AfgPugSByMGHjqk3iVeb5ZtEX
	jfh6L+RwxuNFw3KXDk+TDzvP0scSbH+Hrz4r0BCroA56sB50UuUd7PEgZi0SxCojT7tNxGitt7Y
	s6yLFN7z5bsDbIK5Qgsx5Me6jVLxlgX4CqFJoSWQDd0FfcH8xwkk5QHfak6kgG68=
X-Received: by 2002:a50:a2e5:: with SMTP id 92mr31299072edm.169.1548870530125;
        Wed, 30 Jan 2019 09:48:50 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7tqWgweYR1kL1linlksrWkAdkxmyRy93Uw353/xZQHJ0jP5e3ZDOvZC6ZSyCMABH7+0VQR
X-Received: by 2002:a50:a2e5:: with SMTP id 92mr31299019edm.169.1548870529224;
        Wed, 30 Jan 2019 09:48:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548870529; cv=none;
        d=google.com; s=arc-20160816;
        b=e7Th/7UWiZc4SnApzpwPxcDEr1NwJb8ftGge10bK2xl4wetR5k4N15GzQyM9kzbJDs
         6npPjjxLSOuEnVHjtrjcOwXAwfBNNOlVhSxQ+HMhk/YxpaSRfeEfVkDzjjtNp5Z5sGKH
         TIylq9dO13RIjb0Wn23I1otNmkgixHDlw1lLmUkVTrmw9Tfr5zCymcPj6gFamOL8HpHS
         QxVoyTiPrKOvxp+Ay+Ksc194yJfhoOxUMfee8Bc8kFgKAEYixZcRyMNGvz+Tt516ykY9
         5E2QVsRYaGir7cZkBzc74Hud1/m3fUP1/0rh9V52VizTdNNFx8mvXAJ9+3scFbOxnxys
         zh8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=FAICS1X5uNueQMhHI3a9DeQr2UwTRU34p4ZwdE7x/Bo=;
        b=z1/2Kch4DXJqY9VxCeknk7809TQgFbDzh6z3tCcxd5Mp2pNdaXuraFeASIBxWzxp7Z
         CA5lIg8rLq1kt2tV6dH1cuIt0EvDpOri3kaYCkQlhyCvJlm4uQBu2j7DPDG+xfhoyAO6
         E7Ey0C92JnZGuM0Jk9z71v9/+zLqLQVrizg3aOoVMX8qZm3tRKaSRD4j2eq6nIR3dKRP
         ki59+6Xu50FMrhVrz5hhhyiDZyFoRjBzWiW3/w5g7fug9zSu8XRuDjU2hPsUBIYXfIs+
         M9IMVc0AfI7ycYSjqMP7Abv3IIfSUpRHjePlKwNTM+pArMAEvr7mcVGeidlYzjaZxwzg
         yg0g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q4si1130930edr.173.2019.01.30.09.48.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 09:48:49 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 77E1DAF96;
	Wed, 30 Jan 2019 17:48:48 +0000 (UTC)
Date: Wed, 30 Jan 2019 18:48:47 +0100
From: Michal Hocko <mhocko@kernel.org>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>,
	linux-nvme@lists.infradead.org
Subject: [LSF/MM TOPIC] memory reclaim with NUMA rebalancing
Message-ID: <20190130174847.GD18811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,
I would like to propose the following topic for the MM track. Different
group of people would like to use NVIDMMs as a low cost & slower memory
which is presented to the system as a NUMA node. We do have a NUMA API
but it doesn't really fit to "balance the memory between nodes" needs.
People would like to have hot pages in the regular RAM while cold pages
might be at lower speed NUMA nodes. We do have NUMA balancing for
promotion path but there is notIhing for the other direction. Can we
start considering memory reclaim to move pages to more distant and idle
NUMA nodes rather than reclaim them? There are certainly details that
will get quite complicated but I guess it is time to start discussing
this at least.
-- 
Michal Hocko
SUSE Labs

