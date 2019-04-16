Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD1D5C10F12
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 00:00:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A58642084B
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 00:00:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A58642084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4618E6B0006; Mon, 15 Apr 2019 20:00:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EA196B0007; Mon, 15 Apr 2019 20:00:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 289DB6B0008; Mon, 15 Apr 2019 20:00:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E47376B0006
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 20:00:35 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g1so12892304pfo.2
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 17:00:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=TrEutZpmd3K1j7rFy+kKx4y1SOqkZul1wmMRDrfTNqI=;
        b=YrHNyglYcmU/eb3Sr99fvs7lRZUBcQkh6R3Z+WP6tqjs5FPi+1QGVPGGQenqimIhhy
         A9Ozo2DpjS+5djq9BRhn5ifynzGHA0i50ytSPBQkn6gz72XMlMnbWuPJLhi8Wf4sNQdq
         K3xQms21srZ5YaM2K6ViYwl0S6fsvbDN0+Qq7otGU2uIOxSpcKR5INRt/PZTu1f4YURg
         oMyKxtuWX2EdHcuE8duOsooZCXXd4jlUaegwlUXywZRqhUafs8DwnLf2GqavFzKj2L8E
         pfr57Ejk1N597s+KKsfMpNyHiAAIxN74HqYoM4zmT3p5XXMqnv8wmZUhjGNe6q8iqSNw
         6gPQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXOQSgCB/XldJnMNTieD07WUMMOHO7pNXCkxyNbcEEQu8kCncdX
	uCsKbJvqmkZGtN0RngVt/KfnATgq5Fzz4wstQmhb0Xh30zkSFGuwScDBwtOaAYIVZ6RI/V4i86E
	+0rz6WZglxOcBtzxxIhUI5I9YBgZHhmboerMpluxZRydqML2v3M28ahcjZYYm9Pg=
X-Received: by 2002:a63:ff66:: with SMTP id s38mr73999366pgk.120.1555372835598;
        Mon, 15 Apr 2019 17:00:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnSsFuKZtFKQEHC15Y6Ey9q/uJ5YSDLDI6ROt10RA0sEUHyhv31YS+qW9+jzqhPoqXwthQ
X-Received: by 2002:a63:ff66:: with SMTP id s38mr73999289pgk.120.1555372834824;
        Mon, 15 Apr 2019 17:00:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555372834; cv=none;
        d=google.com; s=arc-20160816;
        b=UhN71IXBNEeZO81ic620BthANH2MQTKu8Mrhx36t8ykVGFC6+c8NHePd0VX9RwyZYl
         wEr/4kguUSZy7BpwUvoCBuKSTcByGP5pqREWBm4BAR1wYU1JMxWcqJBpGgo8AcYZvgg6
         FRn3A8/goolyt1p0g1QYT/TGbBP2ISrnuHcKYXNhsMUgiAOEm0E5VzZW/R+rcH7xi9OA
         Y20eeStAJRKrNLrlHf7fzhvVYtL9tqV7NFzGv2WIHEuNU9SoiOB5Myz3fYsJxhdatZOA
         SlKtEOnuK8FasS7uOq0YaYNe82PCy5pXWqyVCag/woH8QBWdzOtOF4EomQ3atmFYq3KU
         jqCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=TrEutZpmd3K1j7rFy+kKx4y1SOqkZul1wmMRDrfTNqI=;
        b=f2rDyy41jgghhtRl2t4MQlDVb/PrdSNCFfaRPokXp0BhriD6a0mnVWoi61lPcLErNq
         h2ebMBGvACB8b6HVlu6+TOdOz7dODjkzEKR4wkBqW3siJ1QvuM/4L5Mlw9HTULT1PFXj
         NYCOTKfr8yirQPsO1U1+a13BwYGjY55SNd5aJF6nflPuj2sZUBS8brvmOUKCZzflBKs3
         UDqLErHGzxXOs7DGJD9Lep7n/xvOVeoTzK/FjrxhxvGixSf77Ue/2xs2yCJiuwbuE//p
         FRKLCUILF7cagRDW3QQcsLBpXkpEwKk9fpuap7b/tOry7rqcn6WG59pjFSHZePYYDMfo
         BRLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id r23si42312906pgv.471.2019.04.15.17.00.34
        for <linux-mm@kvack.org>;
        Mon, 15 Apr 2019 17:00:34 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-160-97.pa.nsw.optusnet.com.au [49.195.160.97])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 6CF0A43B815;
	Tue, 16 Apr 2019 10:00:23 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hGBWQ-0001Bf-TP; Tue, 16 Apr 2019 10:00:22 +1000
