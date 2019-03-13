Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70EC2C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 17:07:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 361322077B
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 17:07:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 361322077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B69C78E0003; Wed, 13 Mar 2019 13:07:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B190A8E0001; Wed, 13 Mar 2019 13:07:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2FB18E0003; Wed, 13 Mar 2019 13:07:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 662648E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 13:07:42 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a6so2903251pgj.4
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 10:07:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=7wbdosIc+w4MPu6CTKPq2ztWBkv5puKokgY08m4xKyc=;
        b=Ymn7vCZxPKzXBmJsY30oqs7g3W4cFHHWVuex2WFhmxanJIpgYnQsGXwcalrLSCduBQ
         fA7d2gzw7KDIT8GoVocfNCcjwcSOmbTFJhZixitsey4O2dzSIm0RdDLdckLyvEV9v36j
         UNLft7VpBu5LgWC/fDCd44jY8in0h337kouzwRjCmBOSQ/Cq7mEzVzuXT/zGWIuFIaL+
         ohlsOCYwTLxDACG7XaGVI+FtlGSIYJp48UyfNlF8m3oftnYt7eCLCkjDK1YepB5EonFY
         hX1nLtZKvBMx05cADQlfAmLmAbiMaNmENCVVCb3/Un9kkori+SHLMhKiWjv60uSJuudj
         9fOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVLi/gRqgyILTnEjeploozkDaiu2xlSzEOqioLd0zNsBKvvlgVa
	QDfU/pbP1dE4ITxkDdOYkGz5lzPojU58ymI5iVSzr9E1NCHzjvyBi/Tt4C17W5LiNV67Scv7Xxr
	zY9NBAcjFlKrcFJWDPxzWh9q576S/s5CR1thRjPnYQke5+TuJsTGQNK+PHa1W4wdb6Q==
X-Received: by 2002:a65:44cb:: with SMTP id g11mr41565027pgs.29.1552496861477;
        Wed, 13 Mar 2019 10:07:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7R8EfUxOlwQWsk9vJ++ePImkQS0Ff1X+mH9yXe4Y0gZokUv0LYPvJTBc2/8+JOsrREmIv
X-Received: by 2002:a65:44cb:: with SMTP id g11mr41564932pgs.29.1552496860275;
        Wed, 13 Mar 2019 10:07:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552496860; cv=none;
        d=google.com; s=arc-20160816;
        b=upOjnEWGwaySGXet419fqYRL+u2O/h3+oR3uqaatsUCDMpZSbzrJAcwpX4tLFZnllc
         8u3DQuXUltBr5ErEFX7iY3NvBjVCVjkDuFu3/GuCP2ygFb1+jefCg11RgSA0gtN9e0EB
         SMzZXcN10ZOVDvqEBZRX8OTUhnIE/uuQFna3eyX6wpSr9d0keCJNFfS+tGhF3uF7jnuS
         RjBDiT6TE4sJc8jw1in+T1z5aLSE5bLlcwF/H30dAod72vz4VLCpvebTGYMms67QA4dQ
         knA618kGl1bMov+IQ2dHdt8XFF85mzKi0FclvESqm8u7g/ezmGfNC0TLodHXKaOKaGo0
         7aEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=7wbdosIc+w4MPu6CTKPq2ztWBkv5puKokgY08m4xKyc=;
        b=MzDAA4zHYQztgceP6UWaAetDXHIpLwKsQv2+gN2xfi+f2DpWZglVabtsdTXp0CtM9s
         exyHiYtwscpu0AR5u9qWPKAFclXXTsE5TvrEQFs42fz1v5hpxts2M0Fvt8ce1tNpVIPN
         3Q3cL4jKnX/iyM0BfwN9I8GV9Nzmmup+QgkIB2xwZPHm6OfI6DT2PAHGwADmytiWSsAR
         2z2YQ/oaAni2eipvxKis/C7pOJ/tf+A83iCiW0qt9ztrUtrmsPgqE0NVCbnXAVowZCzp
         po7N2+6EzepripfwnjoVAOww7jXqPPflNSXKw0Syw00HYYSbNlcuMlsnqscvaLVlmvhz
         cXaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id z8si10120655pgu.224.2019.03.13.10.07.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 10:07:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Mar 2019 10:07:39 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,474,1544515200"; 
   d="scan'208";a="126649122"
