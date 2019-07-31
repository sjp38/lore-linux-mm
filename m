Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 037C7C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 22:40:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C44E820693
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 22:40:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C44E820693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A0ED8E0003; Wed, 31 Jul 2019 18:40:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 529B78E0001; Wed, 31 Jul 2019 18:40:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3CB738E0003; Wed, 31 Jul 2019 18:40:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id F37D38E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 18:40:08 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 6so44226811pfz.10
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 15:40:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=0bWlLBuUofOMXxzWXPVmkrlWbXYAAypOrTSLVPR2loI=;
        b=dSj9ioDm+0ygp8AcJHZoF9ywAr2BeM9HX/p/J8UblVO8iv1dBIUrzLMUOahqhfIeq/
         W9nN6N0cla8gnkzAfFgKIz8qCaBg2gSK3sSGi3lF7NNXo1SSa04A3XX5UOrE6zxukBdu
         GObPxrQsS0qry/D0Ii3WxEMiLyTi+pxM833W+zhkiDsj6SOsogkOljM7kYIj7c5E/WcX
         kuLjF9l/LAyv2+EQh+xSJ3f22RPh1R8L6K/xq1wzGZnDYuJRf7cfHpCxWzwVwFk0NDzG
         0UzRAHk1y5r+yVp7Mdr/M4tWszlrh97dYJNT4e2Z9eYJe/nVf9OzY3yBcBNvofL6hS06
         R7fg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXIsIJhnXOOqujinXjz78oBdWODIjcbrK2bN+nRb0+0qMQh8jJ3
	GplwdGRJPVH7LA+c0pYU9zJKcGcW08UlfQQOOntAX8AbiWnxxf/akxYyu47tgHePeCDhhJ38WmH
	Aid8gZ7jH2Yr+ghydLxEEv3SiH6iLu2QGP4CyG6uuR7EqxUtkdICmucDQXV+Rd0HuDQ==
X-Received: by 2002:a62:e716:: with SMTP id s22mr49498485pfh.250.1564612808671;
        Wed, 31 Jul 2019 15:40:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzoNQBcp/MVTn1w3ZkxXkg+yClbybsd3XAS6mUEQa3isOv+KYycZbObkWann7OVWz0L0yIN
X-Received: by 2002:a62:e716:: with SMTP id s22mr49498437pfh.250.1564612807992;
        Wed, 31 Jul 2019 15:40:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564612807; cv=none;
        d=google.com; s=arc-20160816;
        b=bbmZkgK4w6goByl+RQg2gsj8LlKuGqzJPelbOtYo2bZzVlRlvthXOQIEHi2N/bcJQs
         Ik/2QmvTITE8EYf1lyxGR7M4Q965R1u/mzMeJyNaXp8PcChUbchfUFR930AIYRqzk+Su
         O5B5FerwJf5tGhiZGjLXftsHrYqvCTtepKcKUBp7lJqDQ8BuSELr6l53khuoV0hzaXRr
         KEgd0Aa49SYG/iO2fGLjMlO1NqVIhYhJByo7oZ9A9yAUTV3dinKiE3Fjv7gDGtn59pJT
         Jh0T23A5o8Oh4ews8sXUXuxzw9xfPO0kQKUTLp2Sw1zdmj3cY02ELSNCYooCz2D5lWWV
         XjtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=0bWlLBuUofOMXxzWXPVmkrlWbXYAAypOrTSLVPR2loI=;
        b=L1bSgxalonzldr7yk8b1CnMiSalEpyeM94lwM6VzI3Wj6KisMl8m8zodq3K0lVYvyD
         WDJ2acqu/sgjuAJ9EG429xhkSdoUD5wdLzXMyWUratwwM1h21byxzJGPlTOXajaiSMU5
         pZEE4mgc39KMZUJHDjM01XipBz/bbS2rgkPyZU+jqcCKpD4ZpIPROKEnunBwWlnxOkwd
         +U86z+eHwlk9V4Lsa6lOQ7i59EHKRn1r9josks4Fn8i8yBo87/EMdTuL8PvmuICd7ElL
         MhiBMxoiAIY4jh7a9lXm3a5vCZbW6IZriUALiqRieqQVZOWAWZ6RKQ29r8/JwBmgXJ4l
         8d7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id bj12si30611564plb.378.2019.07.31.15.40.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 15:40:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of sai.praneeth.prakhya@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=sai.praneeth.prakhya@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 31 Jul 2019 15:40:07 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,331,1559545200"; 
   d="scan'208";a="191399007"
Received: from sai-dev-mach.sc.intel.com ([143.183.140.153])
  by fmsmga001.fm.intel.com with ESMTP; 31 Jul 2019 15:40:07 -0700
Message-ID: <a05920e5994fb74af480255471a6c3f090f29b27.camel@intel.com>
Subject: Re: [PATCH] fork: Improve error message for corrupted page tables
From: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@intel.com,
  Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Date: Wed, 31 Jul 2019 15:36:49 -0700
In-Reply-To: <20190731152753.b17d9c4418f4bf6815a27ad8@linux-foundation.org>
References: <20190730221820.7738-1-sai.praneeth.prakhya@intel.com>
	 <20190731152753.b17d9c4418f4bf6815a27ad8@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5-0ubuntu0.18.10.1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> > With patch:
> > -----------
> > [   69.815453] mm/pgtable-generic.c:29: bad p4d
> > 0000000084653642(800000025ca37467)
> > [   69.815872] BUG: Bad rss-counter state mm:00000000014a6c03
> > type:MM_FILEPAGES val:2
> > [   69.815962] BUG: Bad rss-counter state mm:00000000014a6c03
> > type:MM_ANONPAGES val:5
> > [   69.816050] BUG: non-zero pgtables_bytes on freeing mm: 20480
> 
> Seems useful.
> 
> > --- a/include/linux/mm_types_task.h
> > +++ b/include/linux/mm_types_task.h
> > @@ -44,6 +44,13 @@ enum {
> >  	NR_MM_COUNTERS
> >  };
> >  
> > +static const char * const resident_page_types[NR_MM_COUNTERS] = {
> > +	"MM_FILEPAGES",
> > +	"MM_ANONPAGES",
> > +	"MM_SWAPENTS",
> > +	"MM_SHMEMPAGES",
> > +};
> 
> But please let's not put this in a header file.  We're asking the
> compiler to put a copy of all of this into every compilation unit which
> includes the header.  Presumably the compiler is smart enough not to
> do that, but it's not good practice.

Thanks for the explanation. Makes sense to me.

Just wanted to check before sending V2,
Is it OK if I add this to kernel/fork.c? or do you have something else in
mind?

Regards,
Sai

