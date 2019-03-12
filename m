Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DACACC10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:53:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9818D21741
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:53:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="dbPP9lBM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9818D21741
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EACF8E0003; Tue, 12 Mar 2019 11:53:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 271A98E0002; Tue, 12 Mar 2019 11:53:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13AB68E0003; Tue, 12 Mar 2019 11:53:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id DED988E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:53:10 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id o135so2335175qke.11
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 08:53:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QcPGxotBvu4iLj90nikA7ZEmDk5xqgqrWN30Zzt/GHo=;
        b=EgN2qgwumnOBB45TUacCrck0kOWhT3TWTKn16RgV3uF5vBN5oSH+Vju6jxn90MAm+D
         oGNEWX+cy8gG5Kg3Ij6pS5FzQcoO49juzS8WZ55b8tzV2LuRjaZqK06pYfv42cp3cJ6f
         NNpLcfk3gNpIReRQ8BHyPGJrcKE+kgNGFUGLXQ0P4d8JMbwPTFaSa9/x+Z2IG7JqhVea
         alezyOsy73yLvN3NOHa8mGTJYqDt+2uiOGt4a7nkMQavCalncLjyQCO8QW4GU1pWwCS2
         ctyFG+SOnp7cPsd/NFcByZJRO9/CIhDj5K7FhtAVSwAcG9sUrkfWu0YA2LsQdQOE9b4j
         lPLA==
X-Gm-Message-State: APjAAAVr0gUiVlo5Fv3zpcdHPx5K/LPnl7x50MaZ7p6Na7vi05fd/mPB
	C9BaIIK/KAPVuQerRWR6uxpQOjQm7E7ywxIZrgjwq58TJ5My4jBPfs32QzEmtoKwha5i4wXBtjm
	3Q9825k3jkEtOSETt1zZZAIj5cWiFf4L8IptB3/x2+QNmMaY4O6lRu8wdU8YnJzsAJDor1I3Zkr
	m3MoSDWHe8PbQ/k6KEOIC0xgoTpvYipqq60u3uuyS5aSd7tL96sO/dCXbPwz4YzvufGtDmQ26vU
	4Po7f5BXlMYKVHzRmoBWgtpAxAGOpbpE0CL2jCFLV1EA4lxaLQo1aEDAAiDMaGJBO3xfmTXDZH9
	Rmz7ZKVcTZJUZsfdYHfWUmjEEJovVrGV8J2XbomUTzcrX/HRGGUTawDxAzUClmThtiC5p6zHqrm
	r
X-Received: by 2002:ac8:1481:: with SMTP id l1mr11722733qtj.226.1552405990642;
        Tue, 12 Mar 2019 08:53:10 -0700 (PDT)
