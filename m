Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BDA0C31E4B
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:12:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 233A920449
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 15:12:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="JRz6imxO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 233A920449
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B13AD6B000E; Thu, 13 Jun 2019 11:12:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AC3DE6B0266; Thu, 13 Jun 2019 11:12:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B4646B026A; Thu, 13 Jun 2019 11:12:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7DADB6B000E
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 11:12:22 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id p34so2898694qtp.1
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 08:12:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=R4sEx9DRCkbOcqkLsi6Jkv1GflPMZb75UMnrOJnbtJI=;
        b=G2gPIBXq2SSG/54xfbZEEUc7lfIQaYuiABe9K6E5BZSNuDRIxKs4a/JghKE9X9oYXL
         DK5DF+pOHICaxlJCmkc0RsCopy5Q11ciGqtyPe8jpDx2RGuoOsqQN6ULONk70UG2F8PS
         R8+gwOIcGtNjM54sYHcoA553OWjh8AhmhsuWztiT1wh/8hjUEMgaWUAloLgc/MYLVJML
         2cOarMjwyhbzEXoTJswl2nEP1PshYOV0RqIPV+TbozYProtohgngZEo/qvASmXD27u0M
         wsDS81e9NMg8QU+mCJcR0KpygMMH0/6uZCzt4jQPveifNlTTRQDnDMsP9p2FvCNd2V7B
         oghw==
X-Gm-Message-State: APjAAAWSTj26lHDs0lnqj6ZUWibA+l8HiwJmlDRKiL2dIk2ku9yCpuN5
	YK2B6rXeLh9nTQv9T06XfPigKAfI5V9cRpdVIXG8vfd+R6iEUsir1G8kLliBVlZTaI03yzgazi0
	s/W9996IIk1RPofXjtN5Ww3SsvlMa76fnKeQ8ILwmBzfH4MwEG0vBAnXv+yW7lX6bcA==
X-Received: by 2002:aed:3f1a:: with SMTP id p26mr75481215qtf.113.1560438742237;
        Thu, 13 Jun 2019 08:12:22 -0700 (PDT)
X-Received: by 2002:aed:3f1a:: with SMTP id p26mr75481138qtf.113.1560438741251;
        Thu, 13 Jun 2019 08:12:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560438741; cv=none;
        d=google.com; s=arc-20160816;
        b=S+LyuxxJclR8UZj8BwAY3lDUXwMtKbekkCxu8ovJoqTpWwBS68BdsbS6B3bJ5RqPXU
         L8cnOkSsPbqqd2N0Rx45YYo7FeIEPkXUw0gnKf7BSbqDeRymVAz7fouCLD1wrfB36Bqf
         DMc0AR2B53CQXKGJs1Z5we3NA4FqYqic/OtoMIugtkKJOhOf1G4kfugtSDKg3ZD44idt
         pcTEhWA3jEkaj+y7HrMPoBRwBuZD1/sbcaFISuVSxxmDXZq53vBAixW7SNXV/Y2tPqQP
         zD22EZre8IQF7tqwM6/BDwErGoEs3EKcWhy+fi6URhKWalAytA71eaISj+QU88hmWERN
         3IeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=R4sEx9DRCkbOcqkLsi6Jkv1GflPMZb75UMnrOJnbtJI=;
        b=KIZkyn9z2rZs4um4R7Yg+rLrzP0AYviVMiY2hR+PbY/LapIHO3bigmINm1gQdXKwby
         CBmR1x81QlbKpDyf9vWV1DIAs80a+zo/V49ELVqrV3HvHo9dEQqXf/IvEySepRHMza+y
         CBibchjd/1+OhpSCEfSbBqKn+/CblCsdlC8vsrO3qFaW1mE/zeNeGIcsvS0/O5ikGQZy
         /+Z7c3PBpixiC/aUYlAknfnI9dMrHwCj2RudFXZIhBsKhk6/0QkpV/dOmvG76nFc3HSO
         dzSP7hzvVpjM6Zcc1b6rLvfnPVusrch35Tthn639wmWd1NIVVMiLChFAYm4SxMH/mYCD
         Y6Og==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=JRz6imxO;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x21sor141441qkh.133.2019.06.13.08.12.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 08:12:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=JRz6imxO;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=R4sEx9DRCkbOcqkLsi6Jkv1GflPMZb75UMnrOJnbtJI=;
        b=JRz6imxOTGsNuMS76M162KvumiMVyYkKXhz/IAFwKjp3Igi0hICl/m4BUGOuw61YG6
         Pf3He7hg9Kt6x6X1WZuq8bUrqc1a1W2UmAo8VaUwVPA2GdvPEx7a5YMbLY0nfJoFWaQM
         YEbV9dRjW/drtmRraCujxYyThEP6QtwiSJs3iYcbutlXVk7Z5dASy1/Oy0G/oorjue0j
         RzaH6Drn7BTg39I+BUiwTL6fije0cyR1reQqzW1AIca5v1agyVprI5RgkLHLmKlYW9Fi
         0n1zTcJtV1luwZoUboeqFK2xDSzt81BhwHG/KONzmn78w16+WuqvsJOUxxwdcX8amTie
         g0WA==
X-Google-Smtp-Source: APXvYqzM9yCChTgMP3KlIhiG1BK19OOrfQlMOx6JZlNrolhLErYOjGfGuCWD8w4PBuxWllsDgHA6QA==
X-Received: by 2002:a37:e506:: with SMTP id e6mr3810214qkg.229.1560438740039;
        Thu, 13 Jun 2019 08:12:20 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id n10sm1577550qke.72.2019.06.13.08.12.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 13 Jun 2019 08:12:19 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hbROk-0001qR-Po; Thu, 13 Jun 2019 12:12:18 -0300
Date: Thu, 13 Jun 2019 12:12:18 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-xfs <linux-xfs@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>,
	linux-ext4 <linux-ext4@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190613151218.GB22901@ziepe.ca>
References: <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
 <20190607103636.GA12765@quack2.suse.cz>
 <20190607121729.GA14802@ziepe.ca>
 <20190607145213.GB14559@iweiny-DESK2.sc.intel.com>
 <20190612102917.GB14578@quack2.suse.cz>
 <20190612114721.GB3876@ziepe.ca>
 <20190612120907.GC14578@quack2.suse.cz>
 <20190612191421.GM3876@ziepe.ca>
 <20190612221336.GA27080@iweiny-DESK2.sc.intel.com>
 <CAPcyv4gkksnceCV-p70hkxAyEPJWFvpMezJA1rEj6TEhKAJ7qQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gkksnceCV-p70hkxAyEPJWFvpMezJA1rEj6TEhKAJ7qQ@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 03:54:19PM -0700, Dan Williams wrote:
> > > My preference would be to avoid this scenario, but if it is really
> > > necessary, we could probably build it with some work.
> > >
> > > The only case we use it today is forced HW hot unplug, so it is rarely
> > > used and only for an 'emergency' like use case.
> >
> > I'd really like to avoid this as well.  I think it will be very confusing for
> > RDMA apps to have their context suddenly be invalid.  I think if we have a way
> > for admins to ID who is pinning a file the admin can take more appropriate
> > action on those processes.   Up to and including killing the process.
> 
> Can RDMA context invalidation, "device disassociate", be inflicted on
> a process from the outside? 

Yes, but it is currently only applied to the entire device - ie you do
'rmmod mlx5_ib' and all the running user space process see that their
FD has moved to some error and the device is broken.

Targetting the disassociate of only a single FD would be a new thing.

Jason

