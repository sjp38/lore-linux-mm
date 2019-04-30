Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF8D4C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 16:16:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5536B20835
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 16:16:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZEvdr6d2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5536B20835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D430D6B0003; Tue, 30 Apr 2019 12:16:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCCBD6B0005; Tue, 30 Apr 2019 12:16:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6D966B000A; Tue, 30 Apr 2019 12:16:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9B5A46B0003
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 12:16:11 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id k17so11794647ior.4
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:16:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+7vha2sHMjrOUYPXWIWZ5r9+BQnrS0i2CpGkGubXy9c=;
        b=QzYznWY2RYCBRj9aKFgMb6BgxGJDJpAQ3RURl9cHpZbGsr0YJF86KAZkxvl3aFl5Hv
         fWMgOBhQim9XveI9StQyab9YkoBkT+UIB4YMgaaU9rwawxf34zsrxnX8Sc0nvN0YdcXg
         OyZhonTkfX2dRV/w+gi+KQf7UQ8mq7rsdi9kHTzPUYDR5T0KVc2rLDlSN549zFPc4l60
         LXtQtOYnGoh1tVe+3+xvZjMJoe0vubq51ZoEdhsptQk2CjlknsRsoCwvh/dWhHft2R1O
         r07VqyDea/IqhycAklZ6HYaluVPPWJ8yPQef6B7rWVrKa9X/Hqg9VSZ+PLbC4Bn1KJUL
         WpCg==
X-Gm-Message-State: APjAAAU/tHJczdSCYSe1z1tsfhEd/MFBSL/jb6kqSa5kFL1zWjBOBS0K
	YR4dqvnHH6ka47+HQ7pA+SWKO+/NAXyJuMIhxNIb4X5Trt9BqXgVuHyHYsxwzAmHl3vPN8lY6Yx
	8EGq64qoAfVzp2bl9vlxp/b2mj5/sxmLadwEXD+bc8z7PoBtvG5fyYQh9LmU6T7Rfgw==
X-Received: by 2002:a24:220c:: with SMTP id o12mr4337927ito.1.1556640971390;
        Tue, 30 Apr 2019 09:16:11 -0700 (PDT)
X-Received: by 2002:a24:220c:: with SMTP id o12mr4337878ito.1.1556640970763;
        Tue, 30 Apr 2019 09:16:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556640970; cv=none;
        d=google.com; s=arc-20160816;
        b=pula+j5b1ibdyvpL022lgQOpC7dQm7xV3WkHlo//eBkWiKGr7c1DIvjEiwbsd/4lJ1
         XLw+Pu7zUdU7m/d7x6LBQutoNN0B1RhRahL+ch1Lsxv4lx9hgxjYfc7GEasVzSyD99MI
         joFgMh6cx9XDGCz6PrU1WZuWShkmgOnDj14dvw0+c4Pjf6bVpf/LbFMGeY3eoE+v36TM
         4QH/p214OmAY6aXp3Le/XrbGnVcoBjBw8FJrNhwphitGNTtwed2ZaUiVB6/lMS8Ysg1M
         T3BmNL88UdBuQJLO5VNTUwHsL9L5ZZKQRJnXaSWm7CKyuIPYRFVYIAbsX/gti1m7YY2j
         Fu/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+7vha2sHMjrOUYPXWIWZ5r9+BQnrS0i2CpGkGubXy9c=;
        b=oiyRZ89kcnirW/Uwjg5JOTfeRH9gJIQ261uBeBM3vpunA0N3nk3Famz3JnHya2juW0
         z/lKn9v0b63QNdJk8kMDD0WU/qml2oRa66MDWxblrDStSVzku5Rp31xJZbZiReBFaT7X
         WeZ6AZzvn67vrGOQF6cPhwAg36ykjbjz4mW8+3tiAWYw3MvKJSzVkohZ4ENP3LkvjVQX
         sw5tqTa7bjexx3dsYBo2/gWJ5Fpnovc6jiCnZ11K43sBAm+rm0ZtIzaqUPsqDFOaWbwN
         SNKEbjnoVrTZ5i7bav1Dm8r7PVdrYIdT9kVrhRRlXwiUcLcS0AwL/+j8zHfLakHSxKaT
         ziFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZEvdr6d2;
       spf=pass (google.com: domain of andreas.gruenbacher@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=andreas.gruenbacher@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o68sor4492094ito.13.2019.04.30.09.16.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 09:16:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreas.gruenbacher@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZEvdr6d2;
       spf=pass (google.com: domain of andreas.gruenbacher@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=andreas.gruenbacher@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+7vha2sHMjrOUYPXWIWZ5r9+BQnrS0i2CpGkGubXy9c=;
        b=ZEvdr6d2+xG0yFqb8iyxrYut8QGgl1yzTRo7Ow5Vhy3IMx37a+DFMc0lnlKsNqOEyh
         QfEnblICo9oXNPzKDKbn1EkJaP/hdE7bbewTFezSBWSNvQwty7TvYsr12iOw2YYBVCuP
         la57aMu8L/5bKdx24NXSPUU/kI7ud0lQqKualXqmGSg63pBdzObacOlkHEqsOZjBpiay
         QQtckT0qJ7Wqvq/aN+CZBi02U6Jco2A7k7V2nDIU7ex0Ne5FJPYzSB8yLdKO1NaYpIbs
         ilkZSqXC+az16c77RXYrGtRfMLMrzpM/XzBDXOihzs+S7WLlPflrS70Jay48fo2t/T4/
         7DDA==
X-Google-Smtp-Source: APXvYqxGmNhS7O0WYezZ5KKWcc7qENQZPHTzvK4iRd2jiksYSG3ib+sPBWVyqkn+Y5lNBSxxbI1mNOxM3EPGGfmqec0=
X-Received: by 2002:a24:ac3:: with SMTP id 186mr4260160itw.16.1556640970373;
 Tue, 30 Apr 2019 09:16:10 -0700 (PDT)
MIME-Version: 1.0
References: <20190429220934.10415-1-agruenba@redhat.com> <20190429220934.10415-6-agruenba@redhat.com>
 <20190430153256.GF5200@magnolia> <CAHc6FU5hHFWeGM8+fhfaNs22cSG+wtuTKZcMMKbfeetg1CK4BQ@mail.gmail.com>
 <20190430154707.GG5200@magnolia>
In-Reply-To: <20190430154707.GG5200@magnolia>
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
Date: Tue, 30 Apr 2019 18:15:58 +0200
Message-ID: <CAHpGcMKVE2=6xpUdWyDo8=tyyCWGYaO=Ni0+B_fGJRXiqwdt5g@mail.gmail.com>
Subject: Re: [PATCH v7 5/5] gfs2: Fix iomap write page reclaim deadlock
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>, cluster-devel <cluster-devel@redhat.com>, 
	Christoph Hellwig <hch@lst.de>, Bob Peterson <rpeterso@redhat.com>, Jan Kara <jack@suse.cz>, 
	Dave Chinner <david@fromorbit.com>, Ross Lagerwall <ross.lagerwall@citrix.com>, 
	Mark Syms <Mark.Syms@citrix.com>, =?UTF-8?B?RWR3aW4gVMO2csO2aw==?= <edvin.torok@citrix.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Am Di., 30. Apr. 2019 um 17:48 Uhr schrieb Darrick J. Wong
<darrick.wong@oracle.com>:
> Ok, I'll take the first four patches through the iomap branch and cc you
> on the pull request.

Ok great, thanks.

Andreas