X-Received: by 2002:ac8:1481:: with SMTP id l1mr11722677qtj.226.1552405989834;
        Tue, 12 Mar 2019 08:53:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552405989; cv=none;
        d=google.com; s=arc-20160816;
        b=JwBzXP/XGPjR9zWY0nWU6NwAU2a6hnFjUm4ab/Jjy18ud+8V/Yee9lnWyibbPCX/wI
         Kxoi2Q0DYlcrONwTlJWjg9kW4WDaXEIldFdv1aD8PgWUFRZiBkfHyMs1fOgsCJK4UTHe
         6tnKEAm5KsvXWzfFyLeFlTaSdOTwCBraT8nti9MskoOivLuWl5k30wJV5ReHo84x2ElF
         /AU3YOQamZjTSduGj1LcAFVh3jUd29MdEiuNQi9Yr3/NoJsrPZU6TGMOhK7wwRhFFfZB
         DqbZGhVPDRohC7GWwprlFwqXdVppZXtkgyHgOYwm4RxMCLxUNjyH7ehmZp41w6ARtCOz
         Lb1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QcPGxotBvu4iLj90nikA7ZEmDk5xqgqrWN30Zzt/GHo=;
        b=jr+yV/liWEdv5136+oN3mzhfqorYMXF3+jBFfBbCjpmcxB91vC4Os/IR4ZevdB4J+X
         UC6gRhHqFaf09nLlmoME+hog2h4hQJBj9tb6ri5R/eouWot906TfIxWZqtcI96KrcPhX
         Ty9JIwqXE8iY74e/c/E3pEWrWAWPkTsUJpi73pGkR0bPgtMmrRMNeYARVVOld5OHgJ4/
         WgyMuWAHv+tJX8EryDqeoDnKGGZC42pTlAi9sD3GqVhO3v1mTuO/VftRehjZrYHqZdKt
         xWzITCQGey7Fx+17HJTbuOvhO0PXobEwU3NbWlMd6+OiGAJVrcDFz7T+31d+wfTi/hwC
         KwwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=dbPP9lBM;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w26sor10913718qth.47.2019.03.12.08.53.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 08:53:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=dbPP9lBM;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=QcPGxotBvu4iLj90nikA7ZEmDk5xqgqrWN30Zzt/GHo=;
        b=dbPP9lBM9Vpwl8UqgK2FiG73wqfxxhFr5e/jw73ZhZcIhH6CkbAN6oCvQDucYiWs5I
         JDALIPaDkwHb9EbDQOT2uIcCJchKq5aPZRNB+scgKHVFC8HZwrEMpA+W4lU0Fb1Vx7qV
         aq/C8eg1BT488SLziv9InsoOWyVPjr0B+KEaidQrgJH3iJpsAYV7a/nHR4BVRH6NXQoK
         ZqK6wD7Ox7rAvobJjG2GPPrEUhdKDozEkuDMO1KsUBEfGcWVTg8yl1yk6lpURTBJiYp8
         TFAty+mWGYB7KnRqfP3UkkDJdWQjjlSll/wWP6+tv3C+L2De8lgUqO+G7NZV7xowViW0
         cOpw==
X-Google-Smtp-Source: APXvYqx+bB0cu7zBn/5pp5qfiV/PWk0wKQn1c5Yq7D+NffNMoWoccLsBRobU7B2oICXVHxWT2ZqYPA==
X-Received: by 2002:ac8:5297:: with SMTP id s23mr29738624qtn.371.1552405989409;
        Tue, 12 Mar 2019 08:53:09 -0700 (PDT)
Received: from ziepe.ca ([24.137.65.181])
        by smtp.gmail.com with ESMTPSA id h18sm4893517qkj.50.2019.03.12.08.53.08
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 08:53:08 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1h3jiF-0002rT-AW; Tue, 12 Mar 2019 12:53:07 -0300
Date: Tue, 12 Mar 2019 12:53:07 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Christopher Lameter <cl@linux.com>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 0/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190312155307.GD20037@ziepe.ca>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <010001695b4631cd-f4b8fcbf-a760-4267-afce-fb7969e3ff87-000000@email.amazonses.com>
 <20190308190704.GC5618@redhat.com>
 <01000169703e5495-2815ba73-34e8-45d5-b970-45784f653a34-000000@email.amazonses.com>
 <20190312153528.GB3233@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190312153528.GB3233@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 11:35:29AM -0400, Jerome Glisse wrote:
> > > > Yes you now have the filesystem as well as the GUP pinner claiming
> > > > authority over the contents of a single memory segment. Maybe better not
> > > > allow that?
> > >
> > > This goes back to regressing existing driver with existing users.
> > 
> > There is no regression if that behavior never really worked.
> 
> Well RDMA driver maintainer seems to report that this has been a valid
> and working workload for their users.

I think it is more O_DIRECT that is the history here..

In RDMA land long term GUPs of file backed pages tend to crash the
kernel (what John is trying to fix here) so I'm not sure there are
actual real & tested users, only people that wish they could do this..

Jason

