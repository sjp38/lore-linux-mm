Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C6C7C76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 08:08:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 576982077C
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 08:08:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 576982077C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC60D6B0006; Wed, 17 Jul 2019 04:08:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C770B6B0008; Wed, 17 Jul 2019 04:08:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B40F28E0001; Wed, 17 Jul 2019 04:08:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 660276B0006
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 04:08:07 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c31so17519655ede.5
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 01:08:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bSe6jT5AlnN4CxeOW0Z9Ofq355E0bRiEgXUhvKAHPVE=;
        b=Pq42D7UGGRWZP9/Tmfm06rw3i+lW7vVDN7PAW30SlckzJz/meHrUHD7nZ2mKrGp/kC
         X1uQ1+iupQJvPSmtfbchgNYmbOaaoPznV/OoAiNM/hPc97RE0Bn65eiM1IWx+pDCv6u2
         jxmV+wIsk/6pexzBOEyX03ZJYVCy6DI81Yl1uHlI7JEel1gEyFiPrBxHmXQktFcqN2Gp
         iVfFrDzQrCzlrkpoKdXSvbehUeuHZrzE3V+q2c2mFk9iEESUF93Q0VgNQxIlQeZAJ1m5
         El6LgQhFbp9D8WZj9ntJb4xjn7yXVjUqBxJ/6Fgdxf1P+AG0/G/yvfYqxpOZXbByQrSA
         it6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUkSGUkoqDldc6sTFk2AJDXXPWfj5v4w/LTp7ZgVoE53gLtCUgG
	lDQVdTV86zDtrctpwFPKJnmUw3U3sfvDJHpkGcV50WfiLyHboFCDwdnwXpuYgy+c3rxO3TB1GmP
	VlBHEZx/V4QcbKqRuRM/5xw03nMbkAl5oxg8QDR5fcxSSk1OdvLj5XAsnRMp42lOTSw==
X-Received: by 2002:a17:906:4a10:: with SMTP id w16mr29737132eju.299.1563350886985;
        Wed, 17 Jul 2019 01:08:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEeFJvauOc3jwjjJ07OagTESzM3WPLEWE+luAn4+LhmeqaL2CtaeVNpXyWwJW90TZvE284
X-Received: by 2002:a17:906:4a10:: with SMTP id w16mr29737092eju.299.1563350886307;
        Wed, 17 Jul 2019 01:08:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563350886; cv=none;
        d=google.com; s=arc-20160816;
        b=q+jKUoDDJX39zUQ3RIGriFIVoZER+Pxsydn+QPYmflyM0x8IoUCZYD26NkLVFk2n1O
         yVEDPB4ICCSTzAWjv+PAs97dLkhNeLMObUcs8Arj2FPRmgOwvj2SWihBfAYgbBecrw8z
         NoX+d6pOwUbTJE6Fym7WMbu/LiiQfSSoK2Hj10+K5KhPVBD866mVHFMIk84gOJ317w3p
         Rf2E4NC6R/QoMgBpyIaFhJE0AB13ZS7nGuB1oXZkqIP8Jtw/QsPvZu6U3SCdUMxZpWv8
         AkuMGIOghzoAHe6HbE8I8RbnYrTVIVzqsLP8HSom1OSVMwmeb/tW9bPPDNYFVy1QZ1Pw
         PKWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bSe6jT5AlnN4CxeOW0Z9Ofq355E0bRiEgXUhvKAHPVE=;
        b=geBI09MgW5Dh42Pm2Gy+4cIe7lSw208ZfHcw1Yk8a4dsjgcWhy7e4bQsBX7dvSiW9a
         5Wnwiqr8YmfLrvB8zCdAqJ/2SsBQzAWQ0PYTJ0RLH7Z+ojy0dhuiAhpxH1YJqwoA+BNa
         LbZOW4Xnu6mmrOEKKCuEjgUGfUDH2aFiqrE49X+RgtnTurn16u7wIU/rzrtHdLfle/RB
         RowWx3l8ad5OT/ro72UcB7KL5KurtAWtyAMKqc/Eo7qPTBgENZtdXx7lmcrZlKZ6FFAk
         0zcjzS4D1aL5tfMiTkkIC3LQhLYVUxCWSuODvY8WPlGqwEoFd9TPorJOYvg8IwsxWJdB
         EjrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g27si12687761ejc.229.2019.07.17.01.08.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 01:08:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B73E1AE37;
	Wed, 17 Jul 2019 08:08:05 +0000 (UTC)
Date: Wed, 17 Jul 2019 10:08:03 +0200
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Michal Hocko <mhocko@suse.com>, Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 2/2] mm,memory_hotplug: Fix shrink_{zone,node}_span
Message-ID: <20190717080755.GA22661@linux>
References: <20190715081549.32577-1-osalvador@suse.de>
 <20190715081549.32577-3-osalvador@suse.de>
 <87tvbne0rd.fsf@linux.ibm.com>
 <1563225851.3143.24.camel@suse.de>
 <CAPcyv4gp18-CRADqrqAbR0SnjKBoPaTyL_oaEyyNPJOeLybayg@mail.gmail.com>
 <20190717073853.GA22253@linux>
 <da07d964-fcfa-1406-bc12-faebbe38696e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <da07d964-fcfa-1406-bc12-faebbe38696e@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 10:01:01AM +0200, David Hildenbrand wrote:
> I'd also like to note that we should strive for making all zone-related
> changes when offlining in the future, not when removing memory. So
> ideally, any core changes we perform from now, should make that step
> (IOW implementing that) easier, not harder. Of course, BUGs have to be
> fixed.
> 
> The rough idea would be to also mark ZONE_DEVICE sections as ONLINE (or
> rather rename it to "ACTIVE" to generalize).
> 
> For each section we would then have
> 
> - pfn_valid(): We have a valid "struct page" / memmap
> - pfn_present(): We have actually added that memory via an oficial
>   interface to mm (e.g., arch_add_memory() )
> - pfn_online() / (or pfn_active()): Memory is active (online in "buddy"-
>   speak, or memory that was moved to the ZONE_DEVICE zone)
> 
> When resizing the zones (e.g., when offlining memory), we would then
> search for pfn_online(), not pfn_present().
> 
> In addition to move_pfn_range_to_zone(), we would have
> remove_pfn_range_from_zone(), called during offline_pages() / by
> devmem/hmm/pmem code before removing.
> 
> (I started to look into this, but I don't have any patches yet)

Yes, it seems like a good approach, and something that makes sense
to pursue.
FWIF, I sent a patchset [1] for that a long time ago, but I could not
follow-up due to time constraints.

[1] https://patchwork.kernel.org/cover/10700783/


-- 
Oscar Salvador
SUSE L3

