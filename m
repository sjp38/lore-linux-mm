Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B71EEC282CE
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 00:08:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 736B72184B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 00:08:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 736B72184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 204036B0010; Thu, 11 Apr 2019 20:08:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B38B6B026A; Thu, 11 Apr 2019 20:08:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A37A6B026B; Thu, 11 Apr 2019 20:08:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF14C6B0010
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 20:08:55 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id l26so7217741qtk.18
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:08:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=x0izde7z5CrpjcjAKzlk30eJH24IS1NgTs8hJgtpSJ8=;
        b=tO7sx3oiJywWqK0V0lvdsKWsmiCHqNL8UVG3ZyUsy+7N69v0mK1sEP1PKMLOPQ013Z
         2NFvJjtz2e1C1o3f+z3nnQn8v8dnDhV/fhRAcOfxxI5Qlv53U0WAlBKMcDAekX9HWtdv
         RTJ8yBddZIZ3uQUy3Qf4U9mX/ZtzHF1/ULPTDNnZQxZ20b3878ZY9cduvqZQZrWOk8VB
         PAcvlGYlJ/SxOCIDgoxTw6YRQIFd2ZBzG6NXvIxqMZ+Q4dFVztQuY7l3nmNjMO9Y5myY
         pq4gbW8C9zfGpsolncQsW4MTOSzUx7W/TTHrVOK0sR1rEk/M82uNRoZxHXvglPquhLmK
         n+MA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVFDATgnWtybA314IkPk0JcCGdPV5cHFbdlhIy5/qlBqfHmxv+0
	XzA4yTW9rh8TTwKyGatkdb4Go17DPeuFH6ZkExcykkgdHZ9wiQZ9h1Tg3msiHUkBuQ2r0+/8MrB
	cJ/X28vh4QGve4AfsI4zcFUBWqM0RCf3UfXhB+XkT1heI4poltbLOpuaqZ+WGz3Wd5g==
X-Received: by 2002:ac8:2d13:: with SMTP id n19mr41010499qta.31.1555027735700;
        Thu, 11 Apr 2019 17:08:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwepxQCJsbYMiUj2QgmRxWzjfrSSps/9ow4bSR50v6O001mbQmEgoX8flg+XMg10PfuBY6o
X-Received: by 2002:ac8:2d13:: with SMTP id n19mr41010452qta.31.1555027734969;
        Thu, 11 Apr 2019 17:08:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555027734; cv=none;
        d=google.com; s=arc-20160816;
        b=DBManSm8HOlt3JtDvH3rjXXRteh8mk2I959yqVvB4wFGh21cUAavy1yLSqdJwUO3v3
         2Boe00G59cYTwctaDJq5e7RNQ9Td/Jqfhb6rtATpVoLG3F/8tHLkdb4GfIO8ldwjl5Kh
         n0+bj2LuUbI2gQxUvkkE2RaJkB4/KAoaHJHpmuEMX61K1L5IxYBz9URSLZNmXPE0SQH6
         5PcwfaEllrQ1/pBRxorHlkRJHePp5aZeulwPanNJyt/rGa3iUjzONvcx0YGpV2McgsRZ
         zV0XL8DFaPPwB+oBEG+yf3bogEMlo9YHre9WFuQFhoZLfUpQ4QadBdreD7B6dsxnGOEI
         P3MA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=x0izde7z5CrpjcjAKzlk30eJH24IS1NgTs8hJgtpSJ8=;
        b=h0PqczxnvWApMHUjm4LT88KJPKiqwBTOSh0DA9TmwR8UUXDelrPkF/l/KGkoOQD9It
         EccscjZXRqNwUNDHT9O6GqJAfQPlna1AVV/JU+4CYJb3nczVWL7k0TdAlRMc5Ht+HOhY
         Q4UdNJ9j60IxFj9H2Fq5NNEyMmTQARLGnVj9qMnTgyjsBNuiEpIbhadkho4E/16psO0u
         iyD04yr8ObLdbfEXKLeC2EGkXvVl0ArM84btAc9Qa3I93rnxOR7ZFWDxoeKbiwvB0JKq
         wpJNVmCpFFaW0FNkCPvphq2uKQdtp3tB8Ej+NySen4+ChEeOG6Gy9TAyMwDg/5+4a+8j
         moqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 11si247682qvl.102.2019.04.11.17.08.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 17:08:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BA22B19D2BD;
	Fri, 12 Apr 2019 00:08:53 +0000 (UTC)
Received: from redhat.com (ovpn-120-97.rdu2.redhat.com [10.10.120.97])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6EE7C5D9C8;
	Fri, 12 Apr 2019 00:08:48 +0000 (UTC)
Date: Thu, 11 Apr 2019 20:08:46 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Dave Chinner <david@fromorbit.com>
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
Message-ID: <20190412000846.GB13369@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <20190411210834.4105-13-jglisse@redhat.com>
 <20190411231443.GD1695@dread.disaster.area>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190411231443.GD1695@dread.disaster.area>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Fri, 12 Apr 2019 00:08:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 09:14:43AM +1000, Dave Chinner wrote:
> On Thu, Apr 11, 2019 at 05:08:31PM -0400, jglisse@redhat.com wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > We want to keep track of how we got a reference on page when doing DIO,
> > ie wether the page was reference through GUP (get_user_page*) or not.
> > For that this patch rework the way page reference is taken and handed
> > over between DIO code and BIO. Instead of taking a reference for page
> > that have been successfuly added to a BIO we just steal the reference
> > we have when we lookup the page (either through GUP or for ZERO_PAGE).
> > 
> > So this patch keep track of wether the reference has been stolen by the
> > BIO or not. This avoids a bunch of get_page()/put_page() so this limit
> > the number of atomic operations.
> 
> Is the asme set of changes appropriate for the fs/iomap.c direct IO
> path (i.e. XFS)?

Yes and it is part of this patchset AFAICT iomap use bio_iov_iter_get_pages()
which is updated to pass down wether page are coming from GUP or not. The
bio you get out of that is then release through iomap_dio_bio_end_io() which
calls bvec_put_page() which will use put_user_page() for GUPed page.

I may have miss a case and review are welcome.

Note that while the convertion is happening put_user_page is exactly the same
as put_page() in fact the implementation just call put_page() with nothing
else.

The tricky part is making sure that before we diverge with a put_user_page()
that does something else that put_page() we will need to be sure that we did
not left a path that do GUP but does call put_page() and not put_user_page().
We have some plan to catch that in debug build.

In any case i believe we will be very careful when the times come to change
put_user_page() to something different.

Cheers,
Jérôme

