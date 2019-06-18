Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00F60C31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 20:02:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94FA920679
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 20:02:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="D4LqXjau"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94FA920679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC5FA8E0005; Tue, 18 Jun 2019 16:02:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E751E8E0001; Tue, 18 Jun 2019 16:02:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CEFF18E0005; Tue, 18 Jun 2019 16:02:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 66FE18E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 16:02:57 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id e143so1719466lfd.9
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 13:02:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=cVl3SIklS0nHd797FYY4cxHoZEAnPslNYDQOv5OhMDM=;
        b=WTOaqCU0lxowSqAhaWmh+4IpCpCoChJq9JsHZMpPsXBGUqk2V+I5jyzMvHwnvxSBjI
         g4J2GqlDnlX7F2fV3Pit2psHEuSWdCvW1TuE4AeSSdoB02xZF6yjU8vXKMJptQpE+u7T
         w12lWErXsHxaU3KXKgLqwbBohc4FXivg/ai6GY+sLYUfViIJ5RfGpllpnOD9FIatlDJX
         /6sBIRTs78rvd5qmMbQrTqocOSZXWUZtLtZSg+76gq2/JPrhIiA8xJXxy3uJojSQtcpO
         X/Kd8yx+4MMNKUy/IOECH2IqaJCoFyD1V4NcdmjQVkXKnrm/uhMJFsJgKP9c1BCV0hXY
         gm1A==
X-Gm-Message-State: APjAAAUKoJVAthXyhdmrr2LR/WCzH4E/6gBiBm/M2jY4E2IvvgyJsQbP
	aDeL8UC8qncMyDuNW4u97Cy4sIt2w/UZlanbknTx2mDXeLdYihVUtLY8lgZiSwcmNglGqv+SRgg
	HyqC2INk6u7DsS3bS/gUJA6WDocQ642kNNbRgYifjoFxleM5j2TLdxzddJCssId00DQ==
X-Received: by 2002:ac2:4990:: with SMTP id f16mr2585914lfl.93.1560888176795;
        Tue, 18 Jun 2019 13:02:56 -0700 (PDT)
X-Received: by 2002:ac2:4990:: with SMTP id f16mr2585876lfl.93.1560888175875;
        Tue, 18 Jun 2019 13:02:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560888175; cv=none;
        d=google.com; s=arc-20160816;
        b=lYRiW2yRSD1zp5uJcrdyXzgE0di99hzp2cUDiBQM+odTFd2LMpCxnVwK9uZDIhsCa4
         +mCCPHFRggwoFJ4ffYkfyOmQ+pEuQNFNXzxWPxD9q7bAMAxhQsAYsYxruQoToR/HQoKZ
         xY74ZC8k3PfPqfiedozG3antQqdt+KEXJThYY/QlhaBV1kh2hQKXiSkjMlT9FqpLPbtC
         g2VqEHrvR8hf1H/vpijShiDS/SxSmXhpiZj49jZvm/StoPjq2RP8avsy6IGi/XJdIq0L
         N4O+rHeGZ9jkdp5NFsnptfZHm7PJt3ad4lIct309WZ0oHtAQyqAUrxTS7T3q4/x9NgpL
         aL6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=cVl3SIklS0nHd797FYY4cxHoZEAnPslNYDQOv5OhMDM=;
        b=K491YiGklXN1YA8av6v+h4e6YZPvvjYu9XzkBpnVOkn60Lrsg8v0NgUfWac7hzyEI6
         L2REs+HVAS7MpPsFgxfc+xmTWgW83Auxm312eQ9fHuJJoKQTftqpXOomtJTudHT+utvf
         hvs+fUSv0i2IeePlV6huUZTZdXgg4qOFUClNXQueUFmV4kVOO5enVQAo5cwcpjCtNckg
         4AAfHF3pr3VC+4T9p9QZZAP9C61VhXl7EhsHQh/A9r07gI42uC+NpgiPsC+FsTCYSNd/
         nzBcxUXpr40RS016jg6VRB61RzZDeZSvEFtjVq4W/lKuN3sFmRPCk9KVY2KeJeyiTGpX
         iJjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=D4LqXjau;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x1sor4101008lff.8.2019.06.18.13.02.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 13:02:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=D4LqXjau;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=cVl3SIklS0nHd797FYY4cxHoZEAnPslNYDQOv5OhMDM=;
        b=D4LqXjauq6e8L92SXdCI8dBOeZ9g3qnR+MvRfoDQP4UPl32roBpvGWprF3TjlmHSja
         eZ/6/ZjWzgRN9htttHJTrPzVJCoFvbIqpDA3vC1Cl8utSLu6XzXuxp7AabXcEV/Om6He
         yHiGKcbb2hB4xqghyhAsPiwk4UDzPPVak57pe2KgOS495X1pgno1vQnCtMEqE80s7SDd
         b/xHq26uOBUeyQq+iykM4OWAPJ5VZU59856GZ2QUrHkBfHjmAmn1pe6xmy0ce97q8t4y
         IfDjJ3INQeQbB5asZ/xxIwCfBifBBZjV8Yfyh2WDBB5G9dWZfMSeieDwA07Xq9c2du8P
         K49g==
X-Google-Smtp-Source: APXvYqzKO9zG2G36ym9WsDHSLpShB5YrpwSynDJM7DvNbZeZWMwp4g4634Uhi3PMXIvAfLocbMbxAg==
X-Received: by 2002:a05:6512:29a:: with SMTP id j26mr26109062lfp.44.1560888175432;
        Tue, 18 Jun 2019 13:02:55 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id j23sm1621386lfb.93.2019.06.18.13.02.54
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 18 Jun 2019 13:02:54 -0700 (PDT)
Date: Tue, 18 Jun 2019 23:02:51 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Colin King <colin.king@canonical.com>, Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: idle-page: fix oops because end_pfn is larger than
 max_pfn
Message-ID: <20190618200251.hd2uk6qzyvsy55py@esperanza>
References: <20190618124352.28307-1-colin.king@canonical.com>
 <20190618124502.7b9c32a00a54f0c618a12ca4@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190618124502.7b9c32a00a54f0c618a12ca4@linux-foundation.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 12:45:02PM -0700, Andrew Morton wrote:
> On Tue, 18 Jun 2019 13:43:52 +0100 Colin King <colin.king@canonical.com> wrote:
> 
> > From: Colin Ian King <colin.king@canonical.com>
> > 
> > Currently the calcuation of end_pfn can round up the pfn number to
> > more than the actual maximum number of pfns, causing an Oops. Fix
> > this by ensuring end_pfn is never more than max_pfn.
> > 
> > This can be easily triggered when on systems where the end_pfn gets
> > rounded up to more than max_pfn using the idle-page stress-ng
> > stress test:
> > 
> 
> cc Vladimir.  This seems rather obvious - I'm wondering if the code was
> that way for some subtle reason?

No subtle reason at all - just a bug. The patch looks good to me,

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