Received: from ahduyck-desk1.amr.corp.intel.com ([10.7.198.76])
  by orsmga006.jf.intel.com with ESMTP; 13 Mar 2019 10:07:39 -0700
Message-ID: <e1d108a27d8f532e147c860ee64db6a07ed87040.camel@linux.intel.com>
Subject: Re: [mm PATCH v6 6/7] mm: Add reserved flag setting to
 set_page_links
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, 
 sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-nvdimm@lists.01.org, davem@davemloft.net,
 pavel.tatashin@microsoft.com,  mingo@kernel.org,
 kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, 
 dave.jiang@intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org,
 vbabka@suse.cz,  khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com,
 mgorman@techsingularity.net,  yi.z.zhang@linux.intel.com
Date: Wed, 13 Mar 2019 10:07:39 -0700
In-Reply-To: <20190313093306.c4b49c6d062f506a967f843d@linux-foundation.org>
References: 
	<154361452447.7497.1348692079883153517.stgit@ahduyck-desk1.amr.corp.intel.com>
	 <154361479877.7497.2824031260670152276.stgit@ahduyck-desk1.amr.corp.intel.com>
	 <20181205172225.GT1286@dhcp22.suse.cz>
	 <19c9f0fe83a857d5858c386a08ca2ddeba7cf27b.camel@linux.intel.com>
	 <20181205204247.GY1286@dhcp22.suse.cz>
	 <20190312150727.cb15cbc323a742e520b9a881@linux-foundation.org>
	 <4c72a04bb87e341ea7c747d509f42136a99a0716.camel@linux.intel.com>
	 <20190313093306.c4b49c6d062f506a967f843d@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-03-13 at 09:33 -0700, Andrew Morton wrote:
> On Tue, 12 Mar 2019 15:50:36 -0700 Alexander Duyck <alexander.h.duyck@linux.intel.com> wrote:
> 
> > On Tue, 2019-03-12 at 15:07 -0700, Andrew Morton wrote:
> > > On Wed, 5 Dec 2018 21:42:47 +0100 Michal Hocko <mhocko@kernel.org> wrote:
> > > 
> > > > > I got your explanation. However Andrew had already applied the patches
> > > > > and I had some outstanding issues in them that needed to be addressed.
> > > > > So I thought it best to send out this set of patches with those fixes
> > > > > before the code in mm became too stale. I am still working on what to
> > > > > do about the Reserved bit, and plan to submit it as a follow-up set.
> > > > > From my experience Andrew can drop patches between different versions of
> > > > the patchset. Things can change a lot while they are in mmotm and under
> > > > the discussion.
> > > 
> > > It's been a while and everyone has forgotten everything, so I'll drop
> > > this version of the patchset.
> > > 
> > 
> > As far as getting to the reserved bit I probably won't have the time in
> > the near future. If I were to resubmit the first 4 patches as a
> > standalone patch set would that be acceptable, or would they be held up
> > as well until the reserved bit issues is addressed?
> > 
> 
> Yes, I think that merging the first four will be OK.  As long as they
> don't add some bug which [5/5] corrects, which happens sometimes!
> 
> Please redo, retest and resend sometime?

I had gone through and tested with each patch applied individually when
I was performance testing them, and I am fairly certain there wasn't a
bug introduced between any two patches.

The issue that I recall Michal had was the fact that I was essentially
embedding the setting of the reserved page under several layers of
function calls, which would make it harder to remove. I started that
work at about patch 5 which is why I figured I would resend the first
4, and hold off on 5-7 until I can get the reserved bit removal for
hotplug done.

I can probably have the patches ready to go in a couple days. I'll send
updates once linux-next and mmotm with the patches dropped have been
posted.

Thanks.

- Alex

