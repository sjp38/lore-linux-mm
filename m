Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC0B7C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 23:14:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 594562186A
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 23:14:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 594562186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC5586B0010; Thu, 11 Apr 2019 19:14:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B77F56B026A; Thu, 11 Apr 2019 19:14:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A3C5C6B026B; Thu, 11 Apr 2019 19:14:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6D27D6B0010
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 19:14:54 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id w9so5013628plz.11
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 16:14:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=0OQc2KFOseBtS6C5gc68UcucYkNWGRFhIlRqasBgoaA=;
        b=k7hgQR1fOqmQbnS2tqDek1nPuhbk4F96Ee9DpdKj219jYHk+fe1cbVpbqQPlRunrU9
         cDq3rUMbIrAnu5bolqG8L4Cd1Hxe8l7VE6PGMPQemoqRBlOmKkKQwPjse9kbUoYcQYVS
         uXbuLkS5Ahf3g/i6GIqah7iE6xkrqtYNKCd7ULIo0GzvorvwryAEAEPZ8lIcXyp8xR6h
         lP/aNjsgfZA6pZlSbA706asxczKSmOae8xdU9K9hwIKdLsjp6bcHaxzOUSzU4S9o6t5v
         xlX1Nmc5CQZHBX211+1B8iS8AJQq70/dtxwoSB3ERV1sQtxVL6RAxjUs8zy4mjvlmc1b
         KgwQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAVedSJ2ht7MsxQ2BZAIW9oQJtCbEXtd7Y6f6POE0rLkK6QI5ahK
	KOhrXyF3Kp6a2QkjmvjEOP9+K5uRxdr+AARlH79Ut9XMTHl99NifwvpBeTY5l0gkIZrrfR1RmYS
	IoStNBwCZqnLO8j4Dtz3tnaavTJK6rhMaLSK2tLitRrdwYgx7bIbDYd/+sd/GkHc=
X-Received: by 2002:a17:902:61:: with SMTP id 88mr12346738pla.166.1555024493934;
        Thu, 11 Apr 2019 16:14:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw0xz+ajiq2FpaHXrh1P/6aJ2xYE3eDsMLM+LEt+1g7FP2TiQrniX1qVAj+2U7Xc6Oi71KC
X-Received: by 2002:a17:902:61:: with SMTP id 88mr12346672pla.166.1555024493075;
        Thu, 11 Apr 2019 16:14:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555024493; cv=none;
        d=google.com; s=arc-20160816;
        b=ruBXljgfGaXfCJaHksDsVJNvqzVbZ0LQXSQ+4pe7QdjVSykyMAnGv2CJ1jUe3RrffR
         wtwnSd3WmsqesB0fOIJrikW2JjZdehTZMyUoVlF3R8nC4zlF/v/+NY1F2tktp9X3gpZL
         jyzAQA5WfYihHTXoO4Lv/SKB9efkqrKlbK9xI05LE6DZdGkoVcKCihzqVFwmfX9rmi6f
         f9wYq9dI84Kz9l/1uFcJAq946073yVj2+KHK2u2JKFvMR9KA71yHAVDbbs+9yTIDbuVl
         1GmOaVYvcVS4kd5FMiJ7la5+AZl5kM2OlP8gPfIrQucBOfi3u/gNl1VqeRmxn+24VACu
         px3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=0OQc2KFOseBtS6C5gc68UcucYkNWGRFhIlRqasBgoaA=;
        b=pAh0CuM8uoxCZ/OAVHP6i7Ld6CQKAwozrAi7omIPrftowcNTCW7hGqSr/qhRkrgvRL
         I+rU1fkqjm/lqUK3ddp9IstqaKbHWDWripcJYdZXPOoY4bsUexfzcr8fGtDYb+vAySAO
         px1C3yw/1n05s0fAr5D5wbLN6IXdFBC6+bFghTIwlJLQ5AbPI05Ro2VDTipKJLcmyXYq
         0FywpBMgSe9o0hUMWq8h1C29/H0vFhiKBJhG5KccV5NUBEcNpk0vyO2DtiAHbYutLiY/
         pmZvyGmMVBkKIPpwMzqh4vzxrxbnEstWJd9WjeuiguZKd++36I0lNRB1ZI0gr98WRnco
         dG0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id q4si35668996pfh.157.2019.04.11.16.14.52
        for <linux-mm@kvack.org>;
        Thu, 11 Apr 2019 16:14:53 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-160-97.pa.nsw.optusnet.com.au [49.195.160.97])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 9F97C105E6F9;
	Fri, 12 Apr 2019 09:14:44 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hEiu3-0008Sw-S5; Fri, 12 Apr 2019 09:14:43 +1000
Date: Fri, 12 Apr 2019 09:14:43 +1000
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
	Ernesto A =?iso-8859-1?Q?=2E_Fern=E1ndez?= <ernesto.mnd.fernandez@gmail.com>,
	Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH v1 12/15] fs/direct-io: keep track of wether a page is
 coming from GUP or not
Message-ID: <20190411231443.GD1695@dread.disaster.area>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <20190411210834.4105-13-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190411210834.4105-13-jglisse@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=UJetJGXy c=1 sm=1 tr=0 cx=a_idp_d
	a=EHa8gIBQe3daEtuMEU8ptg==:117 a=EHa8gIBQe3daEtuMEU8ptg==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=8nJEP1OIZ-IA:10 a=oexKYjalfGEA:10
	a=20KFwNOVAAAA:8 a=7-415B0cAAAA:8 a=eWkzej_naR1Ak5NVtaAA:9
	a=wPNLvfGTeEIA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 05:08:31PM -0400, jglisse@redhat.com wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> We want to keep track of how we got a reference on page when doing DIO,
> ie wether the page was reference through GUP (get_user_page*) or not.
> For that this patch rework the way page reference is taken and handed
> over between DIO code and BIO. Instead of taking a reference for page
> that have been successfuly added to a BIO we just steal the reference
> we have when we lookup the page (either through GUP or for ZERO_PAGE).
> 
> So this patch keep track of wether the reference has been stolen by the
> BIO or not. This avoids a bunch of get_page()/put_page() so this limit
> the number of atomic operations.

Is the asme set of changes appropriate for the fs/iomap.c direct IO
path (i.e. XFS)?

-Dave.
-- 
Dave Chinner
david@fromorbit.com

