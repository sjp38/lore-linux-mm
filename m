Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC173C4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 14:32:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6588021736
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 14:32:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6588021736
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 000E58E0004; Mon, 18 Feb 2019 09:32:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF1C58E0002; Mon, 18 Feb 2019 09:32:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE3078E0004; Mon, 18 Feb 2019 09:32:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 841908E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 09:32:07 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d9so7252336edh.4
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 06:32:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=Lufzklt6eenbIpKvnSwz+uyUxZlQqOKkZcA+/w/mdjg=;
        b=ixhUQYdjp2bljsQ23k9bPb9eOjAha0nxC+yWBGGwFpce8OxMw/D9gpDfY1o0yZjknq
         UN+Tozl8kww/nVhffZPLAXP+Ln7Pz8tAO/BzRyp47Ue+4+yj+g8u2VHlsfX0OmCqTtVQ
         J9xrqKfqKZyHxiFg81+mHLSXMdg47e0AUotN54lDHY0wAniVqdh9RzCwFUqnWudTz+P+
         kw1hjDEAGH7AGlIEGiTnOnn9+9ePCwJfG7yNl8smG3NvpqM/fn7oPt1xpu6ntMvAyX3d
         Pz7P8E7y5AKE/s4jolhEclmTvVUsOXMIdQv3coR+wX6J7HyOwc5ZJ3MAtC3klC+kP013
         PyYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: AHQUAubqDIfGUT8+RfL/UQI6e1Oe1lpzLN6CJvioadA7NBibstz8m1qh
	ene3FC8kJOkSlxFz+Ywi71JCJrP8ZBuN6JwMGhyS4wyimkvs4kw9YXFQXmGbOHGDoFB6icHH9tx
	2sqmTldgtEvMWgU8HAXcz6JKAnyHRW0P9/MFimBMWith3EXnOvBkDgciUdtJyOOdd2Q==
X-Received: by 2002:a50:ac55:: with SMTP id w21mr19515838edc.121.1550500327004;
        Mon, 18 Feb 2019 06:32:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbJ3yXMRNnIjL9OXcLCJMQjMRVK2Glo3SCYjY0VMD5J1YOzJ35S+lcqYL1J68M02OItPcbS
X-Received: by 2002:a50:ac55:: with SMTP id w21mr19515775edc.121.1550500326054;
        Mon, 18 Feb 2019 06:32:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550500326; cv=none;
        d=google.com; s=arc-20160816;
        b=ZhAnG44UOFz78kQGnysDfTjisMvKwgvNuX6hBriGVlO93j/8Nnxs0cnukgmYHN6s3X
         4nzWpOBEXL53OI/CH3aFY/VXcHzGGb3nZzCYf5Y03hmTEBiCTUrBzfmV4QpUd8xah2Dc
         MrX8/38d/KFjvfDviNwQXffsh1cpDEoZ7bv2aQjdOpXXw+q2wiSF53s9JhlUFXq+WDtj
         HSAonvewkfqvdZ67TmNnERb+fbq09diJGy4kvjsgIrl3S41QFf5tMWp3VIU7KCcpJok+
         EXxo/woVtqDDlV15f7XGpz5X0F8DkGWnC/m3kqu1OKeq5vNSPnyXr+V0nUFDaHw1Nvoz
         J4mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=Lufzklt6eenbIpKvnSwz+uyUxZlQqOKkZcA+/w/mdjg=;
        b=xYUP9LO7GGevzEzOSGlGDB3NsqPs8yP3RIvT1Td7l9Radp/Y6sC7h10dlokks9v4U2
         onv2JY91lK4ia1SmNxAM3S3YtZOhcJfqhCK9cu464+CcVm6c0iTDTrju05NmCpfmXZK2
         7/HJ+hxVohUjWDy7Tht0OXDfzxegLK+7iWhoEz2pQqSyoSr02ztPsBeFUC2NVGGcYZPZ
         uWKuL+zZN4R13QL/fsDsJVwePTMKUp4Z02zfZC+TBOs4agjgNu+NZZoOjXPGNdOQrPSt
         pFrG2zPoKtsWNWn7CcY+kBNmifZi73q0XFMIUezcVEB+UUigapvK+eXEwGKXqGGjQl/U
         xj4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id y23si5053960edm.117.2019.02.18.06.32.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 06:32:05 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) client-ip=46.22.139.17;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 693E61C16BE
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 14:32:05 +0000 (GMT)
Received: (qmail 6242 invoked from network); 18 Feb 2019 14:32:05 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 18 Feb 2019 14:32:05 -0000
Date: Mon, 18 Feb 2019 14:32:03 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: lsf-pc@lists.linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: [LSF/MM ATTEND] MM track: NUMA, THP locality, reclaim
Message-ID: <20190218143203.GW9565@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I would like to attend the MM track of LSF/MM if a slot is available. My
involvement in MM-specific topics tend to be a little sporadic given my
current role but I generally pop up for some page allocator, compaction,
NUMA, reclaim and THP topics in particular. Recent contributions have
been primarily compaction and fragmentation control related with a number
of patches queued up in Andrew's tree for 5.1-rc1 that finally seems to
have stopped generating bug reports.

I'm particularly interested in the following proposals in rough order
of interest;

o NUMA remote THP vs NUMA local non-THP under MADV_HUGEPAGE
o NUMA, memory hierarchy and device memory
o Memory reclaim with NUMA rebalancing

The other topics are interesting but these are the three I'm likely
to spend the most brain power on. At this time I'm not proposing a
topic. While I'm periodically kicking a compaction-related series around,
I don't expect it to be particularly controversial that would warrant a
discussion. That might change, particularly if it starts colliding with
"NUMA remote THP vs NUMA local non-THP under MADV_HUGEPAGE". If so, I'll
do a topic proposal later or beg/borrow/steal a lightening talk slot.

-- 
Mel Gorman
SUSE Labs

