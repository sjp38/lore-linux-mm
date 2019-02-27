Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9051EC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 01:13:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57EB7218E0
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 01:13:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57EB7218E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF9328E0003; Tue, 26 Feb 2019 20:13:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D819B8E0001; Tue, 26 Feb 2019 20:13:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C233B8E0003; Tue, 26 Feb 2019 20:13:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9FD8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 20:13:20 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id f10so10938095pgp.13
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 17:13:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=lAfcMC57fT06SDDCZL0qyTjcBZoOPGg8cyHaZt44poc=;
        b=qQco4BT+b7WJ4UIOPxFw43gcKFH9gKuuPMSTGmTfY/zjGZfS/Pj7l29cSZ9DGxvzhu
         /0tuHzzrypq60mwfjdWML3XYTXmZxDQTucaSBDodEjci4IlYVw2mmsaQRz1a6SvOD/vh
         7MocQl0XQmZOfrDMDFhP8mFdflPSehhOOQ7Omh5JYe+Ai0ZAw0EU5TrPVBvUkaKOhSkb
         s/qRfwv3eYnnd0TZQSBNHFRWMLX4EjoISC92Dg7VPGdNqa5tLyWfYy4rL9MaE1ELQg7S
         egtlQ1zbwsD3uw5lW6ygexY93tVZqW9uHda8/vXpS6FX26jxjNuSb3IM6SHbgmLpvsiK
         ZNCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZXtljb+KgP4JiREAzD3jGsnnTs7FK/fz/FOldIJjUweLMzX6pq
	VfFwmFOgIl3M3MOjLctst8yp3Od/oIROc+x+6Besze7Oqt3p6jw7fmyX6mLjZUKQEst7j+HQNFY
	L0liVURXUXQ/dpq1ANLeEJb1c1ANHFrECvBQ+9Za/ocCDTtavzb7ek+wWVYEzokw7nA==
X-Received: by 2002:a62:f201:: with SMTP id m1mr29021363pfh.97.1551230000061;
        Tue, 26 Feb 2019 17:13:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ3aQb5ZzxnJ1QPf2Ut9ka0x3v8yIfTs44+y0AT6DAqnuKQXdlgtyP3YqTV3fGeiqGEgZKs
X-Received: by 2002:a62:f201:: with SMTP id m1mr29021273pfh.97.1551229998904;
        Tue, 26 Feb 2019 17:13:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551229998; cv=none;
        d=google.com; s=arc-20160816;
        b=tL7NuWevTwBlCOzro7oBEwbV+2IS2HiBlmdIOOQ/xL5ei7MdXWD3VrvEy+PpnM3xEU
         gWeo/R66JCFuY7I4cCSUIeseGH11JtbZaOB9i8fjsrNARAaPjGucn45plnG/kZhnPV0G
         nnF4N+ygxnOWQmGnCTlrm1MMXIC9u7+4fVZuuGwhi6HzAOtYquYAMU4w8SD5ltihH/Km
         7oXvDxCMwJXg1MKP8jgKoqgETxegrHeVQrnzb4IrGPH0vIB0/X73lX4YdB1aUSXLDDFY
         06iWIiBo7oPVTXPxhw+SashQ40ymGMlxSSahmTtU/iTsE7k85a44SfK61Jm9iLKIqME3
         Okeg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=lAfcMC57fT06SDDCZL0qyTjcBZoOPGg8cyHaZt44poc=;
        b=wJfwQn2s7IdYsjxGbauBpnRqQjRhtlNIaYhd+nBFiHjvgQjMdJYYKIWEKdbspPBpSw
         3/8043lbEM2eJXjBCJ+9sSnuL10mP/c530j+zBlEoXYNotiYFLvV/M+zDi5MDrvD7M4U
         tozSSOlsNYqUzxX1TIgIf/ozfaAuLPYuuaVUhEzxiVtPf5w8jbBHbD/SScFM87/cI+Hu
         MToAGgPAzGkoRMELTOIfQP+pansVQwx3+Jwpn4OxIuFxEm3cX7ojkpuIX2Q3ODQ7B0+/
         m+B2pysYr4k2xYWyQNrXX2kfAWdsvRXlNQygaIbSX5rI4yLeGyqZPYfsEd2HGkh5FeaW
         eu5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id c131si13774963pga.358.2019.02.26.17.13.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 17:13:18 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Feb 2019 17:13:18 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,417,1544515200"; 
   d="scan'208";a="129624334"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.151])
  by orsmga003.jf.intel.com with ESMTP; 26 Feb 2019 17:13:14 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,  Andrew Morton
 <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,
  <linux-kernel@vger.kernel.org>,  Hugh Dickins <hughd@google.com>,  "Paul
 E . McKenney" <paulmck@linux.vnet.ibm.com>,  Minchan Kim
 <minchan@kernel.org>,  Johannes Weiner <hannes@cmpxchg.org>,  "Tim Chen"
 <tim.c.chen@linux.intel.com>,  Mel Gorman <mgorman@techsingularity.net>,
  =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,  Michal Hocko
 <mhocko@suse.com>,  David Rientjes <rientjes@google.com>,  Rik van Riel
 <riel@redhat.com>,  Jan Kara <jack@suse.cz>,  Dave Jiang
 <dave.jiang@intel.com>,  Aaron Lu <aaron.lu@intel.com>,  Andrea Parri
 <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH -mm -V8] mm, swap: fix race between swapoff and some swap operations
References: <20190218070142.5105-1-ying.huang@intel.com>
	<87mumjt57i.fsf@yhuang-dev.intel.com>
	<20190226230729.bz2ukzlub3rbdoqp@ca-dmjordan1.us.oracle.com>
Date: Wed, 27 Feb 2019 09:13:14 +0800
In-Reply-To: <20190226230729.bz2ukzlub3rbdoqp@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Tue, 26 Feb 2019 18:07:29 -0500")
Message-ID: <87imx6rq39.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> On Tue, Feb 26, 2019 at 02:49:05PM +0800, Huang, Ying wrote:
>> Do you have time to take a look at this patch?
>
> Hi Ying, is this handling all places where swapoff might cause a task to read
> invalid data?  For example, why don't other reads of swap_map (for example
> swp_swapcount, page_swapcount, swap_entry_free) need to be synchronized like
> this?

I have checked these places.  They are safe because there are some locks
(like page lock, page table lock, etc.) held to prevent swapoff.  I
found another place in the kernel that is unsafe: the mincore.  I have a
patch for that and will post it (in fact again) after this one is
merged.

Best Regards,
Huang, Ying

