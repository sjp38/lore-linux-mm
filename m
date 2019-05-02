Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0717EC04AA9
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 15:24:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2B70208C4
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 15:24:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2B70208C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CD746B0003; Thu,  2 May 2019 11:24:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6576A6B0006; Thu,  2 May 2019 11:24:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51ED06B0007; Thu,  2 May 2019 11:24:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0296F6B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 11:24:43 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s21so1237814edd.10
        for <linux-mm@kvack.org>; Thu, 02 May 2019 08:24:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=iBS5zwJxT8nFucGkSMSXdkpcqVGnsuOJRwGNgRDCJu8=;
        b=iIB2XDZuamkTgJ8YShVCnHbSj13DH/x3gJMpwkk+AN49U5gzQGC8ekahIcc50vOQkl
         AIUtcKJip+cjzoQgbZGJK4ESN4yEZ6vlGXz1iQWF35REgYTgFCPxAZ147+yqx6bpnrkx
         XKZt+hwhYmQkYdEK2yzax05arpbGUivcB/H4uuqt9FHeGHoAyIBaj9dq9fXQoePrj+oj
         bm+Fjb6eOVZwEPS959wuZM7Srz1fKmz9bywNEgJakghVD9lGH5XKPXDi1IeXRegxjjla
         iFLwDITofMhQzNMXouJ9Y7If9A5lrUyMb6n4mhaAxxOkWrr0oPrr9TR7NGpyf8/+KZSC
         qWaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAUfkVmsPfoLMX3MQkNjHh/lOqDK4NKq6ct+lPq1PIDp37TVoEZs
	qfmkwb7KHkNCzFfLj8f9hE+C88JgPVmyrPgsL+8+CROSBKKLRf6BLqTm4I7qlczmZJ5t/aRBbpr
	21Fg0vxbyCjyKSaC/VWw9N2bFqSL5d+ppikx37O18AKHy19jDe1St8+KcseBzkfMVRQ==
X-Received: by 2002:aa7:c387:: with SMTP id k7mr2983775edq.73.1556810682535;
        Thu, 02 May 2019 08:24:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTGikkRl5H09QwLid9xujfs6vDO/+/RLwxXBVMW/ZO6SjAqCO9xOsCKQ5Rl8MMS1km9SSw
X-Received: by 2002:aa7:c387:: with SMTP id k7mr2983720edq.73.1556810681749;
        Thu, 02 May 2019 08:24:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556810681; cv=none;
        d=google.com; s=arc-20160816;
        b=x7gmFHR9q8axSe6Bfz4H1WcR3u3gt3YjknlXUGO9Zy10D+kQM4lQnxNetx0wt6TGxU
         2UeXpT5q4qrPI8f/QP+635Z2CjILeEao6dJXqfpsRRGkGF6iXhoI6J5nyG9KXS4EtpW3
         Bj2VYyQ7aPk126deJhOIqzv615tk3A7UYc94maag03oxMZhQvyUkEyjuvprN8MYOwxQa
         zaNYWsbYjmF2rWM4UP2OkCmbmOlXr/QhYFUPfBfKegmWHW0LIizT1PWbBMN9j2fMc+68
         WAL+JkYNnxqGHoqHsbyQShLFgyfi45beftuhoNzbxY81tNNvOfvHZ/R2hUoAVIngHAkQ
         5RfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=iBS5zwJxT8nFucGkSMSXdkpcqVGnsuOJRwGNgRDCJu8=;
        b=yLK3A06uCMI7HUMre317xD2t3ibxuBwjUxmhyOU2jDbYrnufTiIfHfwwCupzJ7k9qi
         MYIppS3FMrhA//vI35Hb/XSeoI78GqN//gRi4fhPI059BNTlh7HjTGagNMksz5n2egug
         ZoeHEmBJGu8tHtgueqGFaAPm/M3Ltedo8W+cOo7hen8vcJ0CyZFSCs/PCou5oOTkVpQQ
         eefyWkqiVFZRM8zAvhKS303P0wRKuqeYU4bA+C+6gtHV2LG+P6L0frGc5y2mStU5b9ZJ
         jAbAVAy3NT9AabPWFfEHjTFmA8zX1lHpwGPqfI6xtwDBher4j54jcXsHw36sIhqw1wrY
         gyjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c8si1830068ejm.334.2019.05.02.08.24.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 08:24:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 255E0ADE0;
	Thu,  2 May 2019 15:24:41 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id B19061E0D71; Thu,  2 May 2019 17:24:39 +0200 (CEST)
Date: Thu, 2 May 2019 17:24:39 +0200
From: Jan Kara <jack@suse.cz>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jann Horn <jannh@google.com>, Jan Kara <jack@suse.cz>,
	Linux-MM <linux-mm@kvack.org>
Subject: Re: get_user_pages pinning: 2^22 page refs max?
Message-ID: <20190502152439.GB25032@quack2.suse.cz>
References: <CAG48ez3C11j5On4kqwSBCZGtpS5XMohwEyT_2ei=aoaTex7D9Q@mail.gmail.com>
 <20190502014422.GA8099@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190502014422.GA8099@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 01-05-19 18:44:22, Matthew Wilcox wrote:
> On Wed, May 01, 2019 at 06:19:00PM -0400, Jann Horn wrote:
> > Regarding the LSFMM talk today:
> > So with the page ref bias, the maximum number of page references will
> > be something like 2^22, right? Is the bias only applied to writable
> > references or also readonly ones?
> 
> 2^21, because it's going to get caught by the < 0 check.
> 
> I think that's fine, though.  Anyone trying to map that page so many times
> is clearly doing something either malicious or inadvertently very wrong.
> After the 2 millionth time, attempting to pin the page will fail, and
> the application will have to deal with that failure.

So actually, you can still have ~2^31 *normal* page references (e.g. from
page tables). You would be limited to ~2^21 GUP references but I don't
think that would be a problem for any real workload.

If we are concerned about malicous application causing DOS by pinning page
too many times and then normal reference could not be acquired without
causing issues like leaking the page, I think we could even let get_pin()
fail whenever say page->_refcount >= 1<<29 to still leave *plenty* of space
for normal page references (effectively user could consume only 1/4 of
refcount range for GUP pins).

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

