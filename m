Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CF57C10F00
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 13:07:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 077A82146F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 13:07:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 077A82146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AF066B0269; Wed, 27 Mar 2019 09:07:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85DF36B026A; Wed, 27 Mar 2019 09:07:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 773666B026B; Wed, 27 Mar 2019 09:07:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D3C86B0269
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 09:07:13 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j184so14039813pgd.7
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 06:07:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WsY0P3qhN1SUzLhZnmLyDk0wP5NisUxkhKbEELzNIe4=;
        b=JoOU/2mfG6LxY94r1WL7PvN+My6Fa7QWCd+8+NNtl5TyTuISPpYL3rSqHF/DtuTiMM
         kvpiK3kRJpvacy2PiwyRZkEHQMxc6w3JvtNMX3lFU5sXtykZ8VSSb/geGrS5wWhrRFhr
         U8bXmRvaMTZ5ffkGH2E34yoO7A58drZsbTiHhbKhPPNGMLLb816ekROA5VZfGIJNCcCa
         E57LR1vNj+3sVEL0p3udVTuZ/h0SYoYWwFrxFjnJQXRAieMnurY6gv6M51ShWZmciEso
         uSa/XccvdQWeMSxbrFW/suPSUHYzSZTvFip2E2uU2PhDs/SAhA4u7/O3i0MyzSnAs7XR
         RZqw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.31 as permitted sender) smtp.mailfrom=kbusch@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUKi7yOOz6HJsx8IJ5Z6zu8anf7XkSj81Usnd3Ngt7C0/qnQ/So
	Av4unLK/CtG9D5wyzc2hlSunk5VXTSThAduiB2UFF9nkv1RSZC9YASdAt4/vCwRqV9+/DmD6zqB
	dloj2N30i/bevkqAsRlLJuejO73QUFXtAOwqJA3/sgRXGtj04hHZB/z9SB8vJrF8=
X-Received: by 2002:a65:47cb:: with SMTP id f11mr34318098pgs.18.1553692032942;
        Wed, 27 Mar 2019 06:07:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFnJDirgCb1aAkqV9b2BCrXLV2E25IKpIp0YpggRCH+gVHIr0eLDugqoVOpq4eCg8UFoLP
X-Received: by 2002:a65:47cb:: with SMTP id f11mr34318038pgs.18.1553692032278;
        Wed, 27 Mar 2019 06:07:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553692032; cv=none;
        d=google.com; s=arc-20160816;
        b=0yCwBHWVhI8R1ObrMFJUUO78w/n12EmmPJLOSX0pMJbuwINaYNiVvumxX2qPOcbCCY
         RvfT7lZrvo0YNeIuonFtINmxtYx6r09cMdbJ7X3df6ZDFO95cYRdZ0gcnd1MK2h5uoPd
         kL5kxdcfo3keqUWwAFjZgCCaiAlnz7GoavpqFfb0KFPR/wnKyMKmpMqRUKdMhR/IJC3G
         41Xa1SXo1keyXrC2czUdVlqic/a4H2GreYZFQCOXrmb8eiD5UZ+GF0PkXfvMngUI/JpD
         TGrU/BESc+A228F8PXw6Kqxu8acI8J2r/nlk+gtXOWRIAHrEUTbrS1m/YXTWA5GgDQpU
         Gtiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WsY0P3qhN1SUzLhZnmLyDk0wP5NisUxkhKbEELzNIe4=;
        b=HyeUZUjRjo+96ywQBzmCK0yFMYwcmaAAOFoHFcTBWW/0xA4R0L9gSptqHHiwMOlfTs
         rtccn63gHWFVtHcQ6u3GtZOzz/q3a3bHBgKW8oN1hfsHArjtrK/zV3k43/2sEody4zJG
         SoczWGLS32TUClXcnZ/UW4Yy1VpVgQ1KJ9xWyBYIku5WUTAc1OI3As5ELmGBvEZop4x8
         gOzyP6DQs7P/Nq7eiViJPNm4C8j76r1QWb0Uj8SXbtDrIaT54wJcH3KqAsKeqaO0zoZI
         LlOv3q7UJ5uum7+1lGHc1lpCSwA332qmEmtP1wQep2XOoZDsI1Spx7UTK3fsWXZ6Zfxi
         0ooA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.31 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id q64si18984689pga.492.2019.03.27.06.07.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 06:07:12 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.31 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 27 Mar 2019 06:07:11 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,276,1549958400"; 
   d="scan'208";a="331140619"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga006.fm.intel.com with ESMTP; 27 Mar 2019 06:07:10 -0700
Date: Wed, 27 Mar 2019 07:08:22 -0600
From: Keith Busch <kbusch@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: "mhocko@suse.com" <mhocko@suse.com>,
	"mgorman@techsingularity.net" <mgorman@techsingularity.net>,
	"riel@surriel.com" <riel@surriel.com>,
	"hannes@cmpxchg.org" <hannes@cmpxchg.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"Hansen, Dave" <dave.hansen@intel.com>,
	"Busch, Keith" <keith.busch@intel.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>,
	"Wu, Fengguang" <fengguang.wu@intel.com>,
	"Du, Fan" <fan.du@intel.com>, "Huang, Ying" <ying.huang@intel.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 06/10] mm: vmscan: demote anon DRAM pages to PMEM node
Message-ID: <20190327130822.GD7389@localhost.localdomain>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <1553316275-21985-7-git-send-email-yang.shi@linux.alibaba.com>
 <20190324222040.GE31194@localhost.localdomain>
 <ceec5604-b1df-2e14-8966-933865245f1c@linux.alibaba.com>
 <20190327003541.GE4328@localhost.localdomain>
 <39d8fb56-df60-9382-9b47-59081d823c3c@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <39d8fb56-df60-9382-9b47-59081d823c3c@linux.alibaba.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 26, 2019 at 08:41:15PM -0700, Yang Shi wrote:
> On 3/26/19 5:35 PM, Keith Busch wrote:
> > migration nodes have higher free capacity than source nodes. And since
> > your attempting THP's without ever splitting them, that also requires
> > lower fragmentation for a successful migration.
> 
> Yes, it is possible. However, migrate_pages() already has logic to 
> handle such case. If the target node has not enough space for migrating 
> THP in a whole, it would split THP then retry with base pages.

Oh, you're right, my mistake on splitting. So you have a good best effort
migrate, but I still think it can fail for legitimate reasons that should
have a swap fallback.

