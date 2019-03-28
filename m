Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77901C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 06:58:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 203542173C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 06:58:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 203542173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78A956B0003; Thu, 28 Mar 2019 02:58:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73AE46B0006; Thu, 28 Mar 2019 02:58:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 602026B0007; Thu, 28 Mar 2019 02:58:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1226C6B0003
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 02:58:07 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id t82so1256233wmg.8
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 23:58:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Q1PezP2XQg+mDviVgWM5i24dvdC/8vaYo2tkDH927Eo=;
        b=GhWctcObbxbKeapzEiF8VqkrwFxRPZaPLnE/vU+aXnPwzsfA9ExLX2Qj7ijwQjvmeK
         RwEB4Er5ZV+B+Pj8YtwELqtuMoYO0CtvRZsoPrIddO1KZfUHIjV4illVtToZYqsPPs+a
         ANEFbJQrPK+jcnhDTVaw0ZM/gYi5cnOURVloSPFeGr+4X00981SZft/1E9fdHFXRnQaC
         NpuLEg+MxcVgAO+WM2KAUIXoEstBc/AeuUl5T7FdDJ2A8KtW/FKdd28/6S55Iw8DzZ9/
         4iLi1KJKYGVDfMD+lNsLsA+1ozPRGpy9KugShj1a87bvNVf08C2EgALsN77SN7AYydIK
         OAPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV+fTrduyUNGtFVYj9S+jURo/BLii+rhYQdxeazK0O03My/1EWp
	YGaMT0QEhYoOXTdJoPuiy+yToaflxUm0jV7sLIEtrp/jWG1Ag6xUmvbtnV3p98GMqaLUNsAVGpr
	7C6pMUsAjB/6JQz/uCP5o7LieiTM1pzZOavwx0LPkQtsK1PPWka8ch1HdE832KAs=
X-Received: by 2002:a1c:f312:: with SMTP id q18mr10661893wmq.96.1553756286441;
        Wed, 27 Mar 2019 23:58:06 -0700 (PDT)
X-Received: by 2002:a1c:f312:: with SMTP id q18mr10661858wmq.96.1553756285615;
        Wed, 27 Mar 2019 23:58:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553756285; cv=none;
        d=google.com; s=arc-20160816;
        b=FF2ePbqg6V2MsN8JxiLiTC3PPr88X2QuJSfYAuhmdEa049ouQHDpIus3ARXVwimvRR
         bOdsX6fTryBH7XJ+VmrLhyoiXgOeQtfDhiwwbdKMunqTkZMumk6h1jFJ/5pXpuoJucCD
         a50gZMFsZucFP6xYiE9vwxK+Uzw2ZnYuVxkKootpYdfKYJmqJgLm14EPZNkQvbW/IKNX
         3j5Gv175YCTgzaiagNbaJFKZe6WpgDr2W2Wv9BI6HB+ca6c+LppkjMLiCTuQodxdyaFC
         Qec3StEXYWft34TFsYvwLJFGuuHMXjFsAEJSrVFNUs5voy1dFM4mz+QBqkx5Obt64vKX
         rGpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Q1PezP2XQg+mDviVgWM5i24dvdC/8vaYo2tkDH927Eo=;
        b=sIYOny+2pdz6YXlOkpnlNTNIniYkfJKugh4so3E3S+1rxKcyorOmZ5xajJSCXeq/5E
         Pjqdc6sq0EmmEpGSUCHmfnjmN/IbbQkkCJRM4Y3sZKNDobuBYgkqoz+8n1OMqfd7GDmc
         iGgjt5nnb/vH1jmTXCUO2Q/bGoWtAg4NrOHsDB+WjMtjfaWQAMUaByR6fLT+oJBFxVHl
         4H9CUNgYhaazqUZnrbwdlR7hw9u05nBA6jENKotfR0MSJpJI9Ki8QseOquSqbomhGs65
         1JRW0Fx+QuR5MX/SMCbBFomqZJiV9W0yb1wGrea2PmvqPz7OHuXUNre46XTy6kI0YYp5
         Pzig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 187sor1485396wmb.10.2019.03.27.23.58.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 27 Mar 2019 23:58:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mstsxfx@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mstsxfx@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: APXvYqxEEg6bIrtRVpuuN9OeVJ+wS5PBnn6jxssxAGzZjgcAgnCUtNx+osvmbWfOn0eBECcFZXWlNQ==
X-Received: by 2002:a7b:c00e:: with SMTP id c14mr14313558wmb.110.1553756285332;
        Wed, 27 Mar 2019 23:58:05 -0700 (PDT)
Received: from localhost (ip-37-188-147-215.eurotel.cz. [37.188.147.215])
        by smtp.gmail.com with ESMTPSA id t69sm3211038wmt.16.2019.03.27.23.58.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Mar 2019 23:58:03 -0700 (PDT)
Date: Thu, 28 Mar 2019 07:58:02 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Rik van Riel <riel@surriel.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Keith Busch <keith.busch@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>,
	"Huang, Ying" <ying.huang@intel.com>, Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190328065802.GQ11927@dhcp22.suse.cz>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190326135837.GP28406@dhcp22.suse.cz>
 <43a1a59d-dc4a-6159-2c78-e1faeb6e0e46@linux.alibaba.com>
 <20190326183731.GV28406@dhcp22.suse.cz>
 <f08fb981-d129-3357-e93a-a6b233aa9891@linux.alibaba.com>
 <20190327090100.GD11927@dhcp22.suse.cz>
 <CAPcyv4heiUbZvP7Ewoy-Hy=-mPrdjCjEuSw+0rwdOUHdjwetxg@mail.gmail.com>
 <c3690a19-e2a6-7db7-b146-b08aa9b22854@linux.alibaba.com>
 <20190327193918.GP11927@dhcp22.suse.cz>
 <6f8b4c51-3f3c-16f9-ca2f-dbcd08ea23e6@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6f8b4c51-3f3c-16f9-ca2f-dbcd08ea23e6@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 27-03-19 19:09:10, Yang Shi wrote:
> One question, when doing demote and promote we need define a path, for
> example, DRAM <-> PMEM (assume two tier memory). When determining what nodes
> are "DRAM" nodes, does it make sense to assume the nodes with both cpu and
> memory are DRAM nodes since PMEM nodes are typically cpuless nodes?

Do we really have to special case this for PMEM? Why cannot we simply go
in the zonelist order? In other words why cannot we use the same logic
for a larger NUMA machine and instead of swapping simply fallback to a
less contended NUMA node? It can be a regular DRAM, PMEM or whatever
other type of memory node.
-- 
Michal Hocko
SUSE Labs

