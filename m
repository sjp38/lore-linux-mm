Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE2DDC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:19:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A345D21850
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 10:19:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A345D21850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40BEA8E0003; Thu, 28 Feb 2019 05:19:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B9698E0001; Thu, 28 Feb 2019 05:19:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2839C8E0003; Thu, 28 Feb 2019 05:19:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DD6A28E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 05:19:54 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d31so8306137eda.1
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 02:19:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=51L6dn0BOsFT+/v9OdIFQiwHvarVlEesNMDlIP7OJv8=;
        b=bOq9ZO8tQTwipcLN86ek6Q0S2vYL9JV8Vouamy9ioinJaUrXGH6EYZCy70MGbnLmhk
         021TKjcKXFecrWTcToDiFg4mRf6i9ez6Ifqo1eqNFhYa8Ykh6UwJrdK1KKLyGLt3S7/e
         jSwZpGeGhbqvmcRqUJS597MN5LxBD2gaFxgUCK+x2kU3g55IvRKYj15b6X7AsAsX+znH
         4xcbN5CNiwUGtXE73z/CUph0nR7PefWnM2knt+pVjPXypT3nknvtklI+pk1trkOJrhXF
         37vE1cgw3y8ns7+POUuyxscAH3i6yp7CzmR4aNmqjfgIlD7/wFFfrxlzp/xVfGgzqgcH
         9Xiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAuZRVbrFfUfYWhgIjz3NIUBlTDM6eJAwrd29PVk4nrTU8HL8a7qw
	vTuB3cP5dmulHNyLvEdZGtA+OhDGHhwte69LMMroctdtTEfXGB1IetvcPNDQztgjL/Of9yUWJGz
	97A+Xc8dbuiyqVSo7MdAQ8d+KcoLfJpRo9mDti8YNcSStfoLzV8UYvs8w/Y8h8oNEJw==
X-Received: by 2002:a50:858a:: with SMTP id a10mr6326176edh.1.1551349194472;
        Thu, 28 Feb 2019 02:19:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbF+L6nV224BFAM/Dio+YL8Oy0gO7W/PVGgIGD+OXEFS6w4ZpF+QPYlT3ZI7URahj9SfGtY
X-Received: by 2002:a50:858a:: with SMTP id a10mr6326137edh.1.1551349193714;
        Thu, 28 Feb 2019 02:19:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551349193; cv=none;
        d=google.com; s=arc-20160816;
        b=Z70OR1M/KL0lfM0jNMMW1o5XiapzyBa7ySXeZYR4K7Rvm4gIBUKFeQFpV7utmVOsc8
         E+vl2JlVzRoepIoab/fo+LHvesYz0AF5QjtOXXiXQ4mJ544WYhdCaiJ+7dXTMwlb3sMq
         mIugP4oeEbjYDXazH02nwhkxWNceJcmdx/JGsvYf431cozXi5A1WFb17uBTcEyUJZFkx
         0qMY/bFYLSQtgCTzkXGjNKQ9Xxd3qZqoX2eobqA0f/lPqb5I2Ogbk9CUVRFTK9Mevnu1
         PFfwp2aY77Na+uMIOmHbjO8APm+Kkx9HzC4nAyvsNaL7D1nDzwnaNzFaCuPVno/KT5lZ
         oQ5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=51L6dn0BOsFT+/v9OdIFQiwHvarVlEesNMDlIP7OJv8=;
        b=ihLfCMYI6WZg3sPaFgls/eB5e0VIYI5qQjxyR0Xw/EhEKlRouys/WY8OxLV/A1JWsf
         KDsAs6ezXoBe+Qti3gbrMv80S85Z1NVwygUkudTbvo14/d7lAPOYy3gXbud3TE+XVdgk
         PwsDK5C2/qH156Y8HVS66nFkOR/VMdeegZfpGWX6grBjKWAAUEmMXnyDSBoAz5kp2MaQ
         +KBvgx1/Eg4fyf9XBXkywvdYegosIDSNyMRiMu0rtWDJLNsJzKG1PMMoR5d5o7kTeR8Y
         OqTwERwaaC3RcdYUxGjuobbgTbckaFYLTMDkJ0pJAkxtuJBaRwKN2IsyLgPR2jSSM6Ar
         qa3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id q28si7285878edc.426.2019.02.28.02.19.53
        for <linux-mm@kvack.org>;
        Thu, 28 Feb 2019 02:19:53 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id D6D3F4401; Thu, 28 Feb 2019 11:19:52 +0100 (CET)
Date: Thu, 28 Feb 2019 11:19:52 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, david@redhat.com,
	mike.kravetz@oracle.com
Subject: Re: [RFC PATCH] mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
Message-ID: <20190228101949.qnnzgdhyn6deevnm@d104.suse.de>
References: <20190221094212.16906-1-osalvador@suse.de>
 <20190228092154.GV10588@dhcp22.suse.cz>
 <20190228094104.wbeaowsx25ckpcc7@d104.suse.de>
 <20190228095535.GX10588@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190228095535.GX10588@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 10:55:35AM +0100, Michal Hocko wrote:
> You seemed to miss my point or I am wrong here. If scan_movable_pages
> skips over a hugetlb page then there is nothing to migrate it and it
> will stay in the pfn range and the range will not become idle.

I might be misunterstanding you, but I am not sure I get you.

scan_movable_pages() can either skip or not a hugetlb page.
In case it does, pfn will be incremented to skip the whole hugetlb
range.
If that happens, pfn will hold the next non-hugetlb page.

If it happens that the end of the hugetlb page is also the end
of the memory range, scan_movable_pages() will return 0 and we will
eventually break the loop in __offline_pages().

If this is not what you meant, could you please elaborate a bit more your concern?

-- 
Oscar Salvador
SUSE L3