Date: Tue, 16 Apr 2019 10:00:22 +1000
From: Dave Chinner <david@fromorbit.com>
To: jglisse@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org, linux-mm@kvack.org,
	John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Ming Lei <ming.lei@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
	samba-technical@lists.samba.org, Yan Zheng <zyan@redhat.com>,
	Sage Weil <sage@redhat.com>, Ilya Dryomov <idryomov@gmail.com>,
	Alex Elder <elder@kernel.org>, ceph-devel@vger.kernel.org,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Latchesar Ionkov <lucho@ionkov.net>,
	Mike Marshall <hubcap@omnibond.com>,
	Martin Brandenburg <martin@omnibond.com>, devel@lists.orangefs.org,
	Dominique Martinet <asmadeus@codewreck.org>,
	v9fs-developer@lists.sourceforge.net, Coly Li <colyli@suse.de>,
	Kent Overstreet <kent.overstreet@gmail.com>,
	linux-bcache@vger.kernel.org,
	Ernesto A =?iso-8859-1?Q?=2E_Fern=E1ndez?= <ernesto.mnd.fernandez@gmail.com>
Subject: Re: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
Message-ID: <20190416000022.GA1454@dread.disaster.area>
References: <20190411210834.4105-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190411210834.4105-1-jglisse@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=FNpr/6gs c=1 sm=1 tr=0 cx=a_idp_d
	a=EHa8gIBQe3daEtuMEU8ptg==:117 a=EHa8gIBQe3daEtuMEU8ptg==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=8nJEP1OIZ-IA:10 a=oexKYjalfGEA:10
	a=20KFwNOVAAAA:8 a=7-415B0cAAAA:8 a=8ER2NWrdpJKUM3wQwksA:9
	a=wPNLvfGTeEIA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 05:08:19PM -0400, jglisse@redhat.com wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> This patchset depends on various small fixes [1] and also on patchset
> which introduce put_user_page*() [2] and thus is 5.3 material as those
> pre-requisite will get in 5.2 at best. Nonetheless i am posting it now
> so that it can get review and comments on how and what should be done
> to test things.
> 
> For various reasons [2] [3] we want to track page reference through GUP
> differently than "regular" page reference. Thus we need to keep track
> of how we got a page within the block and fs layer. To do so this patch-
> set change the bio_bvec struct to store a pfn and flags instead of a
> direct pointer to a page. This way we can flag page that are coming from
> GUP.
> 
> This patchset is divided as follow:
>     - First part of the patchset is just small cleanup i believe they
>       can go in as his assuming people are ok with them.
>     - Second part convert bio_vec->bv_page to bio_vec->bv_pfn this is
>       done in multi-step, first we replace all direct dereference of
>       the field by call to inline helper, then we introduce macro for
>       bio_bvec that are initialized on the stack. Finaly we change the
>       bv_page field to bv_pfn.
>     - Third part replace put_page(bv_page(bio_vec)) with a new helper
>       which will use put_user_page() when the page in the bio_vec is
>       coming from GUP.
>     - Fourth part update BIO to use bv_set_user_page() for page that
>       are coming from GUP this means updating bio_add_page*() to pass
>       down the origin of the page (GUP or not).
>     - Fith part convert few more places that directly use bvec_io or
>       BIO.
> 
> Note that after this patchset they are still places in the kernel where
> we should use put_user_page*(). The intention is to separate that task
> in chewable chunk (driver by driver, sub-system by sub-system).
> 
> 
> I have only lightly tested this patchset (branch [4]) on my desktop and
> have not seen anything obviously wrong but i might have miss something.
> What kind of test suite should i run to stress test the vfs/block layer
> around DIO and BIO ?

Such widespread changes need full correctness tests run on them. I'd
suggest fstests (auto group) be run on all the filesystems it
supports that are affected by the changes in the patchset. Given you
touched bio_add_page() here, that's probably all of them....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

