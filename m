Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E7E1C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 01:53:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2124421904
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 01:53:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2124421904
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA1858E0002; Wed, 13 Feb 2019 20:53:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B51608E0001; Wed, 13 Feb 2019 20:53:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A409C8E0002; Wed, 13 Feb 2019 20:53:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 60D098E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 20:53:25 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id r9so3454497pfb.13
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 17:53:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GQ9VF+dvWfYLc9m6nWFfekhlvYVx+0eETtTp4Zl13xE=;
        b=oYB/3UqV6Fl1oF/95Y8PAql8ajnkJEeB4VQCRc+NBS5DzabAseL5JiH1baSRqCWEf8
         +taEWxWLH1wSgN8Bbc/xTftARUf3tlkFh2TLeKg8QB9Mt69mwfBNjOpNOrbMbxyZhYuZ
         Pmkx8VKW4BclattoQkck8CJpSblB0w+0lDRjsbtLi9E3zluqw/W4+s3O5YYcYw9Su9DK
         ar+dETdLqRm0fjSJGXB6vpMSg0KbFr8BuSEhDaU25jLPa8BY93S2mjzGRcEV7RnKs45v
         qPxRh5Nhq74oa6mxfD1ix4lWJnEmpTgmAxohuEi0zGwPBuc8brLuwlxw1ShXw4oAP3df
         Ijdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAub7NTt2FstQSbgfo3gqi0zFqeeG+TUzwtaI0vIZUhYq17aJlzc7
	lAx3b+ZdWmEk2XmsQcIjYUji2RIxpjLP9wi6+wc+SBEyfplYIlSIFeZkeacO2Jdv1uvBTi8ylwv
	qc09Ofy+4EuVZnf65EF+KtlqrVJuxmh9DHmNUrGKTBN4I1wJpPI4HPtF73n7EgV7Tsg==
X-Received: by 2002:a62:1992:: with SMTP id 140mr1369749pfz.33.1550109205063;
        Wed, 13 Feb 2019 17:53:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib4Q3SWyv5AgOQ2D3+bmoXQeTDJIIRCGlCS1UTqLl7aMN6DgAC4e64BcJoFt7hQy2T/yYXF
X-Received: by 2002:a62:1992:: with SMTP id 140mr1369706pfz.33.1550109204337;
        Wed, 13 Feb 2019 17:53:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550109204; cv=none;
        d=google.com; s=arc-20160816;
        b=Q5mjcFlFC4QAa2bitIyc95pnHJTmo2v7Xeck6nGtd4PJwflgFHfLqZXUlK1WrUcUcN
         ls/lFDgmR5iC+zgg/LCmd23kilplwnuUCyDI8gF9NOR0JmtlzCEYTqPfCOe0coMVuT04
         0XOcjoQdT/kDKofuAho8UesbznyLbPTIkulygg2LRbhGFtYLABuLTnoaWTHnXRs+BsQI
         HjV1athGVuEdujswV+ZvezMcktJuOjpKpnvI3PzsSPGRCH2dJ6KqYoesXkshDBbp+sq9
         EDBxM+fCOOA9DeVmmGjERI5jKZ5lJIbhcY+T7r9vXTyXYH1jDAzgWYUIiCyM8qvHgBjY
         q4+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GQ9VF+dvWfYLc9m6nWFfekhlvYVx+0eETtTp4Zl13xE=;
        b=vDTwDC42Q+LvQGY4QzOqn5VyF1cQ0I/jBlGj1qLhFrnwPwCrrLg343t7Qj+VmTITYA
         K7Mm8KFKc2+xuvE9xyo9oY3rX4TTKJ9kAwzXuzPqRlDZ9t8C3fhGcz3Gb1wC4KYvDqB2
         QjyJVM+AnxaP87hWCODA9bnPyJiEwTMwbEb5GLAQfkeRJccVamCONdi3iGcJ3XftIeWm
         kaCkdZgsVvvc8HpUVMWDv5P5TREahxAGTamdFPkjH5igAYVZ3SaRJnkR4i3pU8CArzJa
         S7oVX9O3JGGMtzyxzK1ymZrdXZd/nr72ll7ski0fQTOZWKfnnfsSQZU2qwGh9SNOV+w9
         XlcA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 90si1038400plb.17.2019.02.13.17.53.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 17:53:24 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Feb 2019 17:53:23 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,367,1544515200"; 
   d="scan'208";a="116051781"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga006.jf.intel.com with ESMTP; 13 Feb 2019 17:53:22 -0800
Date: Wed, 13 Feb 2019 17:53:14 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
	dave@stgolabs.net, jack@suse.cz, cl@linux.com, linux-mm@kvack.org,
	kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
	linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
	paulus@ozlabs.org, benh@kernel.crashing.org, mpe@ellerman.id.au,
	hao.wu@intel.com, atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru
Subject: Re: [PATCH 0/5] use pinned_vm instead of locked_vm to account pinned
 pages
Message-ID: <20190214015314.GB1151@iweiny-DESK2.sc.intel.com>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
 <20190211225447.GN24692@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211225447.GN24692@ziepe.ca>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 03:54:47PM -0700, Jason Gunthorpe wrote:
> On Mon, Feb 11, 2019 at 05:44:32PM -0500, Daniel Jordan wrote:
> 
> > All five of these places, and probably some of Davidlohr's conversions,
> > probably want to be collapsed into a common helper in the core mm for
> > accounting pinned pages.  I tried, and there are several details that
> > likely need discussion, so this can be done as a follow-on.
> 
> I've wondered the same..

I'm really thinking this would be a nice way to ensure it gets cleaned up and
does not happen again.

Also, by moving it to the core we could better manage any user visible changes.

From a high level, pinned is a subset of locked so it seems like we need a 2
sets of helpers.

try_increment_locked_vm(...)
decrement_locked_vm(...)

try_increment_pinned_vm(...)
decrement_pinned_vm(...)

Where try_increment_pinned_vm() also increments locked_vm...  Of course this
may end up reverting the improvement of Davidlohr  Bueso's atomic work...  :-(

Furthermore it would seem better (although I don't know if at all possible) if
this were accounted for in core calls which tracked them based on how the pages
are being used so that drivers can't call try_increment_locked_vm() and then
pin the pages...  Thus getting the account wrong vs what actually happened.

And then in the end we can go back to locked_vm being the value checked against
RLIMIT_MEMLOCK.

Ira

