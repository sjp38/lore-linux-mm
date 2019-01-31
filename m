Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66563C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 07:23:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 391E5218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 07:23:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 391E5218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9740C8E0002; Thu, 31 Jan 2019 02:23:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D20A8E0001; Thu, 31 Jan 2019 02:23:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 799408E0002; Thu, 31 Jan 2019 02:23:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 349848E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 02:23:22 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v4so880943edm.18
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 23:23:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7jT9VnJjXX1MderniI1KBVdCrRcARCPzGmp+M9eBT0E=;
        b=kTNZpv3kziOUyVM87XQ5vg0g6jaQOvu8EayrG+P0AJbXxgOUXkprkXb477MuEMIY7w
         HIkkM60ggVOefvBIARMjMGOUkSiHfa/6SUFg2+Tfaq7qs7sBLKHWRSHdKiRqCVjItQ2Q
         ZjBrOMa9O/Emz4Yy1w+f4tDdEdSu/JfC0lb+Tyan35C20C6FK4Q0iTNvGEb3ec6GW0b1
         p9prYaBI2MCDOrl+mvUv1aA8tsyTQxjChML2pQHIltMfefOR+0AUgFYhvcJXT11cE33m
         KHxh5+qpk6iCK04OC8tKRzpzfPQAxq88gV6sN8OIpZwTx/murmzwKLoM8Rya5lGvAS1+
         myrw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukdOK3zBlaoBcy++VCPX7ASovATJ8gKf7Uo9XhM0tMNUwIbVJwqT
	w/FmZFIacHmz/72+B6TYQIEX3fbu9IFIKWRq76RXi65O31RnFB7U9yJqUw+Ojq7sxfs76rIdTzD
	f8ILGlVs6W2ez0fAV74rZrbKmmRXcHUMUwE+f66CQVgetaS3LPvWZvzXByvnoacE=
X-Received: by 2002:a50:8bb5:: with SMTP id m50mr32528455edm.211.1548919401762;
        Wed, 30 Jan 2019 23:23:21 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5+1MeNb+xbHYv/RZhIS0RxCBvz5RW0PyE4H6v6z6OqDX3QMh8sGHy0kiw+aBM0twedRcmb
X-Received: by 2002:a50:8bb5:: with SMTP id m50mr32528415edm.211.1548919400993;
        Wed, 30 Jan 2019 23:23:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548919400; cv=none;
        d=google.com; s=arc-20160816;
        b=zKQtFwLXrJqWenNppMKyg8veymM7tO1bZhvd9zOCY/6iJT1CBJCb7qkhIVz9m8rJAJ
         hxGnBPzEvBpOS7O1pp/Rv3i6+oFX1mTDXiebn96E/NMOUWmeELraO6azaFmhv+Dy3D0D
         0QLZxCR9jjKh645n6SjojITxWfJTU11rzg07HaQDX/uyNuDKBhAOqu/F/Oqf1gKXxOpR
         DzPIRjXlRLD6evnWGQK5v5isaOxvE3nYa2yaO0qhnE/qncimu3Fc1KQzo1UINJ2eJZCo
         COokaTjtWD0+cSvldl0zLWiCjhmJ0I4zGyOuSL0bzlzbNpgYbQyRirkA3WVVQj52zd15
         tylQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7jT9VnJjXX1MderniI1KBVdCrRcARCPzGmp+M9eBT0E=;
        b=GBecP7JkwGA5Bbd8U57bSQA6zqU1Fn0q0UXc4nls2ijqLciIzULvSKvXAaFzFRqnWt
         pMVasxVttuGMU0N5WKa4OXCwyTr6gN+ZWnTz4yh8kQRHC+cqqg3YMWJJJhsKsFtTwR2x
         rFnPyedO8oUq1jRzP9L6ObPy+CwN2nZ8aaUVrjWapAlgHLcBGFJQs5gt9s75W7Ow9AJL
         ma+HiJUQNMPIbPO7QEG09oqgqWk19jDxPmPlch//TDKMFbSJ+AelPGJ+FmPUCqWhp5qW
         g2FTnkSZCTj8/nA9cB+lALgt/68FB0pBXk8CogHCe7DuCWTXzayP38FpBu0oor1qd28+
         aVDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x32si2035764edc.425.2019.01.30.23.23.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 23:23:20 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1502FAFC7;
	Thu, 31 Jan 2019 07:23:20 +0000 (UTC)
Date: Thu, 31 Jan 2019 08:23:19 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: linux-mm@kvack.org, dan.j.williams@intel.com,
	Pavel.Tatashin@microsoft.com, david@redhat.com,
	linux-kernel@vger.kernel.org, dave.hansen@intel.com
Subject: Re: [RFC PATCH v2 0/4] mm, memory_hotplug: allocate memmap from
 hotadded memory
Message-ID: <20190131072319.GN18811@dhcp22.suse.cz>
References: <20190122103708.11043-1-osalvador@suse.de>
 <20190130215159.culyc2wcgocp5l2p@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130215159.culyc2wcgocp5l2p@d104.suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 30-01-19 22:52:04, Oscar Salvador wrote:
> On Tue, Jan 22, 2019 at 11:37:04AM +0100, Oscar Salvador wrote:
> > I yet have to check a couple of things like creating an accounting item
> > like VMEMMAP_PAGES to show in /proc/meminfo to ease to spot the memory that
> > went in there, testing Hyper-V/Xen to see how they react to the fact that
> > we are using the beginning of the memory-range for our own purposes, and to
> > check the thing about gigantic pages + hotplug.
> > I also have to check that there is no compilation/runtime errors when
> > CONFIG_SPARSEMEM but !CONFIG_SPARSEMEM_VMEMMAP.
> > But before that, I would like to get people's feedback about the overall
> > design, and ideas/suggestions.
> 
> just a friendly reminder if some feedback is possible :-)

I will be off next week and will not get to this this week.

-- 
Michal Hocko
SUSE Labs

