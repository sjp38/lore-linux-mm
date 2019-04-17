Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2E90C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 15:30:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DD4C20674
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 15:30:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DD4C20674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7C756B0005; Wed, 17 Apr 2019 11:30:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2B756B0006; Wed, 17 Apr 2019 11:30:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F3496B0007; Wed, 17 Apr 2019 11:30:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6770A6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:30:05 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id l74so16434032pfb.23
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 08:30:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VV4d8N/Ar8bLIiIUepWUD57tvkgJg+Pqd02oCkGTPVc=;
        b=F+wrlpGYBa3aI3AoG9nmPZLuNBvn5k6i7+BBrSTSG4nrp96YoAXtuTmMMugO5On27K
         WivLfWFgnBQ701Ypo0ugv5St/XJHr+fafiw1JD5f5iHhft38v4PnUFn44mHGeZ8euL+p
         eC08IN1IvZSO3ELDqyU6yVIpL7z0k9AHfo+A1+VDP+NNtnMmWQlX0xFKorvQ2w0uRJzB
         4P+U61fi3rXEimtrCTysTV2CF8a8L7eJOqhWkrH5o99K5tFHCAHn7W4PSKdFKFp1XmCA
         pKNu7JQ8aRxk/qjOma1NDiNZUGXckZ2g9w6Odoa43pWRwqg6gCQ11R1qL5AASRsPbOB2
         /R8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWWQnHxsijEOOOaOVRh/ZdeY0nOHv0UpGgyDdVaanHkW9FQBuRt
	faPzw35tM7FeEKkkeG9aeucPZFcVTlqvgkUvKnY+Rg4n0rfRXFW616QafhLIGTrEM12hyIceZed
	DW6bFIDvtMlj5Qu2ju/la63C9398ES9vUTpEkGWDCQNHYsfFp9rCMeKbmUyjAPxkmbg==
X-Received: by 2002:a63:2015:: with SMTP id g21mr81829505pgg.226.1555515004682;
        Wed, 17 Apr 2019 08:30:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHfZQKFQY4cjeky13kOyXvecFOqIMqjpnplixQx3vtJBw9DLxFGzBI3cXskSsVM/pnFa7k
X-Received: by 2002:a63:2015:: with SMTP id g21mr81829449pgg.226.1555515003982;
        Wed, 17 Apr 2019 08:30:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555515003; cv=none;
        d=google.com; s=arc-20160816;
        b=zq2BggmFoztFdD6Tia2ZVnrqqUtPiZTozbZwiEbJBz5sdmksuqkKVE3LP9hKJ4eZnq
         ICDjPyOIX9KM/wz0u5I/e3p5CZk+QcbWRYGK18cjeloYY2zMsGE/wTJNDDwrgImN8C1y
         DXfx8PM9VrSDCdU7weVByL12sU8f+EZlwFhmIzkLbwoAWMsdkLn/UB8vdZZQwMWySxoI
         0cxP8GaviSD7Hi4GgM84+ikt25qiX2zsenC/Ionp+psrvU121xK7f1mv5om6TqXCSl3F
         eDs9Uro5pkU71zKGYugtD+PA92ZhNaWsbOdwcVdaW9Z8kGo2lwP00PcUnk1E6EWc/cwg
         NZ2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VV4d8N/Ar8bLIiIUepWUD57tvkgJg+Pqd02oCkGTPVc=;
        b=lWZ0NS7UpuGdvoiJLkzUQ8E4LzJYhYD50TYq6kD/jy1SdnHRmF54V7w1vMKz+3xj2m
         A3TrqslCXQrWn4NvcYgZPCYCGm2I7krXOzcI1xkXoV+U2RhmpMHQEWPiIOaCNpRkaNcu
         D0frfeWroVHKT8IvX0tVH4bVG0acA2JSdjlcLlf0KJ5uD9rBTXH6euxCgo8sYAvzuCb5
         nDlyFPamkuQ0x9t3z10RFnUUfIeWzxZibKL/Y1XFyDAgZnfK1xZiNJQs6euPEBWhxzpi
         pTbVFJtB0x5z30GmOa5M5vctPMDEQ17j9pBlEUpl8z++Dfzt0Q410i1/sjEkTRvdGh6q
         5P7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id d68si52384054pfg.83.2019.04.17.08.30.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 08:30:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Apr 2019 08:30:03 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,362,1549958400"; 
   d="scan'208";a="292351118"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by orsmga004.jf.intel.com with ESMTP; 17 Apr 2019 08:30:01 -0700
Date: Wed, 17 Apr 2019 09:23:46 -0600
From: Keith Busch <keith.busch@intel.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>, mgorman@techsingularity.net,
	riel@surriel.com, hannes@cmpxchg.org, akpm@linux-foundation.org,
	dan.j.williams@intel.com, fengguang.wu@intel.com, fan.du@intel.com,
	ying.huang@intel.com, ziy@nvidia.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190417152345.GB4786@localhost.localdomain>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
 <20190417092318.GG655@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190417092318.GG655@dhcp22.suse.cz>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 11:23:18AM +0200, Michal Hocko wrote:
> On Tue 16-04-19 14:22:33, Dave Hansen wrote:
> > Keith Busch had a set of patches to let you specify the demotion order
> > via sysfs for fun.  The rules we came up with were:
> 
> I am not a fan of any sysfs "fun"

I'm hung up on the user facing interface, but there should be some way a
user decides if a memory node is or is not a migrate target, right?

