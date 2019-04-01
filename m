Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAE1AC10F05
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 07:52:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3F3D21873
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 07:52:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3F3D21873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 430296B0008; Mon,  1 Apr 2019 03:52:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DDA06B000A; Mon,  1 Apr 2019 03:52:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CCA56B000C; Mon,  1 Apr 2019 03:52:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF4906B0008
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 03:52:16 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id p5so3964623edh.2
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 00:52:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8u76RWuslWz/+1eO9L8VcWwCr1NOOKvt1bvBaQnvT00=;
        b=bAXX2UDAK9FAzGaPvOK0BqQmP5uITEOGVSUL4iDG3wtcQ48up8e+iiU7mJLj1AvCyM
         it+bI7/UJIiFoLwkXoheeFCsmY3kn88lmJ27Js1A0kcEK1ETE19roGi1oZ8jjZR+WOei
         kFz/CTOld9fDO3czsn68Uh8SR+zxMmCa9T/4Zt5aCjcgjzyPQ3WgKStFh0UofEpkV0YW
         HmoY3pbvzcaQk/Qj08YukkXUABuY/U6697BRMrB2HYu1uSN019mB0n1KMGySD0h6PLRW
         IP8Si5SlaL8APjhIPBqgqJWmHD/2Wdh3qN24+O/qL9LWKDS77erh4FcCu8g7eoGdsv6V
         jqBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWwrHrPDC5uwmESM8+AjFw1BZJ4l7rnpg7vskrJ8plDzCnwzwWw
	CmKniTeNtfkyrddPwAGqlU2rHbX3OhOpXZ6qSlKd+NKnZDtyXiS4Bi+TEhtJDeQhxE+I1AeQSMr
	moytNIx70eUWy8uqwKTuAbgdLp9HDx/nYdDxa7/+bWZUUYJVoqGAoQC5EBwEwN3H9Nw==
X-Received: by 2002:a50:ad58:: with SMTP id z24mr41825034edc.75.1554105135591;
        Mon, 01 Apr 2019 00:52:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyUBVzsv/UULWfOwyKq3uxjCv1jZnB1GGbvtOi+PcTVNUECijALqb4VCr+Vu4X2H/3Un58
X-Received: by 2002:a50:ad58:: with SMTP id z24mr41824966edc.75.1554105133504;
        Mon, 01 Apr 2019 00:52:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554105133; cv=none;
        d=google.com; s=arc-20160816;
        b=upBHWvk9bThOFAKF8r0T68VMcVuF6u2A6K27HzPefpg/Dv+b5eJ4BjLZYVq30IcEZR
         1LZLW2D9B5i0w00GxXovNoMh3n0kSreJXyOfGdjs22pVUh3o/aZi1sNceMipVZr38mx9
         buc2OFcOr7GtkpOECP7nS2Gq7UdDlHUP4D5M2WPv/u6ObOY4wtaAzoWnSKGSWgdmTLiq
         PotkOnQwXpSuz2vsvVEpKxQONQOYNvfKMcw9hBqrHo7shfKGI6bNJwKAWUEhTUWMRuYH
         Cu50GAAAl4YjI3+FS5QcNRjNtgMtKFabADGgR0v6BVSpOg4j+6cjei+eL9uWCeWfZsZz
         U7ZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8u76RWuslWz/+1eO9L8VcWwCr1NOOKvt1bvBaQnvT00=;
        b=YZLTwwtJS4q5LqojY+w51/c8QoL3xvmwf4WN+SLIQoW0FzrSySppRQmLZy15ny62tB
         2/1hNZ1jE7p57Vhd9u8OEn6aDRr0FLsZfHZSxsZ0qOSwiI8lWuNNwgDJccsS1+hRtlQw
         icVAGgV5ycBJWbrQWyOk3ECLeaZ/vWaSQhCXTnNoqK2mQl+iO6XBW+Jf3enT0B97PNYL
         qJUH6uVwdkp0lS3vqCLoq0kB53EEuLlwY1RXjK1nlsYZBbhfzoviiZt17K2yDtCH+kMi
         PwHYJy321grhm/psCpQvIc2RKfUsE5VAv7hRGzfSjFgb6aY2+rzkml77mRujlduroYO2
         yTHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id e49si722708ede.155.2019.04.01.00.52.13
        for <linux-mm@kvack.org>;
        Mon, 01 Apr 2019 00:52:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 9C2D3479D; Mon,  1 Apr 2019 09:52:12 +0200 (CEST)
Date: Mon, 1 Apr 2019 09:52:12 +0200
From: Oscar Salvador <osalvador@suse.de>
To: John Hubbard <jhubbard@nvidia.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, david@redhat.com,
	dan.j.williams@intel.com, Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
Message-ID: <20190401075204.zaxgmgyrejjaq3az@d104.suse.de>
References: <20190328134320.13232-1-osalvador@suse.de>
 <91cfdf41-ef43-1f18-36b8-806e246538a0@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <91cfdf41-ef43-1f18-36b8-806e246538a0@nvidia.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 03:23:00PM -0700, John Hubbard wrote:
> On 3/28/19 6:43 AM, Oscar Salvador wrote:
> > Hi,
> > 
> > since last two RFCs were almost unnoticed (thanks David for the feedback),
> > I decided to re-work some parts to make it more simple and give it a more
> > testing, and drop the RFC, to see if it gets more attention.
> > I also added David's feedback, so now all users of add_memory/__add_memory/
> > add_memory_resource can specify whether they want to use this feature or not.
> > I also fixed some compilation issues when CONFIG_SPARSEMEM_VMEMMAP is not set.
> > 
> 
> Hi Oscar, say, what tree and/or commit does this series apply to? I'm having some
> trouble finding the right place. Sorry for the easy question, I did try quite
> a few trees already...

Hi John, I somehow forgot to mention it in the cover-letter, sorry.
This patchsed is based on v5.1-rc2-31-gece06d4a8149 + the following fixes
on top:

* https://patchwork.kernel.org/patch/10862609/
* https://patchwork.kernel.org/patch/10862611/
* https://patchwork.kernel.org/patch/10853049/

-- 
Oscar Salvador
SUSE L3

