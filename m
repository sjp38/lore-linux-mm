Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28B49C04AA8
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 06:45:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB61D20651
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 06:45:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB61D20651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2526C6B0005; Wed,  1 May 2019 02:45:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 203336B0006; Wed,  1 May 2019 02:45:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F2EF6B0007; Wed,  1 May 2019 02:45:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CE0156B0005
	for <linux-mm@kvack.org>; Wed,  1 May 2019 02:45:13 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id o8so10462989pgq.5
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 23:45:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=uYhixpbQX03XTrLnqfSwhW+jaKrgaIjFNeW3Pd+RhQQ=;
        b=pzV6MxvUghwTYlaZAOetVq3zwFuiGd+zf8EImlinrNr+bUEATg17AdmGLfwB133PVK
         ZYGwUkWezEmHtvHdrgExGIGB2rhM/rnCpjKUjLIbeCSRSl0X65GtRgSVpS0xjmfBz0wx
         V1Z2sFvijrSlJY+Wv5pnQGYzIIfI3anfogVuo5Scx4GK/skxDU5nSsSmjn4YUjgpviYd
         FR60UH3vg/6lOFR5VwXG3MZMzjWYomPZauuippWyU05bGpLy0P5ioaW59jA1VEUy51RA
         B8u2zXuqYQqQLMdbnCagHMU0NymgFbQvetZG8kjk7Jp8r7O00/DCZd/JhPWfOhJZRmvS
         XtPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUk/1jv9XQYA9McjyhtRCbo5ol3khXPMtbA03nHZJwBUPDKdpeX
	bmLCOJEXUwoqIx1w652jHhPoevIMYrLUtTgv8OOqTvLc/n8jdHIWgiEVTeTDwGt/cG3Oh8v3l0y
	DkS4YSEbxY0BQk0teZ7aMv4cKZQ26eeryI5DyaWyBdsu7SXsIhB60oySlU4qRbrHBVQ==
X-Received: by 2002:a63:e304:: with SMTP id f4mr72137593pgh.374.1556693113506;
        Tue, 30 Apr 2019 23:45:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyByQI3aTJECcF/h+k9iRewufKCUrFr6s/8QhMGl5xpG6XGuIepg+um6knQ9rfZ/0Q5khnn
X-Received: by 2002:a63:e304:: with SMTP id f4mr72137541pgh.374.1556693112746;
        Tue, 30 Apr 2019 23:45:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556693112; cv=none;
        d=google.com; s=arc-20160816;
        b=ed3yK6e3D/19G8gCjNDAJCCJgPQ2DKp73Ib5rEIu01FG9m5Uaoxb4Iw4RRSgxloGTO
         VSw34jUwaV4PCo4xjMGkv/mWFw0XjBTvPSKpfWdaRuxfavaH4Y+4X6mAGzfG/Kx3v4A2
         pVfZr+E5idZnsg4MQCTzbzug8C99nMPgU3MSbP9VDaEph+iLUmQ3DEPfTWTIL9yIocyp
         pr7ugyre/juNfO76pxpaZcZRxOzDY0w3N5GnJDIQsNb0k8XBTm3a/RdAu/6UjK7z9RG6
         0E//hswX1zkILHn6VOh0z5EGhYK/nvluZ6q2jdOrTKqVS2eM1LyNQBk1kr1Sc5I1f9mJ
         GDCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:message-id
         :subject:cc:to:from:date;
        bh=uYhixpbQX03XTrLnqfSwhW+jaKrgaIjFNeW3Pd+RhQQ=;
        b=JXmsGb2QXTEg7rgAr5vldp+zP/p3kJPJZuclw2Mzfycva3N8paj09ksK8qpdiefqv2
         k9EPipd5kKFsm+9RMtLTRbZ3xgi26cn4bUNqTkkx/ylNlOtK3DQ0KcIOsAh5QIdOF5lS
         1/NwuP9D4l2Yw0QBQdAnhPYtaO6CYPfXXm26zbOJvMlHwRTFWYjV4nPjQPNVgb7SZR+8
         GVSF7FffD3fA3JvEEN1h+IgJWUDuqqEMtO3SLQumWGqRQ/PVHHAwP4InPr9Xs/07wLja
         q8vNDAeyWIH5iybXSad3Y28XTa/auC3eYA1fySTANradb8+XJT0S8dur3l2bcbhc75De
         uJFg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f6si43189749plf.90.2019.04.30.23.45.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 23:45:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 Apr 2019 23:45:11 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,416,1549958400"; 
   d="scan'208";a="147194485"
Received: from lixinshe-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.212.94])
  by orsmga003.jf.intel.com with ESMTP; 30 Apr 2019 23:45:01 -0700
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1hLixs-0001t9-M9; Wed, 01 May 2019 14:43:36 +0800
Date: Wed, 1 May 2019 14:43:36 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, mgorman@techsingularity.net,
	riel@surriel.com, hannes@cmpxchg.org, akpm@linux-foundation.org,
	dave.hansen@intel.com, keith.busch@intel.com,
	dan.j.williams@intel.com, fan.du@intel.com, ying.huang@intel.com,
	ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190501064336.jktcqkvz27ihpqh3@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190417091748.GF655@dhcp22.suse.cz>
User-Agent: NeoMutt/20170609 (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 11:17:48AM +0200, Michal Hocko wrote:
>On Tue 16-04-19 12:19:21, Yang Shi wrote:
>>
>>
>> On 4/16/19 12:47 AM, Michal Hocko wrote:
>[...]
>> > Why cannot we simply demote in the proximity order? Why do you make
>> > cpuless nodes so special? If other close nodes are vacant then just use
>> > them.
>>
>> We could. But, this raises another question, would we prefer to just demote
>> to the next fallback node (just try once), if it is contended, then just
>> swap (i.e. DRAM0 -> PMEM0 -> Swap); or would we prefer to try all the nodes
>> in the fallback order to find the first less contended one (i.e. DRAM0 ->
>> PMEM0 -> DRAM1 -> PMEM1 -> Swap)?
>
>I would go with the later. Why, because it is more natural. Because that
>is the natural allocation path so I do not see why this shouldn't be the
>natural demotion path.

"Demotion" should be more performance wise by "demoting to the
next-level (cheaper/slower) memory". Otherwise something like this
may happen.

DRAM0 pressured => demote cold pages to DRAM1 
DRAM1 pressured => demote cold pages to DRAM0

Kind of DRAM0/DRAM1 exchanged a fraction of the demoted cold pages,
which looks not helpful for overall system performance.

Over time, it's even possible some cold pages get "demoted" in path
DRAM0=>DRAM1=>DRAM0=>DRAM1=>...

Thanks,
Fengguang

