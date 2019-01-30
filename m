Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87DB6C282D4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 07:52:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 476D821852
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 07:52:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 476D821852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 904AE8E0002; Wed, 30 Jan 2019 02:52:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B3608E0001; Wed, 30 Jan 2019 02:52:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77CB98E0002; Wed, 30 Jan 2019 02:52:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3332E8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 02:52:06 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c18so8815826edt.23
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 23:52:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=c7x4SMFXPn2dFBXJ+43DLuaFcpDG0OarbWOwXaz3zlQ=;
        b=fAB7wR/jJIDjkkUbSArDIkOw6uy07tYQzcPwa22OQCrZwC9QThQ0xy4aXdlE/WNpv3
         AFj6Dehz8xdd75+7/9TH5BeXZNmZccOS6sxTl1YLvyKMi16MltW91IyhRdcExdeueEeD
         +bWeZJ6uV1WUYMzECr8nYnqeIgbca3Vwgqxrpb7Cf7MOK0DLi1ucNWTsHP8XFtqXA3bF
         Vgw8RtO/B9o/a7QqkE6U4M7dd6cfTAjR8roM98MDzMdrFiPhH7iiYQdPz3CVtRft6FDH
         vNJHZsIpCnREXy1cbwrbtT6/AvGbpzzU0+aJFld5nvFy6BISjngwqw1Yonv4J/2sAMTW
         padQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AJcUukcf1llhfmu3knTfn13kSPKA1JeGQOlHrMggeNjiaFM3tTUD54B1
	Szm7XR7YsHBic5wqA39hui73/JotOl7v2Bc891GqBV/XIp7uFPpQ7yb6pU0SPzZ+EEj78Q3U9MH
	8rcKIicdFc59A3gj/TldE6++HTaf8aPqzgTwuckEVP+opb0BJCmwvO/qC5iX/GBtjtw==
X-Received: by 2002:a50:d797:: with SMTP id w23mr29625851edi.19.1548834725763;
        Tue, 29 Jan 2019 23:52:05 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6DT4xgYPkEF6blCA7t4ZOjQyEU/H4EgnqvrUf57+XUNNcFDebrfeYxZcfdN0MqSpxQ7n4G
X-Received: by 2002:a50:d797:: with SMTP id w23mr29625808edi.19.1548834724949;
        Tue, 29 Jan 2019 23:52:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548834724; cv=none;
        d=google.com; s=arc-20160816;
        b=MW+X2fELz8yMD7Rv+pZKYnUlWyYCvT8UKr1wWI516UFQkJ0B5wMUSSNRtvKFNiGJ2Y
         +O55pcHMZioNHc06etRDf1/hV2ZHuBwb40n2aJGvqXRJNeRqeosRimZcNFgd2Egme1aW
         aBJeAE2qS4jc+YztwGt6grF/55qWDb49cIyBLvF5T7NWgWTUgQhMkMWue/xGxjphrrkm
         0CFdeWh26fJcKrqZJBRFsY0O8SNdhURZmZv0zqFwNSsOdnWtlEbhJV9q3QrfaVtNDoxy
         5IcaxJ4+ezpg2Aj9w0lYnFt4WXQNxraUtDNe9pruqW/Ne/lYsrHrc/iYUFrE0aG/NgBc
         LNNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=c7x4SMFXPn2dFBXJ+43DLuaFcpDG0OarbWOwXaz3zlQ=;
        b=fKK1upHLAirrW4+8RfGsXl7d0Foaz9wVa7QuMyrmvj4nDc17xsYydhVB9rKZOQSFKk
         Qu0zbzps/Y0pFR/ILQHdEDt1JWeIoWbZJc4hRA7q7fgEH5kKu/Zl+SsDA4+yrGoMGQT6
         0K6weezRFyCrMhWJ8OSCEhy2CCx9OGmRaigQW677PWWkNSpdc8Cxc5PLtZQNcwza+7uW
         JUjHmw84sm/wLqgRQ2po4IK/MscFXHcxvsd3VqfjJhp04T0z5Hp9oBkMcyuMr1eK9S1O
         6aP1UOx8gz8b7DTVlZVbB8wcx3/CqfE6Riu/5JumfzgJDIIZlsW0EMhdlueOBABBBTBx
         /V6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id b20si605884edr.54.2019.01.29.23.52.04
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 23:52:04 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id B420640CD; Wed, 30 Jan 2019 08:52:03 +0100 (CET)
Date: Wed, 30 Jan 2019 08:52:03 +0100
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, mhocko@suse.com
Subject: Re: [PATCH] mm,memory_hotplug: Fix scan_movable_pages for gigantic
 hugepages
Message-ID: <20190130075200.yauazwxy6s2xb7tr@d104.suse.de>
References: <20190122154407.18417-1-osalvador@suse.de>
 <5368e2b4-5aca-40dd-fe18-67d861a04a29@redhat.com>
 <20190125075830.6mqw2io4rwz7wxx5@d104.suse.de>
 <20190128145309.c7dcf075b469d6a54694327d@linux-foundation.org>
 <20190128145617.069b3a5436fc7e34bdebb104@linux-foundation.org>
 <33fdaa38-6204-bef0-b12f-0416f16dc165@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <33fdaa38-6204-bef0-b12f-0416f16dc165@redhat.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 11:03:56AM +0100, David Hildenbrand wrote:
> Not sure if encoding the -1 in the previous line is even better now that
> we have more space
> 
> skip = (1 << compound_order(head)) - (page - head + 1);
> 
> Looks good to me.
> 
> >  	}

I would rather not do that.
For me looks a bit "subtle" why do we add up 1 after substracting page - head.
I think that doing "skip - 1" looks more clear, but I do not have a strong
opinion here.

-- 
Oscar Salvador
SUSE L3

